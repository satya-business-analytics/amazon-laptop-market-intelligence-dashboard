-- Amazon Laptop Market Intelligence Dashboard
-- Analytical SQL views used for market analysis and Power BI reporting

USE amazon_project; 

-- 1. Clean base view for Power BI
CREATE OR REPLACE VIEW vw_clean_amazon AS
SELECT
    product_id,
    TRIM(product_name) AS product_name,
    TRIM(brand) AS brand,
    TRIM(category) AS category,
    price,
    rating,
    review_count,
    load_date,
    load_timestamp
FROM amazon_data;


-- 2. Brand summary view
CREATE OR REPLACE VIEW vw_brand_summary AS
SELECT
    brand,
    COUNT(DISTINCT product_id) AS total_products,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(rating), 2) AS avg_rating,
    SUM(review_count) AS total_reviews
FROM vw_clean_amazon
GROUP BY brand;


-- 3. Market share view
CREATE OR REPLACE VIEW vw_market_share AS
SELECT
    brand,
    COUNT(DISTINCT product_id) AS total_products,
    ROUND(
        COUNT(DISTINCT product_id) * 100.0 /
        (SELECT COUNT(DISTINCT product_id) FROM vw_clean_amazon),
        2
    ) AS market_share_pct
FROM vw_clean_amazon
GROUP BY brand;


-- 4. Price tier view
CREATE OR REPLACE VIEW vw_price_tier AS
SELECT
    product_id,
    product_name,
    brand,
    price,
    CASE
        WHEN price < 30000 THEN 'Budget'
        WHEN price < 60000 THEN 'Mid Range'
        WHEN price < 100000 THEN 'Premium'
        ELSE 'Ultra Premium'
    END AS price_tier,
    rating,
    review_count,
    load_date
FROM vw_clean_amazon;


-- 5. Price tier summary view
CREATE OR REPLACE VIEW vw_price_tier_summary AS
SELECT
    price_tier,
    COUNT(DISTINCT product_id) AS total_products,
    ROUND(
        COUNT(DISTINCT product_id) * 100.0 /
        (SELECT COUNT(DISTINCT product_id) FROM vw_price_tier),
        2
    ) AS price_tier_pct,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(rating), 2) AS avg_rating
FROM vw_price_tier
GROUP BY price_tier;


-- 6. Brand + price tier summary
CREATE OR REPLACE VIEW vw_brand_price_tier_summary AS
SELECT
    brand,
    price_tier,
    COUNT(DISTINCT product_id) AS total_products,
    ROUND(
        COUNT(DISTINCT product_id) * 100.0 /
        (
            SELECT COUNT(DISTINCT product_id)
            FROM vw_price_tier
        ),
        2
    ) AS overall_share_pct,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(rating), 2) AS avg_rating
FROM vw_price_tier
GROUP BY brand, price_tier;


-- 7. Value score view
CREATE OR REPLACE VIEW vw_value_score AS
SELECT
    product_id,
    product_name,
    brand,
    price,
    rating,
    review_count,
    ROUND(rating / NULLIF(price, 0) * 10000, 2) AS value_score,
    load_date
FROM vw_clean_amazon
WHERE review_count >= 50;


-- 8. Social proof view
CREATE OR REPLACE VIEW vw_social_proof AS
SELECT
    product_id,
    product_name,
    brand,
    rating,
    review_count,
    price,
    ROUND(rating * LOG10(review_count + 1), 2) AS social_proof_score,
    load_date
FROM vw_clean_amazon;


-- 9. Latest snapshot view
CREATE OR REPLACE VIEW vw_latest_snapshot AS
SELECT *
FROM vw_clean_amazon
WHERE load_date = (
    SELECT MAX(load_date)
    FROM amazon_data
);


-- 10. Price history view with LAG and rolling averages
CREATE OR REPLACE VIEW vw_price_history AS
SELECT
    product_id,
    product_name,
    brand,
    price,
    rating,
    review_count,
    load_date,

    LAG(price) OVER (
        PARTITION BY product_id
        ORDER BY load_date
    ) AS previous_price,

    ROUND(
        price - LAG(price) OVER (
            PARTITION BY product_id
            ORDER BY load_date
        ),
        2
    ) AS price_change,

    ROUND(
        (
            price - LAG(price) OVER (
                PARTITION BY product_id
                ORDER BY load_date
            )
        ) / NULLIF(
            LAG(price) OVER (
                PARTITION BY product_id
                ORDER BY load_date
            ),
            0
        ) * 100,
        2
    ) AS price_change_pct,

    ROUND(
        AVG(price) OVER (
            PARTITION BY product_id
            ORDER BY load_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS rolling_7_day_avg,

    ROUND(
        AVG(price) OVER (
            PARTITION BY product_id
            ORDER BY load_date
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS rolling_30_day_avg

FROM vw_clean_amazon;


-- 11. Review growth view
CREATE OR REPLACE VIEW vw_review_growth AS
SELECT
    product_id,
    product_name,
    brand,
    review_count,
    load_date,

    LAG(review_count) OVER (
        PARTITION BY product_id
        ORDER BY load_date
    ) AS previous_review_count,

    review_count - LAG(review_count) OVER (
        PARTITION BY product_id
        ORDER BY load_date
    ) AS review_growth

FROM vw_clean_amazon;


-- 12. Rating trend view
CREATE OR REPLACE VIEW vw_rating_trend AS
SELECT
    product_id,
    product_name,
    brand,
    rating,
    load_date,

    LAG(rating) OVER (
        PARTITION BY product_id
        ORDER BY load_date
    ) AS previous_rating,

    ROUND(
        rating - LAG(rating) OVER (
            PARTITION BY product_id
            ORDER BY load_date
        ),
        2
    ) AS rating_change

FROM vw_clean_amazon;


-- 13. KPI summary view for dashboard cards
CREATE OR REPLACE VIEW vw_kpi_summary AS
SELECT
    load_date,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(rating), 2) AS avg_rating,
    COUNT(DISTINCT product_id) AS market_volume,
    COUNT(DISTINCT brand) AS total_brands
FROM vw_clean_amazon
GROUP BY load_date;


-- 14. KPI change view with 1% tolerance support
CREATE OR REPLACE VIEW vw_kpi_change AS
SELECT
    load_date,
    avg_price,
    avg_rating,
    market_volume,
    total_brands,

    LAG(avg_price) OVER (ORDER BY load_date) AS previous_avg_price,
    LAG(avg_rating) OVER (ORDER BY load_date) AS previous_avg_rating,
    LAG(market_volume) OVER (ORDER BY load_date) AS previous_market_volume,

    ROUND(
        (avg_price - LAG(avg_price) OVER (ORDER BY load_date))
        / NULLIF(LAG(avg_price) OVER (ORDER BY load_date), 0) * 100,
        2
    ) AS avg_price_change_pct,

    ROUND(
        (avg_rating - LAG(avg_rating) OVER (ORDER BY load_date))
        / NULLIF(LAG(avg_rating) OVER (ORDER BY load_date), 0) * 100,
        2
    ) AS avg_rating_change_pct,

    ROUND(
        (market_volume - LAG(market_volume) OVER (ORDER BY load_date))
        / NULLIF(LAG(market_volume) OVER (ORDER BY load_date), 0) * 100,
        2
    ) AS market_volume_change_pct

FROM vw_kpi_summary;


-- 15. Laptop_specs 

CREATE OR REPLACE VIEW vw_laptop_specs AS
WITH latest AS (
    SELECT a.*
    FROM amazon_data a
    INNER JOIN (
        SELECT product_id, MAX(load_date) AS max_load_date
        FROM amazon_data
        GROUP BY product_id
    ) b
        ON a.product_id = b.product_id
       AND a.load_date = b.max_load_date
),
base AS (
    SELECT
        product_id,
        product_name,
        brand,
        category,
        price,
        rating,
        review_count,
        load_date,
        UPPER(product_name) AS pn,
        UPPER(brand) AS brand_upper
    FROM latest
)
SELECT
    product_id,
    product_name,
    brand,
    category,
    price,
    rating,
    review_count,
    load_date,

    CASE
        WHEN pn LIKE '%INTEL%' OR pn LIKE '%CORE I%' OR pn LIKE '%CORE 3%' OR pn LIKE '%CORE 5%' OR pn LIKE '%CORE 7%' OR pn LIKE '%CORE ULTRA%' THEN 'Intel'
        WHEN pn LIKE '%AMD%' OR pn LIKE '%RYZEN%' OR pn LIKE '%ATHLON%' THEN 'AMD'
        WHEN pn LIKE '%SNAPDRAGON%' OR pn LIKE '%QUALCOMM%' THEN 'Qualcomm'
        WHEN brand_upper = 'APPLE' OR pn LIKE '%A18%' THEN 'Apple'
        WHEN pn LIKE '%MEDIATEK%' OR pn LIKE '%HELIO%' THEN 'MediaTek'
        ELSE 'Unknown'
    END AS processor_brand,

    CASE
        WHEN pn LIKE '%CORE ULTRA 9%' THEN 'Core Ultra 9'
        WHEN pn LIKE '%CORE ULTRA 7%' THEN 'Core Ultra 7'
        WHEN pn LIKE '%CORE ULTRA 5%' THEN 'Core Ultra 5'
        WHEN pn LIKE '%I9%' OR pn LIKE '%CORE I9%' THEN 'Core i9'
        WHEN pn LIKE '%I7%' OR pn LIKE '%CORE I7%' OR pn LIKE '%CORE 7%' THEN 'Core i7 / Core 7'
        WHEN pn LIKE '%I5%' OR pn LIKE '%CORE I5%' OR pn LIKE '%CORE 5%' THEN 'Core i5 / Core 5'
        WHEN pn LIKE '%I3%' OR pn LIKE '%CORE I3%' OR pn LIKE '%CORE 3%' THEN 'Core i3 / Core 3'
        WHEN pn LIKE '%RYZEN AI 9%' THEN 'Ryzen AI 9'
        WHEN pn LIKE '%RYZEN AI 7%' THEN 'Ryzen AI 7'
        WHEN pn LIKE '%RYZEN AI 5%' THEN 'Ryzen AI 5'
        WHEN pn LIKE '%RYZEN 9%' THEN 'Ryzen 9'
        WHEN pn LIKE '%RYZEN 7%' THEN 'Ryzen 7'
        WHEN pn LIKE '%RYZEN 5%' THEN 'Ryzen 5'
        WHEN pn LIKE '%RYZEN 3%' THEN 'Ryzen 3'
        WHEN pn LIKE '%ATHLON%' THEN 'Athlon'
        WHEN pn LIKE '%CELERON%' THEN 'Celeron'
        WHEN pn LIKE '%PENTIUM%' THEN 'Pentium'
        WHEN pn LIKE '%SNAPDRAGON X%' THEN 'Snapdragon X'
        WHEN pn LIKE '%SNAPDRAGON%' THEN 'Snapdragon'
        WHEN pn LIKE '%A18%' OR brand_upper = 'APPLE' THEN 'Apple Silicon'
        WHEN pn LIKE '%MEDIATEK%' OR pn LIKE '%HELIO%' THEN 'MediaTek / Helio'
        ELSE 'Other / Unknown'
    END AS processor_family,

    CAST(
        REGEXP_SUBSTR(
            REGEXP_SUBSTR(
                pn,
                '[0-9]{1,3}[ ]*GB[ ]*(DDR[0-9X]*|LPDDR[0-9X]*|RAM|UNIFIED MEMORY)'
            ),
            '[0-9]{1,3}'
        ) AS UNSIGNED
    ) AS ram_gb,

    CASE
        WHEN pn LIKE '%LPDDR5X%' THEN 'LPDDR5X'
        WHEN pn LIKE '%LPDDR5%' THEN 'LPDDR5'
        WHEN pn LIKE '%LPDDR4X%' THEN 'LPDDR4X'
        WHEN pn LIKE '%DDR5%' THEN 'DDR5'
        WHEN pn LIKE '%DDR4%' THEN 'DDR4'
        WHEN pn LIKE '%UNIFIED MEMORY%' THEN 'Unified Memory'
        ELSE 'Unknown'
    END AS ram_type,

    CASE
        WHEN REGEXP_SUBSTR(pn, '[0-9]{1,2}[ ]*TB[ ]*(SSD|NVME|STORAGE)') IS NOT NULL THEN
            CAST(
                REGEXP_SUBSTR(
                    REGEXP_SUBSTR(pn, '[0-9]{1,2}[ ]*TB[ ]*(SSD|NVME|STORAGE)'),
                    '[0-9]{1,2}'
                ) AS UNSIGNED
            ) * 1024
        WHEN REGEXP_SUBSTR(pn, '[0-9]{2,4}[ ]*GB[ ]*(SSD|NVME|EMMC|UFS|STORAGE)') IS NOT NULL THEN
            CAST(
                REGEXP_SUBSTR(
                    REGEXP_SUBSTR(pn, '[0-9]{2,4}[ ]*GB[ ]*(SSD|NVME|EMMC|UFS|STORAGE)'),
                    '[0-9]{2,4}'
                ) AS UNSIGNED
            )
        ELSE NULL
    END AS storage_gb,

    CASE
        WHEN pn LIKE '%NVME%' THEN 'NVMe SSD'
        WHEN pn LIKE '%SSD%' THEN 'SSD'
        WHEN pn LIKE '%EMMC%' THEN 'eMMC'
        WHEN pn LIKE '%UFS%' THEN 'UFS'
        ELSE 'Unknown'
    END AS storage_type,

    CAST(
        REGEXP_SUBSTR(
            REGEXP_SUBSTR(pn, '[0-9]{2}(\\.[0-9])?[ ]*("|INCH|INCHES)'),
            '[0-9]{2}(\\.[0-9])?'
        ) AS DECIMAL(4,1)
    ) AS screen_size_in,

    CASE
        WHEN pn LIKE '%OLED%' THEN 'OLED'
        WHEN pn LIKE '%IPS%' THEN 'IPS'
        WHEN pn LIKE '%TN%' THEN 'TN'
        ELSE 'Standard / Unknown'
    END AS panel_type,

    CASE
        WHEN pn LIKE '%2.5K%' THEN '2.5K'
        WHEN pn LIKE '%2.2K%' THEN '2.2K'
        WHEN pn LIKE '%2K%' THEN '2K'
        WHEN pn LIKE '%QHD%' OR pn LIKE '%WQXGA%' THEN 'QHD / WQXGA'
        WHEN pn LIKE '%WUXGA%' THEN 'WUXGA'
        WHEN pn LIKE '%FHD+%' THEN 'FHD+'
        WHEN pn LIKE '%FHD%' OR pn LIKE '%FULL HD%' THEN 'FHD'
        WHEN pn LIKE '%HD%' THEN 'HD'
        ELSE 'Unknown'
    END AS display_resolution,

    CASE
        WHEN REGEXP_SUBSTR(pn, 'RTX[ ]?[0-9]{4}') IS NOT NULL THEN
            REGEXP_REPLACE(REGEXP_SUBSTR(pn, 'RTX[ ]?[0-9]{4}'), 'RTX', 'RTX ')
        WHEN pn LIKE '%RADEON%' THEN 'AMD Radeon'
        WHEN pn LIKE '%IRIS XE%' THEN 'Intel Iris Xe'
        WHEN pn LIKE '%INTEL UHD%' OR pn LIKE '%UHD GRAPHICS%' THEN 'Intel UHD'
        WHEN pn LIKE '%ADRENO%' THEN 'Qualcomm Adreno'
        ELSE 'Integrated / Unknown'
    END AS gpu_type,

    CASE
        WHEN pn LIKE '%WINDOWS 11%' OR pn LIKE '%WIN11%' OR pn LIKE '%WIN 11%' OR pn LIKE '%W11%' THEN 'Windows 11'
        WHEN pn LIKE '%WINDOWS 10%' OR pn LIKE '%WIN 10%' THEN 'Windows 10'
        WHEN pn LIKE '%CHROME OS%' OR pn LIKE '%CHROMEBOOK%' THEN 'Chrome OS'
        WHEN pn LIKE '%UBUNTU%' THEN 'Ubuntu'
        WHEN pn LIKE '%DOS%' THEN 'DOS'
        WHEN pn LIKE '%ANDROID%' OR pn LIKE '%PRIMEOS%' THEN 'Android / PrimeOS'
        ELSE 'Unknown'
    END AS os_type,

    CASE
        WHEN pn LIKE '%GAMING%' OR pn LIKE '%RTX%' OR pn LIKE '%ROG%' OR pn LIKE '%TUF%' OR pn LIKE '%LOQ%' OR pn LIKE '%LEGION%' OR pn LIKE '%VICTUS%' OR pn LIKE '%OMEN%' OR pn LIKE '%PREDATOR%' OR pn LIKE '%ALIENWARE%' THEN 'Gaming'
        WHEN pn LIKE '%AI PC%' OR pn LIKE '%AI POWERED%' OR pn LIKE '%COPILOT%' OR pn LIKE '%CORE ULTRA%' OR pn LIKE '%RYZEN AI%' OR pn LIKE '%SNAPDRAGON X%' THEN 'AI / Copilot'
        WHEN pn LIKE '%BUSINESS%' OR pn LIKE '%PROFESSIONAL%' OR pn LIKE '%PRO 15%' THEN 'Business'
        WHEN pn LIKE '%CHROMEBOOK%' OR pn LIKE '%CHROME OS%' THEN 'Chromebook'
        WHEN pn LIKE '%STUDENT%' OR pn LIKE '%PRIMEBOOK%' OR pn LIKE '%EBOOK%' OR pn LIKE '%BROWSEBOOK%' THEN 'Student / Entry'
        WHEN pn LIKE '%THIN%' OR pn LIKE '%LIGHT%' THEN 'Thin & Light'
        ELSE 'General'
    END AS laptop_segment

FROM base;


CREATE OR REPLACE VIEW vw_laptop_specs_dashboard AS
SELECT
    product_id,
    product_name,
    brand,
    category,
    price,
    rating,
    review_count,
    load_date,

    CASE
        WHEN price < 30000 THEN 'Budget'
        WHEN price < 60000 THEN 'Mid Range'
        WHEN price < 100000 THEN 'Premium'
        ELSE 'Ultra Premium'
    END AS price_tier,

    processor_brand,
    processor_family,

    CASE
        WHEN ram_gb IS NULL THEN 'Unknown'
        ELSE CONCAT(ram_gb, ' GB')
    END AS ram_size,

    CASE
        WHEN ram_gb IS NULL THEN 'Unknown'
        WHEN ram_gb <= 4 THEN '4 GB or below'
        WHEN ram_gb = 8 THEN '8 GB'
        WHEN ram_gb = 12 THEN '12 GB'
        WHEN ram_gb = 16 THEN '16 GB'
        WHEN ram_gb = 24 THEN '24 GB'
        WHEN ram_gb >= 32 THEN '32 GB+'
        ELSE 'Other'
    END AS ram_tier,

    ram_type,

    CASE
        WHEN storage_gb IS NULL THEN 'Unknown'
        ELSE CONCAT(storage_gb, ' GB')
    END AS storage_size,

    CASE
        WHEN storage_gb IS NULL THEN 'Unknown'
        WHEN storage_gb < 256 THEN 'Below 256 GB'
        WHEN storage_gb = 256 THEN '256 GB'
        WHEN storage_gb = 512 THEN '512 GB'
        WHEN storage_gb = 1024 THEN '1 TB'
        WHEN storage_gb > 1024 THEN 'Above 1 TB'
        ELSE 'Other'
    END AS storage_tier,

    storage_type,
    screen_size_in,

    CASE
        WHEN screen_size_in IS NULL THEN 'Unknown'
        WHEN screen_size_in < 14 THEN 'Below 14 inch'
        WHEN screen_size_in >= 14 AND screen_size_in < 15 THEN '14 inch'
        WHEN screen_size_in >= 15 AND screen_size_in < 16 THEN '15 inch'
        WHEN screen_size_in >= 16 THEN '16 inch+'
        ELSE 'Unknown'
    END AS screen_size_tier,

    panel_type,
    display_resolution,
    gpu_type,
    os_type,
    laptop_segment,

    CASE
        WHEN ram_gb IS NULL OR storage_gb IS NULL OR processor_brand = 'Unknown'
        THEN 'Needs Review'
        ELSE 'Parsed'
    END AS spec_parse_status

FROM vw_laptop_specs;
