# Python ETL Pipeline

This folder contains the Python ETL pipeline used to collect and process daily Amazon laptop market snapshots.

## Pipeline Flow

The pipeline performs the following steps:

1. Connects to the Amazon data API using credentials stored in environment variables.
2. Retrieves laptop search-result data across configured result pages.
3. Uses retry logic to handle temporary API and network failures.
4. Prevents duplicate product IDs within the same API execution.
5. Cleans product names, brand values, prices, ratings, and review counts.
6. Validates data boundaries, including positive prices, ratings between 0 and 5, and non-negative review counts.
7. Adds daily load date and timestamp fields to support historical snapshot analysis.
8. Queries MySQL to identify products already loaded on the current day.
9. Prevents duplicate same-day inserts while allowing the same product to be captured again on future days.
10. Loads the final cleaned dataset into the `amazon_data` MySQL table.

## Main File

* `amazon_pipeline.py` — Complete ETL pipeline for extraction, transformation, validation, duplicate handling, and MySQL loading.

## Configuration

Sensitive values are not stored in the Python script. The pipeline reads the required credentials from environment variables:

* `OPENWEBNINJA_API_KEY`
* `DB_HOST`
* `DB_USER`
* `DB_PASSWORD`
* `DB_NAME`

See the `.env.example` file in the project root for the required configuration format.
