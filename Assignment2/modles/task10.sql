SELECT
    o.order_id,
    
    -- Customers with completely NULL records are marked Invalid, missing ones as Orphan
    COALESCE(
        CASE 
            WHEN c.email IS NULL AND c.phone IS NULL AND c.country_code IS NULL AND c.created_at IS NULL
            THEN 'Invalid Customer'
            ELSE LOWER(c.email)
        END,
        'Orphan Customer'
    ) AS email,
    
    o.customer_id,
    
    -- Handle missing products
    COALESCE(INITCAP(p.product_name), 'Unknown Product') AS product_name,
    COALESCE(INITCAP(p.category), 'Unknown Product') AS category,
    COALESCE(p.status, 'Unknown Product') AS product_status,
    
    -- Convert amounts to USD and handle negative values
    CASE 
        WHEN o.currency = 'USD' OR o.currency IS NULL THEN IFF(o.amount < 0, 0, o.amount)
        WHEN o.currency = 'INR' THEN IFF(o.amount < 0, 0, o.amount) * 0.012
        WHEN o.currency = 'SGD' THEN IFF(o.amount < 0, 0, o.amount) * 0.74
        WHEN o.currency = 'EUR' THEN IFF(o.amount < 0, 0, o.amount) * 1.1
        ELSE IFF(o.amount < 0, 0, o.amount)
    END AS amount_usd,
    
    TO_VARCHAR(o.created_at) AS created_at
FROM hevo_assignment2_orders_raw o
LEFT JOIN hevo_assignment2_customers_raw c
    ON o.customer_id = c.customer_id
LEFT JOIN hevo_assignment2_products_raw p
    ON o.product_id = p.product_id
ORDER BY o.customer_id, o.order_id;