-- File: 003_create_products_raw.sql
CREATE TABLE HEVO_ASSIGNMENT2_PRODUCTS_RAW (
    product_id VARCHAR(50),
    product_name VARCHAR(255),
    category VARCHAR(100),
    active_flag CHAR(1)
);




-- File: 003_insert_products_raw.sql
INSERT INTO HEVO_ASSIGNMENT2_PRODUCTS_RAW (product_id, product_name, category, active_flag) VALUES
('P01', 'keyboard', 'hardware', 'Y'),
('P02', 'MOUSE', 'Hardware', 'Y'),
('P03', 'Monitor', 'Hardware', 'N'),
('P04', 'Premium Cable', 'Accessory', 'Y');
