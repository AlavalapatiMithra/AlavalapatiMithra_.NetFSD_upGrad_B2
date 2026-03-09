
--P!--
CREATE DATABASE EcommAppDb;
USE EcommAppDb;

CREATE TABLE categories (category_id INT IDENTITY(1,1) PRIMARY KEY, category_name VARCHAR(255) NOT NULL);
CREATE TABLE brands (brand_id INT IDENTITY(1,1) PRIMARY KEY, brand_name VARCHAR(255) NOT NULL);
CREATE TABLE stores (store_id INT IDENTITY(1,1) PRIMARY KEY, store_name VARCHAR(255) NOT NULL, city VARCHAR(255));
CREATE TABLE customers (customer_id INT IDENTITY(1,1) PRIMARY KEY, first_name VARCHAR(255), last_name VARCHAR(255), city VARCHAR(50));
CREATE TABLE products (
    product_id INT IDENTITY(1,1) PRIMARY KEY, 
    product_name VARCHAR(255), 
    brand_id INT REFERENCES brands(brand_id), 
    category_id INT REFERENCES categories(category_id), 
    model_year SMALLINT, 
    list_price DECIMAL(10,2)
);

-- 1. Categories
INSERT INTO categories (category_name) VALUES ('Electric Bikes'), ('Mountain Bikes'), ('Road Bikes'), ('Cruisers'), ('Children Bikes');

-- 2. Brands
INSERT INTO brands (brand_name) VALUES ('Trek'), ('Giant'), ('Specialized'), ('Cannondale'), ('Santa Cruz');

-- 3. Stores
INSERT INTO stores (store_name, city) VALUES ('City Bikes', 'New York'), ('Mountain Hub', 'Denver'), ('Beach Cruiser', 'Miami'), ('Pedal Power', 'New York'), ('Nitro Cycles', 'Austin');

-- 4. Customers
INSERT INTO customers (first_name, last_name, city) VALUES ('Alice', 'Johnson', 'New York'), ('Bob', 'Smith', 'Denver'), ('Charlie', 'Davis', 'New York'), ('Diana', 'Prince', 'Miami'), ('Edward', 'Norton', 'Austin');

-- 5. Products (Must use brand_id and category_id from 1 to 5)
INSERT INTO products (product_name, brand_id, category_id, model_year, list_price) VALUES 
('Model E1', 1, 1, 2024, 1200.00),
('Peak Climber', 2, 2, 2023, 850.00),
('Speedster Pro', 3, 3, 2024, 1500.00),
('City Glide', 4, 4, 2022, 600.00),
('Kiddo Safe', 5, 5, 2023, 300.00);

--Retrieve products with Brand and Category names

SELECT 
    p.product_name, 
    b.brand_name, 
    c.category_name, 
    p.list_price
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
JOIN categories c ON p.category_id = c.category_id;

--Retrieve all customers from a specific city
SELECT * FROM customers 
WHERE city = 'New York';

--Display total number of products in each category

SELECT 
    c.category_name, 
    COUNT(p.product_id) AS product_count
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_name;


--P2--
-- 1. Create Staffs Table (Required for Orders)
CREATE TABLE staffs (
    staff_id INT IDENTITY (1, 1) PRIMARY KEY,
    first_name VARCHAR (50) NOT NULL,
    last_name VARCHAR (50) NOT NULL,
    email VARCHAR (255) NOT NULL UNIQUE,
    store_id INT NOT NULL,
    active tinyint NOT NULL,
    FOREIGN KEY (store_id) REFERENCES stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 2. Create Orders Table
CREATE TABLE orders (
    order_id INT IDENTITY (1, 1) PRIMARY KEY,
    customer_id INT,
    order_status tinyint NOT NULL, -- 1 = Pending; 4 = Completed
    order_date DATE NOT NULL,
    required_date DATE NOT NULL,
    shipped_date DATE,
    store_id INT NOT NULL,
    staff_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers (customer_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (store_id) REFERENCES stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES staffs (staff_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

--Product Summary Report

CREATE VIEW vw_ProductInventory AS
SELECT 
    p.product_name, 
    b.brand_name, 
    c.category_name, 
    p.model_year, 
    p.list_price
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
JOIN categories c ON p.category_id = c.category_id;
GO

--Order Details Report
CREATE OR ALTER VIEW vw_OrderDetails AS
SELECT 
    o.order_id,
    CONCAT(cust.first_name, ' ', cust.last_name) AS customer_name,
    s.store_name,
    CONCAT(stf.first_name, ' ', stf.last_name) AS staff_name,
    o.order_date
FROM orders o
JOIN customers cust ON o.customer_id = cust.customer_id
JOIN stores s ON o.store_id = s.store_id
JOIN staffs stf ON o.staff_id = stf.staff_id;


--Creating Performance Indexes
-- Speed up joins between products, brands, and categories
CREATE INDEX idx_products_brand_id ON products(brand_id);
CREATE INDEX idx_products_category_id ON products(category_id);

-- Speed up searches for customers by city
CREATE INDEX idx_customers_city ON customers(city);

-- Speed up order lookups
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'orders')
BEGIN
    CREATE INDEX idx_orders_customer_id ON orders(customer_id);
    CREATE INDEX idx_orders_store_id ON orders(store_id);
END


--Testing Performance
SELECT * FROM vw_ProductInventory WHERE brand_name = 'Trek';