# Amazon Laptop Market Intelligence Dashboard

An end-to-end Business Analytics project that collects Amazon laptop market data through an API, processes and stores historical snapshots in MySQL, creates an analytical SQL layer, and delivers interactive market insights through Power BI.

The project demonstrates a complete analytics workflow covering automated data collection, Python-based data processing, historical data tracking, SQL analytics, Power BI modeling, DAX calculations, and scheduled automation.

---

## Business Problem

The Amazon laptop market contains a large number of products with different brands, prices, ratings, customer review volumes, processors, memory configurations, storage capacities, and market segments.

Product availability and market information can change over time. A one-time static dataset provides only a limited view of these changes.

This project was designed to create a repeatable market intelligence workflow that captures Amazon laptop search-result snapshots and transforms them into a structured analytical dataset for business analysis.

The project helps answer questions such as:

* Which brands have the highest visible product presence?
* What is the average laptop price in the captured market?
* How are products distributed across different price tiers?
* Which processor brands are most commonly represented?
* Which laptop segments contain the highest number of products?
* What storage configurations are most common?
* How do prices, ratings, reviews, and product characteristics vary across the captured market?
* How do selected market indicators change across historical snapshots?

---

## Solution Overview

The project follows an end-to-end analytics workflow:

```text
OpenWeb Ninja API
        ↓
Python Data Pipeline
        ↓
Data Cleaning and Validation
        ↓
MySQL Historical Storage
        ↓
SQL Analytical Views
        ↓
Power BI Data Model
        ↓
DAX Measures
        ↓
Interactive Market Intelligence Dashboard
```

The workflow is also documented using a BPMN process diagram that includes automation, API validation, data validation, duplicate handling, MySQL loading, SQL processing, Power BI reporting, and error-handling paths.

---

## Project Architecture

### 1. API Data Collection

The project uses the OpenWeb Ninja API to collect Amazon laptop search-result data.

The pipeline captures product-level information including:

* Product ID
* Product name
* Brand
* Category
* Price
* Rating
* Review count

The collected data represents a market visibility sample rather than every laptop listing available on Amazon.

---

### 2. Python Data Pipeline

The Python pipeline:

* Requests Amazon laptop search-result data
* Handles temporary API failures using retry logic
* Extracts product records
* Cleans product names and categorical fields
* Converts price values into numeric format
* Converts ratings and review counts into numeric values
* Removes invalid or incomplete records
* Removes duplicate products within a pipeline execution
* Adds load dates and timestamps
* Loads cleaned records into MySQL

Environment variables and database credentials are stored locally and excluded from the repository.

---

### 3. Historical Data Storage

MySQL is used to store product snapshots over time.

The `amazon_data` table uses a composite unique constraint on:

* `product_id`
* `load_date`

This allows the same product to appear on different dates while preventing duplicate records for the same product on the same day.

The historical structure supports analysis of:

* Price changes
* Rating changes
* Review growth
* Market volume
* Product availability patterns

---

### 4. SQL Analytical Layer

SQL views separate raw data storage from analytical logic.

The analytical layer includes views for:

* Clean base data
* Brand summaries
* Market share
* Price tiers
* Value scoring
* Social proof scoring
* Latest market snapshots
* Product price history
* Review growth
* Rating trends
* KPI summaries
* Laptop specification extraction
* Dashboard-ready analytical data

Advanced SQL techniques used in the project include:

* Common Table Expressions
* Window functions
* `LAG()`
* Rolling averages
* Conditional logic using `CASE`
* Regular expression extraction
* Aggregations
* Historical comparisons

---

### 5. Laptop Specification Analysis

Additional analytical attributes are extracted from product titles.

These include:

* Processor brand
* Processor family
* RAM capacity
* RAM type
* Storage capacity
* Storage type
* Screen size
* Display resolution
* Panel type
* GPU type
* Operating system
* Laptop segment

These derived attributes allow the dashboard to analyze the laptop market beyond basic price and rating information.

---

## Power BI Dashboard

The Power BI dashboard contains two analytical pages.

### Executive Market Overview

Provides a high-level view of the captured laptop market.

Key metrics and analyses include:

* Top brand
* Top brand market share
* Average price
* Average rating
* Latest snapshot product volume
* Total captured records
* Number of snapshot days
* Brand market share
* Price tier distribution
* Processor brand distribution
* Laptop segment mix
* Most common storage capacity

### Core Business Analysis

Provides deeper product and market analysis.

Key analyses include:

* Price range dispersion
* Segment-level product distribution
* Quality versus value comparison
* Social proof analysis
* Laptop segment filtering
* What-if price scenario analysis

The project also uses:

* A calendar dimension
* A product dimension
* DAX measures
* Conditional formatting measures
* Disconnected what-if parameter tables

---

## What-If Price Scenario Analysis

The dashboard includes a disconnected Price Scenario Points table.

Users can explore hypothetical price adjustments between:

```text
-20% to +20%
```

The scenario dynamically adjusts the average price based on the selected laptop segment.

The scenario does not modify the original dataset or stored historical records.

It is used only for analytical exploration.

---

## Automation

The data pipeline is configured for scheduled execution using Windows Task Scheduler.

The automated workflow:

1. Triggers the pipeline on the scheduled interval.
2. Requests Amazon laptop data through the API.
3. Validates the API response.
4. Extracts product records.
5. Cleans and validates the data.
6. Checks for duplicate same-day records.
7. Loads new records into MySQL.
8. Stores the historical market snapshot.
9. Makes the updated data available to the SQL analytical layer and Power BI.

---

## BPMN Workflow

The end-to-end workflow is documented using BPMN.

The diagram represents the interaction between:

* Scheduled automation
* Python data processing
* API data collection
* Validation and error handling
* Duplicate checks
* MySQL storage
* SQL analytical processing
* Power BI reporting

The BPMN workflow is available in the `docs` folder in both:

* Editable `.drawio` format
* PNG format

---

## Technologies Used

* Python
* pandas
* SQLAlchemy
* MySQL
* SQL
* Power BI
* DAX
* Power Query
* Windows Task Scheduler
* OpenWeb Ninja API
* draw.io / BPMN

---

## Repository Structure

```text
amazon-laptop-market-intelligence-dashboard/
│
├── src/
│   ├── amazon_pipeline.py
│   └── README.md
│
├── sql/
│   ├── amazon_schema.sql
│   ├── amazon_views.sql
│   └── README.md
│
├── docs/
│   ├── README.md
│   ├── project_overview.md
│   ├── power_bi_documentation.md
│   ├── BPMN workflow source file
│   └── BPMN workflow diagram
│
├── Automation/
│   └── README.md
│
├── screenshots/
│   └── README.md
│
├── .env.example
├── .gitignore
├── requirements.txt
└── README.md
```

---

## Data Scope

This project uses API-based Amazon laptop search-result snapshots as a market visibility sample.

The project does not claim to track every Amazon laptop listing or guarantee that the exact same products appear in every snapshot.

Instead, the solution is designed to monitor visible market patterns related to:

* Brand presence
* Pricing
* Price tiers
* Product specifications
* Ratings
* Customer review volumes
* Laptop segments
* Historical market changes

---

## Documentation

Detailed documentation is available in the following folders:

* [`docs`](docs/) — project overview, Power BI documentation, DAX documentation, and BPMN workflow
* [`src`](src/) — Python pipeline documentation
* [`sql`](sql/) — database schema and SQL analytical views
* [`Automation`](Automation/) — scheduled pipeline automation documentation
* [`screenshots`](screenshots/) — Power BI dashboard screenshots

---

## Key Business Value

This project demonstrates how regularly collected external market data can be transformed into a structured analytics and reporting system.

Instead of relying on a one-time static dataset, the solution supports historical market tracking and repeatable analysis.

The project combines:

* API integration
* Python data processing
* Data cleaning
* Data validation
* Historical data tracking
* MySQL storage
* SQL analytical views
* Window functions
* Product specification extraction
* Power BI data modeling
* DAX calculations
* What-if analysis
* BPMN process modeling
* Scheduled automation

The project was built as an end-to-end Business Analytics portfolio project demonstrating both technical implementation and business-oriented analytical reporting.


