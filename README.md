# Hevo Data Assessment – End-to-End Implementation & Issue Resolution

Assignment completed by Shubham Sharma for interview rounds of HEVO

## 1. Overview

This assessment demonstrates the complete setup of a data pipeline using Hevo Data, with PostgreSQL as the source and Snowflake as the destination. The pipeline leverages logical replication to stream data from PostgreSQL into Snowflake in near real time.

The implementation also includes data transformations using Hevo to:

- Derive a username field from customer email addresses
- Convert order statuses into event-based records (order_events)

The project highlights real-world challenges such as containerized databases, data quality issues, network exposure, and transformation errors—and documents how each was resolved.

## 2. Snowflake Setup

A Snowflake free trial account was created using Snowflake's official signup process.

**Steps performed:**

- Logged into Snowflake
- Created a warehouse, database, and schema
- Enabled Partner Connect

Snowflake serves as the final destination for all ingested and transformed data.

## 3. Hevo Account Setup (via Snowflake Partner Connect)

Hevo was provisioned directly using Snowflake Partner Connect, which:

- Automatically connected Snowflake as the destination
- Eliminated manual credential configuration
- Ensured secure connectivity

Hevo's dashboard was used to manage pipelines, transformations, and monitoring.

## 4. PostgreSQL Setup Using Docker

PostgreSQL was deployed locally using Docker to ensure isolation and reproducibility.

**Container Details:**
- Database: `hevo_db`
- Username: `postgres`
- Port: `5432`
- Image: `postgres:14`

Docker allowed PostgreSQL to run independently from the host system.

## 5. Database Schema Creation

Three tables were created in PostgreSQL.

### 5.1 Customers Table

```sql
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    address JSONB
);
```

### 5.2 Orders Table

```sql
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(id),
    status VARCHAR(50)
);
```

### 5.3 Feedback Table

```sql
CREATE TABLE feedback (
    id SERIAL PRIMARY KEY,
    order_id INT UNIQUE REFERENCES orders(id),
    feedback_comment TEXT,
    rating INT
);
```

**Note:** SQL scripts are available in the `SQL/` directory:
- `001_create_customers.sql`
- `002_create_orders.sql`
- `003_create_feedback.sql`

## 6. Data Loading Challenges & Solutions

### 6.1 CSV Files Not Accessible Inside Docker Container

**Problem:**

CSV files were cloned locally from GitHub, but PostgreSQL was running inside a Docker container. PostgreSQL could not access local filesystem files.

**Solution:**

CSV files were copied into the container using `docker cp`:

```bash
docker cp customers.csv hevo-postgres:/var/lib/postgresql/data/
docker cp orders.csv hevo-postgres:/var/lib/postgresql/data/
docker cp feedback.csv hevo-postgres:/var/lib/postgresql/data/
```

Once copied, data was loaded using the `COPY` command.

### 6.2 Duplicate Data Error in Orders Table

**Problem:**

The orders.csv file contained duplicate records, causing failures due to the UNIQUE constraint on the orders table.

**Solution:**

A temporary staging table was created:

```sql
CREATE TABLE orders_temp (
    id INT,
    customer_id INT,
    status VARCHAR(50)
);
```

Data was loaded into the temp table and then deduplicated:

```sql
INSERT INTO orders
SELECT DISTINCT id, customer_id, status
FROM orders_temp;
```

This ensured data integrity and successful ingestion.

## 7. Enabling Logical Replication in PostgreSQL

### 7.1 Issue Encountered

Hevo pipeline creation failed with:

```
Unable to set up logical replication
```

### 7.2 Configuration Fix

PostgreSQL configuration was updated:

**postgresql.conf:**
```
wal_level = logical
max_replication_slots = 4
max_wal_senders = 4
```

**pg_hba.conf:**
```
host replication postgres 0.0.0.0/0 md5
```

The container was restarted, and verification confirmed logical replication was enabled.

## 8. Exposing PostgreSQL to Hevo Using ngrok

**Problem:**

Hevo could not connect to a locally running PostgreSQL instance.

**Solution:**

ngrok (free tier) was used to expose PostgreSQL over the internet:

```bash
ngrok tcp 5432
```

The generated hostname and port were used in Hevo's PostgreSQL source configuration.

This established connectivity:

```
PostgreSQL (Docker) → ngrok → Hevo
```

## 9. Hevo Pipeline Configuration

### 9.1 Source

- PostgreSQL via ngrok
- Ingestion Mode: Logical Replication

### 9.2 Destination

- Snowflake (via Partner Connect)
- Selected warehouse, database, and schema

Upon activation, tables automatically appeared in Snowflake.

## 10. Transformation – Customers → Username

**Objective:**

Create a derived column `username` from customer email addresses.

**Example:**
- `jane.doe@gmail.com` → `jane.doe`

**Transformation Logic:**

```
SPLIT(email, '@')[0]
```

This Snowflake-compatible expression was added as a Derived Column in Hevo.

## 11. Transformation – Orders → Order Events

**Objective:**

Convert order status values into event-based records.

| Order Status | Event Type |
|-------------|------------|
| placed | order_placed |
| shipped | order_shipped |
| delivered | order_delivered |
| cancelled | order_cancelled |

**Logic Used:**

```sql
CASE
  WHEN status = 'placed' THEN 'order_placed'
  WHEN status = 'shipped' THEN 'order_shipped'
  WHEN status = 'delivered' THEN 'order_delivered'
  WHEN status = 'cancelled' THEN 'order_cancelled'
END
```

**Note:** Transformation scripts are available in `transformationScripts/hevo.py`

## 12. Transformation Errors & Fix

**Problem:**

Initial transformation logic:

- Updated incorrect tables
- Did not follow Hevo's event-based transformation model
- Resulted in missing data in Snowflake

**Solution:**

Hevo documentation was referenced:

- https://docs.hevodata.com/pipelines/transformations/python-transfm/event-object/

Transformations were rewritten to align with Hevo's event object structure. After this:

- Data appeared correctly in Snowflake
- Event tables populated as expected

## 13. Snowflake Validation

### Row Count Checks

```sql
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_events;
```

### Username Validation

```sql
SELECT email, username FROM customers LIMIT 10;
```

### Event Validation

```sql
SELECT event_type, COUNT(*)
FROM order_events
GROUP BY event_type;
```

All results matched expectations.

## 14. Summary of Issues & Resolutions

| Issue | Resolution |
|-------|------------|
| CSV access issue | Copied files into Docker container |
| Duplicate orders | Used temp table and deduplication |
| Local DB connectivity | Exposed DB using ngrok |
| Logical replication error | Updated PostgreSQL config |
| Transformation errors | Fixed using Hevo documentation |

## 15. Security & Best Practices

- No credentials committed to GitHub
- ngrok used only for development
- Logical replication configured correctly
- Snowflake roles managed securely

## 16. Deliverables

- ✅ PostgreSQL DDL scripts (`SQL/` directory)
- ✅ CSV files / CSV repo link
- ✅ Hevo transformation logic (`transformationScripts/` directory)
- ✅ Snowflake validation queries
- ✅ README documentation
- ✅ Loom walkthrough video

## 17. Final Outcome

This project successfully demonstrates:

- End-to-end data pipeline creation
- Logical replication in PostgreSQL
- Secure cloud ingestion using Hevo
- SQL-based transformations
- Real-world troubleshooting and resolution

The solution fully satisfies Hevo Assessment requirements and reflects production-grade data engineering practices.

## Project Structure

```
HEVO_Shubham_Assignment/
├── README.md                    # This file
├── csv.txt                      # CSV data files reference
├── SQL/                         # Database schema scripts
│   ├── 001_create_customers.sql
│   ├── 002_create_orders.sql
│   └── 003_create_feedback.sql
└── transformationScripts/       # Hevo transformation scripts
    ├── hevo.py                  # Python transformation logic
    └── Screenshot From 2025-12-14 22-58-18.png
```

## Getting Started

1. **Set up PostgreSQL using Docker:**
   ```bash
   docker run --name hevo-postgres -e POSTGRES_PASSWORD=yourpassword -p 5432:5432 -d postgres:14
   ```

2. **Create database schema:**
   - Execute SQL scripts in the `SQL/` directory in order

3. **Load data:**
   - Copy CSV files into the Docker container
   - Use `COPY` command to load data

4. **Configure PostgreSQL for logical replication:**
   - Update `postgresql.conf` and `pg_hba.conf` as documented

5. **Expose PostgreSQL using ngrok:**
   ```bash
   ngrok tcp 5432
   ```

6. **Set up Hevo pipeline:**
   - Connect PostgreSQL source via ngrok
   - Connect Snowflake destination
   - Configure transformations

7. **Validate in Snowflake:**
   - Run validation queries to verify data integrity

## Additional Resources

- [Hevo Data Documentation](https://docs.hevodata.com/)
- [PostgreSQL Logical Replication](https://www.postgresql.org/docs/current/logical-replication.html)
- [Snowflake Documentation](https://docs.snowflake.com/)
README.md
Displaying README.md.
