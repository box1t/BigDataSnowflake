-- scripts/01_create_tables.sql

CREATE TABLE IF NOT EXISTS public.mock_data (
    id SERIAL PRIMARY key,
	customer_first_name varchar(50) NULL,
	customer_last_name varchar(50) NULL,
	customer_age integer NULL,
	customer_email varchar(50) NULL,
	customer_country varchar(50) NULL,
	customer_postal_code varchar(50) NULL,
	customer_pet_type varchar(50) NULL,
	customer_pet_name varchar(50) NULL,
	customer_pet_breed varchar(50) NULL,
	seller_first_name varchar(50) NULL,
	seller_last_name varchar(50) NULL,
	seller_email varchar(50) NULL,
	seller_country varchar(50) NULL,
	seller_postal_code varchar(50) NULL,
	product_name varchar(50) NULL,
	product_category varchar(50) NULL,
	product_price real NULL,
	product_quantity integer NULL,
	sale_date varchar(50) NULL,
	sale_customer_id integer NULL,
	sale_seller_id integer NULL,
	sale_product_id integer NULL,
	sale_quantity integer NULL,
	sale_total_price real NULL,
	store_name varchar(50) NULL,
	store_location varchar(50) NULL,
	store_city varchar(50) NULL,
	store_state varchar(50) NULL,
	store_country varchar(50) NULL,
	store_phone varchar(50) NULL,
	store_email varchar(50) NULL,
	pet_category varchar(50) NULL,
	product_weight real NULL,
	product_color varchar(50) NULL,
	product_size varchar(50) NULL,
	product_brand varchar(50) NULL,
	product_material varchar(50) NULL,
	product_description varchar(1024) NULL,
	product_rating real NULL,
	product_reviews integer NULL,
	product_release_date varchar(50) NULL,
	product_expiry_date varchar(50) NULL,
	supplier_name varchar(50) NULL,
	supplier_contact varchar(50) NULL,
	supplier_email varchar(50) NULL,
	supplier_phone varchar(50) NULL,
	supplier_address varchar(50) NULL,
	supplier_city varchar(50) NULL,
	supplier_country varchar(50) NULL
);

CREATE TABLE IF NOT EXISTS DimCustomers (
    customer_sk SERIAL PRIMARY KEY,             
    customer_first_name VARCHAR(255) NOT NULL,
    customer_last_name VARCHAR(255) NOT NULL,
    customer_age INTEGER,
    customer_email VARCHAR(255) UNIQUE NOT NULL, 
    customer_country VARCHAR(255),
    customer_postal_code VARCHAR(50),
    customer_pet_type VARCHAR(255),
    customer_pet_name VARCHAR(255),
    customer_pet_breed VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS DimSellers (
    seller_sk SERIAL PRIMARY KEY,              
    seller_first_name VARCHAR(255) NOT NULL,
    seller_last_name VARCHAR(255) NOT NULL,
    seller_email VARCHAR(255) UNIQUE NOT NULL, 
    seller_country VARCHAR(255),
    seller_postal_code VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS DimProducts (
    product_sk SERIAL PRIMARY KEY,             
    product_name VARCHAR(255) UNIQUE NOT NULL, 
    product_category VARCHAR(255),
    product_price NUMERIC(10, 2),             
    product_weight NUMERIC(10, 2),
    product_color VARCHAR(100),
    product_size VARCHAR(100),
    product_brand VARCHAR(255),
    product_material VARCHAR(255),
    product_description TEXT,                  
    product_rating NUMERIC(3, 1),             
    product_reviews INTEGER,
    product_release_date DATE,
    product_expiry_date DATE,
    pet_category VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS DimStores (
    store_sk SERIAL PRIMARY KEY,               
    store_name VARCHAR(255) UNIQUE NOT NULL,   
    store_location VARCHAR(255),
    store_city VARCHAR(255),
    store_state VARCHAR(255),
    store_country VARCHAR(255),
    store_phone VARCHAR(50),
    store_email VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS DimSuppliers (
    supplier_sk SERIAL PRIMARY KEY,            
    supplier_name VARCHAR(255) UNIQUE NOT NULL, 
    supplier_contact VARCHAR(255),
    supplier_email VARCHAR(255),
    supplier_phone VARCHAR(50),
    supplier_address VARCHAR(255),
    supplier_city VARCHAR(255),
    supplier_country VARCHAR(255)
);


CREATE TABLE IF NOT EXISTS DimDate (
    date_sk INTEGER PRIMARY KEY,           
    full_date DATE NOT NULL UNIQUE,        
    year SMALLINT NOT NULL,                
    month SMALLINT NOT NULL,               
    day SMALLINT NOT NULL,                 
    day_of_week SMALLINT NOT NULL,         
    day_name VARCHAR(10) NOT NULL,         
    month_name VARCHAR(10) NOT NULL,       
    quarter SMALLINT NOT NULL,             
    week_of_year SMALLINT NOT NULL,        
    is_weekend BOOLEAN NOT NULL DEFAULT FALSE 
);

CREATE TABLE IF NOT EXISTS FactSales (
    sale_id SERIAL PRIMARY KEY,               
    customer_sk INTEGER NOT NULL REFERENCES DimCustomers (customer_sk), 
    seller_sk INTEGER NOT NULL REFERENCES DimSellers (seller_sk),       
    product_sk INTEGER NOT NULL REFERENCES DimProducts (product_sk),    
    store_sk INTEGER NOT NULL REFERENCES DimStores (store_sk),          
    supplier_sk INTEGER REFERENCES DimSuppliers (supplier_sk),          
    date_sk INTEGER NOT NULL REFERENCES DimDate (date_sk),              
    sale_quantity INTEGER NOT NULL,           
    sale_total_price NUMERIC(10, 2) NOT NULL  
);
