-- File: 002_create_orders_raw.sql
CREATE TABLE HEVO_ASSIGNMENT2_ORDERS_RAW (
    order_id INT,
    customer_id INT,
    product_id VARCHAR(50),
    amount NUMERIC(12,2),
    created_at TIMESTAMP,
    currency VARCHAR(10)
);




-- File: 002_insert_orders_raw.sql
INSERT INTO HEVO_ASSIGNMENT2_ORDERS_RAW (order_id, customer_id, product_id, amount, created_at, currency) VALUES
(5001, 101, 'P01', 120.00, '2025-07-10 09:00:00', 'USD'),
(5002, 102, 'P02', 80.5, '2025-07-10 09:05:00', 'usd'),
(5003, 103, NULL, 200.00, '2025-07-10 09:15:00', 'INR'),
(5004, 105, 'P99', NULL, '2025-07-10 09:20:00', NULL),
(5002, 102, 'P02', 80.50, '2025-07-10 09:05:00', 'USD'),
(5005, 106, 'P03', -50, '2025-07-10 09:25:00', 'SGD'),
(5006, 107, NULL, 300, '2025-07-11 10:00:00', 'usd'),
(5007, 108, 'P04', 500, '2025-07-11 10:15:00', 'EUR');
