-- File: 004_create_country_dim.sql
CREATE TABLE HEVO_ASSIGNMENT2_COUNTRY_DIM (
    country_name VARCHAR(100),
    iso_code VARCHAR(10)
);


-- File: 004_insert_country_dim.sql
INSERT INTO HEVO_ASSIGNMENT2_COUNTRY_DIM (country_name, iso_code) VALUES
('United States', 'US'),
('India', 'IN'),
('Singapore', 'SG'),
('Unknown', NULL);
