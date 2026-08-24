# Power BI Dashboard Documentation

## Overview

The Power BI dashboard is the reporting and visualization layer of the Amazon Laptop Market Intelligence project.

Data is collected through the Python pipeline, stored in MySQL, transformed through SQL analytical views, and loaded into Power BI for business analysis.

The dashboard contains two primary report pages:

1. Executive Market Overview
2. Core Business Analysis

---

# Power BI Data Model

The Power BI model uses analytical datasets imported from MySQL SQL views.

Key source views include:

- `vw_clean_amazon`
- `vw_laptop_specs_dashboard`
- `vw_social_proof`

Additional Power BI tables were created to support filtering, analysis, and scenario modeling.

These include:

- `Dim_Products`
- `Dim_Calendar`
- `Price Scenario Points`

---

# Dim_Products

`Dim_Products` is used as a product dimension table within the Power BI model.

It supports product-level analysis and helps organize product-related attributes separately from analytical and reporting calculations.

---

# Dim_Calendar

`Dim_Calendar` is used as the calendar/date dimension in the Power BI model.

It supports date-based analysis and enables consistent reporting across daily market snapshots.

The table is connected to the snapshot date fields used for historical tracking.

---

# Price Scenario Points

`Price Scenario Points` is a disconnected scenario table used for what-if price analysis.

The table provides scenario values ranging from negative to positive price changes.

The selected scenario value is used by DAX measures to calculate a hypothetical average price.

This scenario does not modify the underlying dataset or directly filter the dashboard data.

Instead, it dynamically changes the scenario calculation based on the selected percentage.

---

# Dashboard Pages

## Page 1 — Executive Market Overview

The Executive Market Overview provides a high-level summary of the captured Amazon laptop market.

Key KPIs include:

- Top Brand Leader
- Average Price
- Average Rating
- Latest Snapshot Products
- Total Captured Records
- Snapshot Days

Key visualizations include:

- Top Brand Market Share
- Price Tier Distribution
- Processor Brand Distribution
- Laptop Segment Mix

Additional insight card:

- Top Storage Capacity

The Top Storage Capacity card identifies the most common storage tier among the currently selected products.

The percentage displayed beside the storage capacity represents the share of valid-storage products that belong to the most common storage tier.

For example:

`512 GB | 74.1%`

means that 512 GB is the most common storage capacity and represents 74.1% of the products with valid storage information in the current filter context.

A Laptop Segment slicer allows users to filter the dashboard by laptop category.

---

## Page 2 — Core Business Analysis

The Core Business Analysis page provides deeper analysis of product pricing, product segments, quality, and social proof.

Key visualizations include:

- Price Range Dispersion
- Quality vs Value Matrix
- Segment Health by Product Count
- Social Proof Integrity Analysis

Interactive controls include:

- Laptop Segment slicer
- Price Scenario slicer

The Price Scenario slicer allows users to model hypothetical percentage changes to the average price without changing the underlying data.
