-- scripts/04_tables_analysis.sql

SELECT COUNT(*) FROM DimCustomers;
SELECT * FROM DimCustomers LIMIT 10;
----------------------------------


SELECT COUNT(*) FROM DimSellers;
SELECT * FROM DimSellers LIMIT 10;
----------------------------------

SELECT COUNT(*) FROM DimProducts;
SELECT * FROM DimProducts LIMIT 10;
----------------------------------

SELECT COUNT(*) FROM DimStores;
SELECT * FROM DimStores LIMIT 10;
----------------------------------

SELECT COUNT(*) FROM DimSuppliers;
SELECT * FROM DimSuppliers LIMIT 10;

----------------------------------

SELECT COUNT(*) FROM DimDate;
SELECT * FROM DimDate ORDER BY full_date LIMIT 10;

----------------------------------

SELECT COUNT(*) FROM FactSales;
SELECT * FROM FactSales LIMIT 10;


SELECT COUNT(md.*)
FROM mock_data md
LEFT JOIN DimCustomers dc ON md.customer_email = dc.customer_email
LEFT JOIN DimSellers ds ON md.seller_email = ds.seller_email;


SELECT COUNT(md.*)
FROM mock_data md
LEFT JOIN DimCustomers dc ON md.customer_email = dc.customer_email
LEFT JOIN DimSellers ds ON md.seller_email = ds.seller_email
LEFT JOIN DimProducts dp ON md.product_name = dp.product_name;


