-- Amazon Laptop Market Intelligence Dashboard
-- Core table schema for storing daily Amazon laptop snapshots

CREATE TABLE IF NOT EXISTS amazon_data (
    product_id VARCHAR(100) NOT NULL,
    product_name VARCHAR(500) DEFAULT NULL,
    brand VARCHAR(200) DEFAULT NULL,
    category VARCHAR(200) DEFAULT NULL,
    price DECIMAL(10,2) DEFAULT NULL,
    rating DECIMAL(3,2) DEFAULT NULL,
    review_count INT DEFAULT NULL,
    load_date DATE DEFAULT NULL,
    load_timestamp DATETIME DEFAULT NULL,

    CONSTRAINT uq_product_day
        UNIQUE (product_id, load_date)
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;
