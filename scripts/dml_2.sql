
----------------------------------------

INSERT INTO DimCustomers (
    customer_first_name,
    customer_last_name,
    customer_age,
    customer_email,
    customer_country,
    customer_postal_code,
    customer_pet_type,
    customer_pet_name,
    customer_pet_breed
)
SELECT DISTINCT
    customer_first_name,
    customer_last_name,
    customer_age,
    customer_email,
    customer_country,
    customer_postal_code,
    customer_pet_type,
    customer_pet_name,
    customer_pet_breed
FROM
    mock_data
ON CONFLICT (customer_email) DO NOTHING; -- Чтобы избежать ошибок, если email уже существует (хотя при TRUNCATE это не должно произойти)

-- Проверка
SELECT COUNT(*) FROM DimCustomers;
SELECT * FROM DimCustomers LIMIT 10;
----------------------------------------

INSERT INTO DimSellers (
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country,
    seller_postal_code
)
SELECT DISTINCT
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country,
    seller_postal_code
FROM
    mock_data
ON CONFLICT (seller_email) DO NOTHING;

-- Проверка
SELECT COUNT(*) FROM DimSellers;
SELECT * FROM DimSellers LIMIT 10;
----------------------------------------

INSERT INTO DimProducts (
    product_name,
    product_category,
    product_price,
    product_weight,
    product_color,
    product_size,
    product_brand,
    product_material,
    product_description,
    product_rating,
    product_reviews,
    product_release_date,
    product_expiry_date,
    pet_category
)
SELECT DISTINCT ON (product_name)
    product_name,
    product_category,
    product_price,
    product_weight,
    product_color,
    product_size,
    product_brand,
    product_material,
    product_description,
    product_rating,
    product_reviews,
    product_release_date::DATE, 
    product_expiry_date::DATE,  
    pet_category
FROM
    mock_data
WHERE product_name IS NOT NULL
ORDER BY product_name;

-- Проверка
SELECT COUNT(*) FROM DimProducts;
SELECT * FROM DimProducts LIMIT 10;
----------------------------------------

INSERT INTO DimStores (
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email
)
SELECT DISTINCT
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email
FROM
    mock_data
WHERE store_name IS NOT NULL
ON CONFLICT (store_name) DO NOTHING;

-- Проверка
SELECT COUNT(*) FROM DimStores;
SELECT * FROM DimStores LIMIT 10;
----------------------------------------

INSERT INTO DimSuppliers (
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
)
SELECT DISTINCT
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
FROM
    mock_data
WHERE supplier_name IS NOT NULL
ON CONFLICT (supplier_name) DO NOTHING;

-- Проверка
SELECT COUNT(*) FROM DimSuppliers;
SELECT * FROM DimSuppliers LIMIT 10;
----------------------------------------
INSERT INTO DimDate (
    date_sk,
    full_date,
    year,
    month,
    day,
    day_of_week,
    day_name,
    month_name,
    quarter,
    week_of_year,
    is_weekend
)
SELECT DISTINCT
    TO_CHAR(md.sale_date::DATE, 'YYYYMMDD')::INTEGER AS date_sk, 
    md.sale_date::DATE AS full_date,                            
    EXTRACT(YEAR FROM md.sale_date::DATE) AS year,              
    EXTRACT(MONTH FROM md.sale_date::DATE) AS month,            
    EXTRACT(DAY FROM md.sale_date::DATE) AS day,                
    EXTRACT(DOW FROM md.sale_date::DATE) AS day_of_week,        
    TO_CHAR(md.sale_date::DATE, 'Day') AS day_name,             
    TO_CHAR(md.sale_date::DATE, 'Month') AS month_name,         
    EXTRACT(QUARTER FROM md.sale_date::DATE) AS quarter,        
    EXTRACT(WEEK FROM md.sale_date::DATE) AS week_of_year,      
    CASE WHEN EXTRACT(DOW FROM md.sale_date::DATE) IN (0, 6) THEN TRUE ELSE FALSE END AS is_weekend 
FROM
    mock_data md
WHERE
    md.sale_date IS NOT NULL
ON CONFLICT (full_date) DO NOTHING;

-- Проверка
SELECT COUNT(*) FROM DimDate;
SELECT * FROM DimDate ORDER BY full_date LIMIT 10;
----------------------------------------
INSERT INTO FactSales (
    customer_sk,
    seller_sk,
    product_sk,
    store_sk,
    supplier_sk,
    date_sk,
    sale_quantity,
    sale_total_price
)
SELECT
    dc.customer_sk,
    ds.seller_sk,
    dp.product_sk,
    dsh.store_sk,
    dsup.supplier_sk,
    dd.date_sk,
    md.sale_quantity,
    md.sale_total_price
FROM
    mock_data md
JOIN
    DimCustomers dc ON md.customer_email = dc.customer_email
JOIN
    DimSellers ds ON md.seller_email = ds.seller_email
JOIN
    DimProducts dp ON md.product_name = dp.product_name
JOIN
    DimStores dsh ON md.store_name = dsh.store_name
LEFT JOIN
    DimSuppliers dsup ON md.supplier_name = dsup.supplier_name
JOIN
    DimDate dd ON md.sale_date::DATE = dd.full_date;

-- Проверка (можно выполнить сразу после INSERT)
SELECT COUNT(*) FROM FactSales;
SELECT * FROM FactSales LIMIT 10;

-- Проверка
SELECT COUNT(*) FROM FactSales;
SELECT * FROM FactSales LIMIT 10;

-- Доп проверки
SELECT COUNT(md.*)
FROM mock_data md
LEFT JOIN DimCustomers dc ON md.customer_email = dc.customer_email
LEFT JOIN DimSellers ds ON md.seller_email = ds.seller_email;


SELECT COUNT(md.*)
FROM mock_data md
LEFT JOIN DimCustomers dc ON md.customer_email = dc.customer_email
LEFT JOIN DimSellers ds ON md.seller_email = ds.seller_email
LEFT JOIN DimProducts dp ON md.product_name = dp.product_name;


