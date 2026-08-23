import os
import requests
import pandas as pd
import mysql.connector
from sqlalchemy import create_engine
from datetime import datetime
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
import logging
import html
from urllib.parse import quote_plus
from dotenv import load_dotenv


load_dotenv()  # Load environment variables from .env file

# Configure logs
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s"
)

# Database Configurations
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_NAME = os.getenv("DB_NAME", "Amazon_Project")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")

# Daily market snapshot settings
SEARCH_PAGES = 3

# OpenWeb Ninja API Setup
API_KEY = os.getenv("OPENWEBNINJA_API_KEY") 

if not all([DB_USER, DB_PASSWORD, API_KEY]):
    raise ValueError(
        "Missing required environment variables. "
        "Check your .env file."
    )

BASE_URL = "https://api.openwebninja.com/realtime-amazon-data"
HEADERS = {
    "X-API-Key": API_KEY,
    "Accept": "application/json"
}

# Database Engine setup
DB_PASSWORD_ENCODED = quote_plus(DB_PASSWORD)

ENGINE = create_engine(
    f"mysql+mysqlconnector://{DB_USER}:{DB_PASSWORD_ENCODED}@{DB_HOST}/{DB_NAME}"
)

# Safe Session Networking
session = requests.Session()
retry_strategy = Retry(
    total=3,
    backoff_factor=2,
    status_forcelist=[429, 500, 502, 503, 504]
)
session.mount("https://", HTTPAdapter(max_retries=retry_strategy))


def get_today_loaded_asins():
    """Gets product IDs already loaded today to avoid duplicate same-day inserts."""
    try:
        with mysql.connector.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME
        ) as db:
            cursor = db.cursor()
            cursor.execute(
                "SELECT product_id FROM amazon_data WHERE load_date = CURDATE()"
            )
            return {row[0] for row in cursor.fetchall()}
    except Exception as e:
        logging.error(f"Failed to fetch today's loaded ASINs: {e}")
        return set()


def clean_product_name(product_title):
    """Cleans product title text."""
    title = str(product_title).strip()

    title = title.replace("DellLaptop", "Dell Laptop")
    title = title.replace("DELLLaptop", "DELL Laptop")
    title = title.replace("Delllaptop", "Dell Laptop")
    title = title.replace("DELLlaptop", "DELL Laptop")

    if title.lower().startswith("acer "):
        title = "Acer " + title[5:]

    if title.lower().startswith("dell "):
        title = "Dell " + title[5:]

    return title


def extract_brand(product_title):
    """Extracts brand from product title."""
    title = clean_product_name(product_title)
    title_upper = title.upper()

    known_brands = {
        "ASUS": "ASUS",
        "HP": "HP",
        "LENOVO": "Lenovo",
        "ACER": "Acer",
        "DELL": "DELL",
        "APPLE": "Apple",
        "SAMSUNG": "Samsung",
        "MSI": "MSI",
        "ALIENWARE": "Alienware",
        "PRIMEBOOK": "Primebook",
        "BROWSEBOOK": "BrowseBook",
        "EBOOK": "EBook"
    }

    for key, value in known_brands.items():
        if title_upper.startswith(key):
            return value

    return title.split()[0] if title else "Unknown"


def run_pipeline():
    start_time = datetime.now()
    all_laptops = []

    logging.info("Launching daily Amazon laptop market snapshot routine...")
    logging.info(f"SEARCH_PAGES setting = {SEARCH_PAGES}")

    url = f"{BASE_URL}/search"
    seen_asins = set()

    for page in range(1, SEARCH_PAGES + 1):
        params = {
            "query": "laptops",
            "country": "IN",
            "page": str(page)
        }

        try:
            logging.info(f"Extracting laptop search snapshot page {page} from OpenWeb Ninja...")

            response = session.get(
                url,
                headers=HEADERS,
                params=params,
                timeout=15
            )

            if response.status_code == 200:
                results = response.json().get("data", {}).get("products", [])

                logging.info(f"Page {page} returned {len(results)} raw products.")

                if not results:
                    logging.warning(f"No products returned on page {page}.")
                    break

                for item in results:
                    asin = item.get("asin")

                    if asin and asin not in seen_asins:
                        seen_asins.add(asin)

                        all_laptops.append({
                            "product_id": asin,
                            "product_name": clean_product_name(item.get("product_title")),
                            "brand": extract_brand(item.get("product_title")),
                            "category": "Laptops",
                            "price": item.get("product_price"),
                            "rating": item.get("product_star_rating"),
                            "review_count": item.get("product_num_ratings")
                        })

            else:
                logging.error(f"Search snapshot page {page} rejected by API: {response.status_code}")
                logging.error(f"API response body: {response.text[:1000]}")
                break

        except Exception as e:
            logging.error(f"Search snapshot call failed on page {page}: {e}")
            break

    logging.info(f"Search snapshot finished. Collected {len(all_laptops)} raw entries.")

    if not all_laptops:
        logging.warning("Pipeline executed successfully but zero raw records were extracted.")
        return

    # Data Cleaning
    df = pd.DataFrame(all_laptops)
    logging.info(f"Rows entering data cleaning pipeline: {len(df)}")

    required_cols = [
        "product_id",
        "product_name",
        "brand",
        "category",
        "price",
        "rating",
        "review_count"
    ]

    missing_cols = [col for col in required_cols if col not in df.columns]

    if missing_cols:
        raise ValueError(f"Missing required columns: {missing_cols}")

    # Remove duplicate products inside same API run
    before_dup = len(df)

    df.drop_duplicates(
        subset=["product_id"],
        keep="last",
        inplace=True
    )

    logging.info(f"Removed {before_dup - len(df)} duplicate items inside this execution.")

    # Clean text columns
    df["product_id"] = df["product_id"].astype(str).str.strip()
    df["product_name"] = df["product_name"].astype(str).str.strip()
    df["product_name"] = df["product_name"].apply(html.unescape)
    df["brand"] = df["brand"].astype(str).str.strip()
    df["category"] = df["category"].astype(str).str.strip()

    # Remove blank text records
    df = df[
        (df["product_id"] != "") &
        (df["product_name"] != "") &
        (df["brand"] != "") &
        (df["category"] != "")
    ]

    # Clean price
    df["price"] = (
        df["price"]
        .astype(str)
        .str.replace("₹", "", regex=False)
        .str.replace(",", "", regex=False)
    )

    df["price"] = pd.to_numeric(df["price"], errors="coerce")

    # Clean rating
    df["rating"] = pd.to_numeric(df["rating"], errors="coerce")

    # Clean review count
    df["review_count"] = (
        df["review_count"]
        .astype(str)
        .str.replace(",", "", regex=False)
    )

    df["review_count"] = pd.to_numeric(df["review_count"], errors="coerce")

    # Data boundary checks
    before_invalid = len(df)

    df = df[
        (df["price"].notna()) &
        (df["price"] > 0) &
        (df["rating"].notna()) &
        (df["rating"] >= 0) &
        (df["rating"] <= 5) &
        (df["review_count"].notna()) &
        (df["review_count"] >= 0)
    ]

    logging.info(f"Data boundary check finished. Removed {before_invalid - len(df)} invalid rows.")

    # Add load timestamps
    load_time = datetime.now()
    df["load_date"] = load_time.date()
    df["load_timestamp"] = load_time

    # Avoid duplicate inserts for same day
    today_loaded_asins = get_today_loaded_asins()
    before_existing_today = len(df)

    df = df[
        ~df["product_id"].isin(today_loaded_asins)
    ]

    logging.info(f"Removed {before_existing_today - len(df)} products already loaded today.")

    df.drop_duplicates(
        subset=["product_id", "load_date"],
        keep="last",
        inplace=True
    )

    logging.info(f"Final clean rows ready for database insertion: {len(df)}")

    if df.empty:
        logging.info("No new products to insert today.")
        return

    try:
        df.to_sql(
            "amazon_data",
            con=ENGINE,
            if_exists="append",
            index=False
        )

        logging.info(f"Successfully loaded {len(df)} sanitized records into MySQL.")
        logging.info(f"Pipeline executed in: {datetime.now() - start_time}")

    except Exception as e:
        logging.error(f"Data Warehouse Load Aborted: {e}")


if __name__ == "__main__":
    run_pipeline()