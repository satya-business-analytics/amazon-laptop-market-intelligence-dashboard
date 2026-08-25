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

# DAX Measures

The Power BI dashboard uses DAX measures for KPI calculations, market analysis, display formatting, conditional formatting, and what-if price scenario analysis.

The measures are grouped below according to their business purpose.

## Core KPI Measures

### Avg Price KPI

```DAX
Avg price KPI =
AVERAGE(vw_laptop_specs_dashboard[price])
```

Calculates the average laptop price for the products currently available in the filter context.

---

### Avg Rating KPI

```DAX
Avg Rating KPI =
AVERAGE(vw_laptop_specs_dashboard[rating])
```

Calculates the average product rating for the currently selected products.

---

### Product Count

```DAX
Product Count =
DISTINCTCOUNT(vw_laptop_specs_dashboard[product_id])
```

Calculates the number of unique products in the current filter context.

This measure is reused across multiple visuals, including brand share, price tier distribution, and segment analysis.

---

### Laptop Segment Product Count

```DAX
Laptop Segment Product Count =
COUNTROWS(vw_laptop_specs_dashboard)
```

Calculates the number of product records available for laptop segment analysis.

---

### Total Captured Records

```DAX
Total Captured Records =
COUNTROWS('vw_clean_amazon')
```

Calculates the total number of records captured across all historical market snapshots.

Unlike `Product Count`, this measure counts all stored records rather than unique products.

---

### Snapshot Days

```DAX
Snapshot Days =
DISTINCTCOUNT('vw_clean_amazon'[load_date])
```

Calculates the number of unique dates for which market snapshots have been captured.

---

## Brand Analysis Measures

### Brand Share %

```DAX
Brand Share % =
DIVIDE(
    [Product Count],
    CALCULATE(
        [Product Count],
        ALLSELECTED(vw_laptop_specs_dashboard[brand])
    )
) * 100
```

Calculates the percentage share of each brand relative to the total number of products visible in the current filter selection.

This measure is used in the Top Brand Market Share chart.

---

### Top Brand

```DAX
Top Brand =
VAR TopBrandTable =
    TOPN(
        1,
        ADDCOLUMNS(
            ALLSELECTED(vw_laptop_specs_dashboard[brand]),
            "BrandProducts", [Product Count]
        ),
        [BrandProducts],
        DESC,
        vw_laptop_specs_dashboard[brand],
        ASC
    )

RETURN
    CONCATENATEX(
        TopBrandTable,
        vw_laptop_specs_dashboard[brand],
        ", "
    )
```

Identifies the brand with the highest number of products within the current filter context.

`TOPN` selects the highest-ranked brand based on product count.

---

### Top Brand Share %

```DAX
Top Brand Share % =
VAR TopBrandTable =
    TOPN(
        1,
        ADDCOLUMNS(
            ALLSELECTED(vw_laptop_specs_dashboard[brand]),
            "BrandShare", [Brand Share %]
        ),
        [BrandShare],
        DESC,
        vw_laptop_specs_dashboard[brand],
        ASC
    )

RETURN
    MAXX(TopBrandTable, [BrandShare])
```

Calculates the market share percentage of the top-ranked brand within the current filter context.

---

### Top Brand Share Display

```DAX
Top Brand Share Display =
FORMAT([Top Brand Share %], "0.0") & "%"
```

Formats the Top Brand Share percentage as display text.

---

### Top Brand Share Latest

```DAX
Top Brand Share Latest =
VAR LatestDate =
    CALCULATE(
        MAX('vw_clean_amazon'[load_date]),
        ALL('vw_clean_amazon')
    )

VAR BrandTable =
    SUMMARIZE(
        FILTER(
            ALL('vw_clean_amazon'),
            'vw_clean_amazon'[load_date] = LatestDate
        ),
        'vw_clean_amazon'[brand],
        "ProductCount",
            DISTINCTCOUNT('vw_clean_amazon'[product_id])
    )

VAR TopBrand =
    TOPN(
        1,
        BrandTable,
        [ProductCount],
        DESC
    )

VAR BrandCount =
    MAXX(TopBrand, [ProductCount])

VAR TotalCount =
    CALCULATE(
        DISTINCTCOUNT('vw_clean_amazon'[product_id]),
        'vw_clean_amazon'[load_date] = LatestDate
    )

RETURN
    DIVIDE(BrandCount, TotalCount)
```

Calculates the market share of the leading brand in the most recent market snapshot.

This measure uses the latest available `load_date` from the historical dataset.

---

### Top Brand Leader Display

```DAX
Top Brand Leader Display =
[Top Brand] & " | " &
FORMAT([Top Brand Share Latest], "0.0%")
```

Combines the top brand name and its latest market share into a single display value.

Example:

`Lenovo | 42.5%`

This measure is used in the Top Brand Leader KPI card.

---

## Latest Snapshot Measures

### Market Volume Latest

```DAX
Market Volume Latest =
VAR LatestDate =
    CALCULATE(
        MAX('vw_clean_amazon'[load_date]),
        ALL('vw_clean_amazon')
    )

RETURN
    CALCULATE(
        DISTINCTCOUNT('vw_clean_amazon'[product_id]),
        'vw_clean_amazon'[load_date] = LatestDate
    )
```

Calculates the number of unique products captured in the most recent market snapshot.

This measure is used in the Latest Snapshot Products KPI card.

---

## Display Measures

### Avg Price Display

```DAX
Avg Price Display =
"₹" &
FORMAT([Avg price KPI] / 1000, "0.00") &
"K"
```

Formats the average price KPI into a shortened currency display.

For example:

`₹65.50K`

---

### Top Brand Share Display

```DAX
Top Brand Share Display =
FORMAT([Top Brand Share %], "0.0") & "%"
```

Formats the calculated top brand share as a percentage display value.

---

### Top Storage Capacity Display

```DAX
Top Storage Capacity Display =
VAR _StorageSummary =
    FILTER(
        SUMMARIZE(
            ALLSELECTED('vw_laptop_specs_dashboard'),
            'vw_laptop_specs_dashboard'[storage_tier],
            "Products",
                DISTINCTCOUNT(
                    'vw_laptop_specs_dashboard'[product_id]
                )
        ),
        NOT ISBLANK(
            'vw_laptop_specs_dashboard'[storage_tier]
        )
            &&
            'vw_laptop_specs_dashboard'[storage_tier]
                <> "Unknown"
    )

VAR _TopRow =
    TOPN(
        1,
        _StorageSummary,
        [Products],
        DESC,
        'vw_laptop_specs_dashboard'[storage_tier],
        ASC
    )

VAR _TopStorage =
    CONCATENATEX(
        _TopRow,
        'vw_laptop_specs_dashboard'[storage_tier],
        ""
    )

VAR _TopProducts =
    MAXX(
        _TopRow,
        [Products]
    )

VAR _TotalProducts =
    SUMX(
        _StorageSummary,
        [Products]
    )

RETURN
    IF(
        ISBLANK(_TopStorage),
        "No storage data",
        _TopStorage &
        " | " &
        FORMAT(
            DIVIDE(
                _TopProducts,
                _TotalProducts
            ),
            "0.0%"
        )
    )
```

Identifies the most common storage tier among the currently selected products.

The percentage represents the share of valid-storage products belonging to the most common storage tier.

For example:

`512 GB | 74.1%`

means that 512 GB is the most common storage capacity and represents 74.1% of products with valid storage information in the current filter context.

---

## Conditional Formatting Measures

These measures return color codes used for dynamic border formatting on KPI cards.

### Avg Price Border Color

```DAX
Avg Price Border Color =
VAR PriceValue = [Avg price KPI]

RETURN
    SWITCH(
        TRUE(),
        ISBLANK(PriceValue), "#334155",
        PriceValue >= 100000, "#EF4444",
        PriceValue >= 60000, "#F59E0B",
        "#22C55E"
    )
```

Returns a border color based on the average price level.

* Green: below ₹60,000
* Orange: ₹60,000 to ₹99,999
* Red: ₹100,000 or above

---

### Avg Rating Border Color

```DAX
Avg Rating Border Color =
VAR RatingValue = [Avg Rating KPI]

RETURN
    SWITCH(
        TRUE(),
        ISBLANK(RatingValue), "#334155",
        RatingValue >= 3.80, "#22C55E",
        RatingValue >= 3.50, "#F59E0B",
        "#EF4444"
    )
```

Returns a border color based on the average product rating.

* Green: rating of 3.80 or higher
* Orange: rating from 3.50 to 3.79
* Red: rating below 3.50

---

### Market Volume Border Color

```DAX
Market Volume Border Color =
VAR VolumeValue = [Market Volume Latest]

RETURN
    SWITCH(
        TRUE(),
        ISBLANK(VolumeValue), "#334155",
        VolumeValue >= 75, "#22C55E",
        VolumeValue >= 25, "#F59E0B",
        "#EF4444"
    )
```

Returns a border color based on the number of unique products captured in the latest snapshot.

---

### Top Brand Leader Border Color

```DAX
Top Brand Leader Border Color =
VAR ShareValue = [Top Brand Share Latest]

RETURN
    SWITCH(
        TRUE(),
        ShareValue <= 0.35, "#22C55E",
        ShareValue <= 0.50, "#FF9900",
        "#EF4444"
    )
```

Returns a border color based on the market concentration of the leading brand.

A higher concentration results in a more prominent warning color.

---

### Scenario Border Color

```DAX
Scenario Border Color =
VAR ScenarioPoints = [Scenario Points Check]

RETURN
    SWITCH(
        TRUE(),
        ScenarioPoints < 0, "#22C55E",
        ScenarioPoints = 0, "#FF9900",
        ScenarioPoints > 0, "#EF4444",
        "#FF9900"
    )
```

Returns a color based on the selected price scenario.

* Green: negative price scenario
* Orange: no price change
* Red: positive price scenario

---

## What-If Price Scenario Measures

The Power BI dashboard includes a disconnected Price Scenario Points table that allows users to simulate price changes between -20% and +20%.

The scenario selection does not modify the underlying dataset. Instead, it dynamically calculates a hypothetical average price.

### Scenario Points Check

```DAX
Scenario Points Check =
SELECTEDVALUE(
    'Price Scenario Points '[Price Scenario Points ],
    0
)
```

Retrieves the percentage currently selected in the Price Scenario Points slicer.

If no scenario value is selected, the measure returns 0.

---

### Scenario Avg Price Display

```DAX
Scenario Avg Price Display =
VAR ScenarioPoints =
    SELECTEDVALUE(
        'Price Scenario Points '[Price Scenario Points ],
        0
    )

VAR ScenarioPrice =
    [Avg price KPI] *
    (
        1 +
        DIVIDE(ScenarioPoints, 100)
    )

RETURN
    "₹" &
    FORMAT(
        DIVIDE(ScenarioPrice, 1000),
        "0.00"
    ) &
    "K"
```

Calculates a hypothetical average laptop price based on the selected scenario percentage.

For example, if the average price is ₹60,000 and the selected scenario is +10%, the calculated scenario price becomes approximately ₹66,000.

The result responds to the current laptop segment filter because it uses `Avg price KPI` as the starting value.

---

## Measure Usage Summary

The DAX layer supports four main dashboard functions:

1. **Business KPIs** — calculates average price, average rating, product counts, snapshot volume, and data collection duration.

2. **Market Analysis** — calculates brand market share, identifies the leading brand, and analyzes the most recent market snapshot.

3. **Dynamic Presentation** — formats KPI values and generates conditional formatting colors based on business thresholds.

4. **What-If Analysis** — allows users to simulate hypothetical price changes between -20% and +20% without modifying the underlying data.
