# Automation

This folder documents the scheduled execution of the Amazon Laptop Market Intelligence data pipeline.

## Automation Tool

The project uses **Windows Task Scheduler** to automate the daily execution of the Python data pipeline.

The scheduled task runs the pipeline automatically without requiring manual execution.

## Automated Workflow

The scheduled process follows this flow:

```text
Windows Task Scheduler
        ↓
Run Python Pipeline
        ↓
Request Amazon Laptop Data
        ↓
Clean and Validate Data
        ↓
Check Same-Day Duplicates
        ↓
Load New Records into MySQL
        ↓
Store Historical Snapshot
        ↓
SQL Analytical Views
        ↓
Power BI Reporting
```

## Daily Execution Process

During each scheduled execution, the pipeline:

1. Starts automatically through Windows Task Scheduler.
2. Runs the Python data pipeline.
3. Requests Amazon laptop search-result data through the API.
4. Extracts the returned product records.
5. Cleans and validates product information such as price, rating, review count, brand, and category.
6. Removes duplicate products within the same pipeline execution.
7. Checks whether valid new records are available for the current day.
8. Loads eligible records into the MySQL `amazon_data` table.
9. Stores the data as part of the historical daily snapshot collection.
10. Makes the updated data available to the SQL analytical layer and Power BI reporting model.

## Error Handling

The Python pipeline includes retry logic for temporary API failures and logs execution activity.

If the API request fails or no valid records are available, the pipeline completes without inserting invalid or duplicate records into the database.

## Relationship to the BPMN Workflow

The complete end-to-end workflow of the project, including the scheduled trigger, Python processing, validation decisions, MySQL storage, SQL analytical layer, and Power BI reporting, is documented visually in the BPMN diagram available in the [`docs`](../docs) folder.

## Automation Scope

The automation is designed to support repeated daily market snapshot collection.

The goal is to reduce manual execution and maintain a consistent historical dataset that can be used for ongoing market analysis and reporting.
