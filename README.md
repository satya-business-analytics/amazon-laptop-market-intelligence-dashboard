# Amazon Laptop Market Intelligence Dashboard

This is an in-progress Business Analytics portfolio project focused on building an automated market intelligence dashboard using Python, MySQL, SQL views, and Power BI.

The project collects daily API-based laptop market snapshots, cleans product pricing, rating, review, brand, and specification fields, stores daily snapshots in MySQL, and visualizes business KPIs in Power BI.

## Current Status

- Daily data collection is in progress
- Power BI dashboard design is completed
- MySQL storage and SQL views are being used
- Final screenshots, documentation, and cleaned code will be added after the 30-day data collection period

## Tools Used

- Python
- pandas
- MySQL
- SQL
- Power BI
- DAX
- Power Query
- Windows Task Scheduler

## Data Scope

This project uses daily API-based Amazon laptop search-result snapshots as a market visibility sample.

The pipeline is configured to collect a limited number of search-result pages per daily run to manage API credits and maintain consistent tracking. Depending on the API response volume and cleaning rules, each daily snapshot captures approximately 40–60 cleaned product records.

The project does not claim to track every Amazon laptop listing or guarantee the exact same products every day. Instead, it is designed to monitor visible market patterns such as brand share, pricing tiers, specifications, ratings, reviews, and daily snapshot trends.

## Planned Additions

- Final dashboard screenshots
- Cleaned Python ETL script
- SQL table schema and SQL views
- Project documentation
- BPMN process diagram
- Task Scheduler setup notes
- Final LinkedIn project post
