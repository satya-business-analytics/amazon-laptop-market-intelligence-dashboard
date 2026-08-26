# Project Documentation

This folder contains supporting documentation for the Amazon Laptop Market Intelligence Dashboard.

## Documentation Files

### [Project Overview](project_overview.md)

Provides an overview of the business problem, project objectives, data collection approach, analytical workflow, automation, and overall business value of the project.

### [Power BI Documentation](power_bi_documentation.md)

Describes the Power BI dashboard structure, report pages, KPI cards, charts, filters, data model components, and what-if price scenario analysis.

### BPMN Workflow

The project workflow is also documented using a BPMN process diagram.

The BPMN diagram provides a visual representation of the end-to-end workflow, including:

- Scheduled pipeline execution
- API data retrieval
- API response validation
- Data extraction
- Data cleaning and validation
- Duplicate checks
- MySQL data loading
- Historical snapshot storage
- SQL analytical processing
- Power BI reporting
- Error handling paths

The diagram is available in two formats:

- [`BPMN source file`](docs/Amazon Laptop Market Intelligence Workflow.drawio)
- [`BPMN workflow diagram`](amazon_laptop_market_intelligence_workflow.png)

The `.drawio` file can be opened and edited in draw.io, while the PNG provides a quick visual reference to the workflow.


### DAX Measures

The Power BI documentation also includes the DAX measures used for:

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
