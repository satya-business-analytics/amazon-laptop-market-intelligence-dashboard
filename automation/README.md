# Automation

This folder documents the automation setup used to run the Amazon Laptop Market Intelligence data pipeline.

## Automation Objective

The project is designed to collect Amazon laptop market snapshots automatically on a scheduled basis.

Instead of manually running the Python pipeline every day, Windows Task Scheduler can be used to execute the data collection process automatically.

The automated workflow supports continuous historical data collection.

## Automated Workflow

The scheduled process follows this sequence:

Windows Task Scheduler

↓

Python Pipeline Execution

↓

OpenWeb Ninja API Request

↓

Amazon Laptop Search Result Collection

↓

Data Cleaning and Validation

↓

Duplicate Detection

↓

MySQL Database Insert

↓

Updated Historical Market Dataset

↓

Power BI Refresh

## Python Pipeline

The automated script used for the data collection process is:

```text
src/amazon_pipeline.py
