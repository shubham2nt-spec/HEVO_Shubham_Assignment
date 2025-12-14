WITH ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY updated_at DESC NULLS LAST
        ) AS rn
    FROM hevo_assignment2_customers_raw
),
cleaned AS (
    SELECT
        r.customer_id,
        
        -- Standardize email
        CASE
            WHEN r.email IS NULL AND r.phone IS NULL AND r.country_code IS NULL AND r.created_at IS NULL
            THEN 'Invalid Customer'
            ELSE LOWER(r.email)
        END AS email,
        
        -- Standardize phone to 10 digits
        CASE
            WHEN REGEXP_REPLACE(r.phone, '[^0-9]', '') RLIKE '^[0-9]{10}$'
            THEN REGEXP_REPLACE(r.phone, '[^0-9]', '')
            ELSE 'Unknown'
        END AS phone,
        
        -- Robust country mapping with common variations
        CASE
            WHEN UPPER(r.country_code) IN ('US', 'USA', 'UNITEDSTATES') THEN 'US'
            WHEN UPPER(r.country_code) IN ('IND', 'INDIA') THEN 'IN'
            WHEN UPPER(r.country_code) IN ('SG', 'SINGAPORE') THEN 'SG'
            ELSE 'Unknown'
        END AS country_code,
        
        -- Timestamps formatted as string
        TO_VARCHAR(COALESCE(r.created_at, TO_TIMESTAMP('1900-01-01 00:00:00'))) AS created_at,
        TO_VARCHAR(r.updated_at) AS updated_at
    FROM ranked r
    WHERE rn = 1
)
SELECT *
FROM cleaned
ORDER BY customer_id;