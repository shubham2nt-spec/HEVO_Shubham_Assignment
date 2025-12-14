SELECT
    o.order_id,
    
    -- Mark missing customers as "Orphan Customer"
    COALESCE(c.email, 'Orphan Customer') AS email,
    
    o.customer_id,
    
    -- Mark missing or invalid products as "Unknown Product"
    COALESCE(p.product_name, 'Unknown Product') AS product_name,
    COALESCE(p.category, 'Unknown Product') AS category,
    COALESCE(p.status, 'Unknown Product') AS product_status,
    
    o.amount_usd,
    o.created_at
FROM hevo_assignment2_orders_raw o
LEFT JOIN hevo_assignment2_customers_raw c
    ON o.customer_id = c.customer_id
LEFT JOIN hevo_assignment2_products_raw p
    ON o.product_id = p.product_id
ORDER BY o.customer_id, o.order_id;