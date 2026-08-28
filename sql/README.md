# SQL

This folder contains the database schema and analytical SQL views used in the Amazon Laptop Market Intelligence Dashboard.

## Files

### `amazon_schema.sql`

Defines the core `amazon_data` table used to store daily Amazon laptop market snapshots.

The table uses a composite unique constraint on:

- `product_id`
- `load_date`

This prevents duplicate records for the same product on the same day while allowing the same product to be tracked across different days for historical analysis.

### `amazon_views.sql`

Contains 16 analytical SQL views built on top of the raw snapshot table.

Key views include:

- `vw_clean_amazon` — cleaned base dataset
- `vw_latest_snapshot` — most recent market snapshot
- `vw_price_history` — product-level historical price tracking
- `vw_review_growth` — review count changes over time
- `vw_rating_trend` — rating changes over time
- `vw_social_proof` — rating and review-based social proof score
- `vw_laptop_specs` — specification extraction from product titles
- `vw_laptop_specs_dashboard` — dashboard-ready analytical dataset

These views create the analytical layer between the raw MySQL snapshot table and Power BI reporting.

