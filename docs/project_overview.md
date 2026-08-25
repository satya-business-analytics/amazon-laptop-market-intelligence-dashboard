# Project Overview

## Business Problem

The Amazon laptop market contains a large number of products with different brands, prices, ratings, customer review volumes, processors, memory configurations, storage capacities, and market segments.

Because product availability and pricing can change over time, a single static dataset provides only a limited view of the market.

The objective of this project is to build an automated market intelligence pipeline that captures daily Amazon laptop search-result snapshots and transforms them into a structured analytical dataset for business analysis.

The project focuses on answering questions such as:

- Which brands currently have the highest visible product presence?
- What is the average laptop price in the captured market sample?
- How are products distributed across different price tiers?
- Which processor brands are most commonly represented?
- Which laptop segments contain the highest number of products?
- What storage configurations are most common?
- How do product prices, ratings, reviews, and other metrics vary across the captured market?
- How do selected market indicators change across daily snapshots?

---

## Project Objective

The objective of this project is to create an automated Business Analytics workflow that collects daily laptop market snapshots, cleans and stores the data, creates an analytical SQL layer, and visualizes market insights through an interactive Power BI dashboard.

The project follows the flow:

API Data Collection

↓

Python Data Cleaning and Validation

↓

MySQL Historical Storage

↓

SQL Analytical Views

↓

Power BI Data Model and DAX Measures

↓

Interactive Market Intelligence Dashboard

---

## Data Collection Approach

The project uses the OpenWeb Ninja API to collect Amazon laptop search-result data.

The Python pipeline retrieves multiple search-result pages and captures product-level information including:

- Product ID
- Product name
- Brand
- Category
- Price
- Rating
- Review count

The pipeline is configured to collect a limited number of search-result pages during each scheduled execution.

The purpose is not to capture every laptop listing available on Amazon.

Instead, the collected data represents a consistent market visibility sample that can be used to analyze visible product patterns over time.

---

## Data Cleaning and Validation

The Python pipeline performs several data preparation steps before loading records into MySQL.

These include:

- Removing duplicate products within an API execution
- Cleaning product names
- Extracting and standardizing brand names
- Cleaning currency symbols and commas from prices
- Converting price values into numeric format
- Converting ratings into numeric format
- Cleaning review counts
- Removing invalid or incomplete records
- Applying data boundary checks
- Adding daily load dates and timestamps
- Preventing duplicate product inserts for the same day

The pipeline also uses retry logic to improve reliability when API requests encounter temporary failures.

---

## Historical Data Tracking

The MySQL database stores daily product snapshots.

The table uses a composite unique constraint based on:

- `product_id`
- `load_date`

This allows the same laptop product to appear on multiple days while preventing duplicate records for the same product on the same day.

As a result, the database can support historical analysis of product prices, ratings, reviews, and other market indicators.

---

## SQL Analytical Layer

SQL views are used to create a structured analytical layer between the raw MySQL table and Power BI.

The views include:

- Clean base data
- Brand summaries
- Market share analysis
- Price tiers
- Value scores
- Social proof scoring
- Latest market snapshots
- Product price history
- Review growth
- Rating trends
- KPI summaries
- Laptop specification extraction
- Dashboard-ready laptop specifications

This structure separates raw data storage from analytical logic.

---

## Laptop Specification Analysis

Product titles are used to extract additional analytical attributes.

These include:

- Processor brand
- Processor family
- RAM capacity
- RAM type
- Storage capacity
- Storage type
- Screen size
- Display resolution
- Panel type
- GPU type
- Operating system
- Laptop segment

These derived fields allow the Power BI dashboard to analyze the market beyond basic price and rating information.

---

## Power BI Dashboard

The Power BI dashboard is organized into two primary analytical pages.

### Executive Market Overview

Provides a high-level summary of the captured laptop market.

Key insights include:

- Leading brand
- Average price
- Average rating
- Latest snapshot product volume
- Total captured historical records
- Number of snapshot days
- Brand market share
- Price tier distribution
- Processor brand distribution
- Laptop segment mix
- Most common storage capacity

### Core Business Analysis

Provides deeper product and market analysis.

Key areas include:

- Price range dispersion
- Segment-level product distribution
- Quality versus value comparison
- Social proof analysis
- Laptop segment filtering
- What-if price scenario analysis

---

## What-If Price Scenario Analysis

The dashboard includes a disconnected Price Scenario Points table.

Users can select a hypothetical price adjustment between -20% and +20%.

The scenario calculation dynamically adjusts the average price based on the currently selected laptop segment.

The scenario does not modify the original dataset.

It is used only to simulate potential price changes for analytical exploration.

---

## Automation

The Python data pipeline is designed to support scheduled execution.

Windows Task Scheduler is used to automate daily pipeline execution.

Each scheduled run:

1. Requests the latest laptop search-result data from the API.
2. Cleans and validates the extracted records.
3. Removes duplicate same-day products.
4. Adds load date and timestamp information.
5. Inserts new records into MySQL.
6. Makes the updated data available for SQL analysis and Power BI reporting.

---

## Key Business Value

The project demonstrates how a Business Analytics workflow can convert regularly collected external market data into a structured reporting system.

Instead of relying on a one-time static dataset, the project supports repeated market snapshots and historical tracking.

The final solution combines:

- API integration
- Python automation
- Data cleaning
- Data validation
- MySQL storage
- SQL analytical views
- Historical tracking
- Power BI modeling
- DAX calculations
- Interactive dashboard reporting
- Scheduled automation

The project is designed as a portfolio demonstration of an end-to-end Business Analytics workflow.
