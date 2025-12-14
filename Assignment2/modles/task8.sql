SELECT
    product_id,
    
    -- Capitalize product names properly
    INITCAP(product_name) AS product_name,
    
    -- Title case for category names
    INITCAP(category) AS category,
    
    -- Mark inactive products as "Discontinued Product"
    CASE
        WHEN active_flag = 'N' THEN 'Discontinued Product'
        ELSE 'Active Product'
    END AS status
FROM hevo_assignment2_products_raw
ORDER BY product_id;