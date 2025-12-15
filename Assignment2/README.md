
# Hevo Exercise – Assessment II

Messy E-Commerce Orders (Post-Load Data Cleaning with Hevo Models)

## Overview
This project demonstrates an end-to-end data pipeline using PostgreSQL → Hevo → Snowflake, followed by post-load data cleaning and transformation using Hevo Models (SQL). The raw e-commerce data contained duplicates, inconsistent formats, null values, inactive records, and orphan references. The goal was to transform this raw data into a single, reliable, analytics-ready dataset.

## Architecture
PostgreSQL (Local)

```
|
|  Logical Replication (Hevo)
v
```

Snowflake (RAW Schema)

```
|
|  Hevo Models (SQL Transformations)
v
```

Snowflake (CLEAN / ANALYTICS Schema)

## Phase 1: PostgreSQL Setup
- A local PostgreSQL instance was set up using Docker.
- A database named `ecommerce` was created.
- The following raw tables were created: `customers_raw`, `orders_raw`, `products_raw`, `country_dim`.
- These tables exactly match the schemas provided in the assessment.

## Phase 2: Data Loading into PostgreSQL
- Sample data provided in the assessment was inserted into each raw table using `INSERT` statements.
- `<null>` values from the problem statement were inserted as SQL `NULL`.
- No data cleaning or transformation was performed at this stage to preserve raw data integrity.

## Phase 3: Hevo Pipeline Configuration
- Source: PostgreSQL
- Ingestion mode: Logical Replication
- All raw tables were selected for replication.
- Destination: Snowflake (Trial account via Partner Connect)
- Hevo automatically ingested the raw data into Snowflake under the `RAW` schema.

## Phase 4: Raw Data Validation in Snowflake
- Verified the following tables in Snowflake: `RAW.CUSTOMERS_RAW`, `RAW.ORDERS_RAW`, `RAW.PRODUCTS_RAW`, `RAW.COUNTRY_DIM`.
- Observed duplicate customer and order records, inconsistent country and currency formats, missing and invalid values, and orphan references across entities.

## Phase 5 & 6: Customer Deduplication and Data Fixes
**Objectives**
- Deduplicate customers.
- Standardize formats.
- Fix nulls and country inconsistencies.

**Transformations Applied**
- Deduplication: Customers were deduplicated using `customer_id`; only the most recent record per customer (based on `updated_at`) was retained.
- Email Standardization: All emails were converted to lowercase.
- Phone Number Standardization: Non-numeric characters were removed; only valid 10-digit numbers were retained; invalid or missing values were replaced with `Unknown`.
- Country Standardization: Country values (e.g., `usa`, `UnitedStates`, `IND`, `SINGAPORE`) were standardized using the `country_dim` table. All valid countries were mapped to ISO codes; unmapped values defaulted to `Unknown`.
- Null Handling: `created_at` values that were NULL were replaced with `1900-01-01`. Customers with all critical fields NULL were labeled as `Invalid Customer`.

## Phase 7: Orders Cleaning
**Transformations Applied**
- Exact duplicate orders were removed.
- Negative order amounts were replaced with `0`.
- NULL order amounts were replaced with the median transaction amount per customer (fallback to `0` if unavailable).
- Currency codes were standardized to uppercase.
- A derived column `amount_usd` was created using predefined currency conversion rates to ensure consistent monetary analysis.

## Phase 8: Products Cleaning
**Transformations Applied**
- Product names were standardized using proper capitalization.
- Product categories were converted to Title Case.
- Products marked as inactive (`active_flag = 'N'`) were labeled as `Discontinued Product`.

## Phase 9: Final Unified Dataset
The final analytics-ready dataset was created by joining cleaned customers, cleaned orders, and cleaned products.

**Special Handling**
- Orders referencing non-existent customers were retained and labeled as `Orphan Customer`.
- Orders referencing missing or invalid products were labeled as `Unknown Product`.
- All orders were preserved to maintain data completeness.

## Final Output
- Contains clean, deduplicated, and standardized data.
- Handles all edge cases defined in the assessment.
- Suitable for downstream analytics and reporting.
- Preserves orphan records with clear placeholders.

## Tools & Technologies Used
- PostgreSQL (Local source database)
- Docker
- Hevo Data (Logical Replication + Models)
- Snowflake (Data Warehouse)
- SQL (Snowflake-compatible)
