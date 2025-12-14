WITH dedup AS (
    -- Remove duplicates based on key columns
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (
                PARTITION BY order_id, customer_id, product_id
                ORDER BY created_at DESC
            ) AS rn
        FROM hevo_assignment2_orders_raw
    )
    WHERE rn = 1
),
amounts_fixed AS (
    SELECT
        order_id,
        customer_id,
        product_id,
        -- Fix negative amounts first
        CASE WHEN amount < 0 THEN 0 ELSE amount END AS amount_temp,
        created_at,
        UPPER(currency) AS currency
    FROM dedup
),
amounts_filled AS (
    SELECT
        *,
        -- Replace NULL amounts with median per customer, fallback 0
        COALESCE(
            amount_temp,
            PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY amount_temp) 
                OVER (PARTITION BY customer_id),
            0
        ) AS amount
    FROM amounts_fixed
),
amounts_usd AS (
    SELECT
        order_id,
        customer_id,
        product_id,
        amount,
        TO_VARCHAR(created_at) AS created_at,  -- fixed here
        currency,
        -- Handle NULL currency by treating as USD
        CASE 
            WHEN currency = 'USD' OR currency IS NULL THEN amount
            WHEN currency = 'INR' THEN amount * 0.012
            WHEN currency = 'SGD' THEN amount * 0.74
            WHEN currency = 'EUR' THEN amount * 1.1
            ELSE amount
        END AS amount_usd
    FROM amounts_filled
)
SELECT *
FROM amounts_usd
ORDER BY customer_id, order_id;