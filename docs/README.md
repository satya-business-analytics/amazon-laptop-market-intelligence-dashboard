# Project Documentation

This folder contains supporting documentation for the Amazon Laptop Market Intelligence Dashboard.

## Documentation Files

### [Project Overview](project_overview.md)

Provides an overview of the business problem, project objectives, data collection approach, analytical workflow, automation, and overall business value of the project.

### [Power BI Documentation](power_bi_documentation.md)

Describes the Power BI dashboard structure, report pages, KPI cards, charts, filters, data model components, and what-if price scenario analysis.

### [DAX Measures](dax_measures.md)

Documents the DAX measures used for:

- KPI calculations
- Product and market analysis
- Display formatting
- Conditional formatting
- Brand share calculations
- Latest snapshot calculations
- What-if price scenario analysis

## Related Project Components

Other technical components are documented in their respective repository folders:

- [`src`](../src/) — Python ETL pipeline
- [`sql`](../sql/) — MySQL schema and analytical SQL views
- [`Automation`](../Automation/) — scheduled pipeline automation documentation

## Project Workflow

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
