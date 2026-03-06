-- P1 --
SELECT 
    customers.first_name, 
    customers.last_name, 
    orders.order_id, 
    orders.order_date, 
    orders.order_status
FROM 
    customers, 
    orders
WHERE 
    customers.customer_id = orders.customer_id
    AND (orders.order_status = 1 OR orders.order_status = 4)
ORDER BY 
    orders.order_date DESC;

-- P2 --

SELECT 
    p.product_name, 
    b.brand_name, 
    c.category_name, 
    p.model_year, 
    p.list_price
FROM 
    products p, 
    brands b, 
    categories c
WHERE 
    p.brand_id = b.brand_id         
    AND p.category_id = c.category_id 
    AND p.list_price > 500             
ORDER BY 
    p.list_price ASC; 
    
-- P3 --

SELECT 
    s.store_name,
    SUM(oi.quantity * oi.list_price) AS total_sales
FROM
    stores AS s
INNER JOIN 
    orders AS o ON s.store_id = o.store_id
INNER JOIN
    order_items AS oi ON o.order_id = oi.order_id
WHERE 
    o.order_status = 4
GROUP BY 
    s.store_name
ORDER BY
    total_sales DESC;

-- P4 --
SELECT 
    p.product_name, 
    s.store_name, 
    st.quantity AS available_stock, 
    SUM(oi.quantity) AS total_quantity_sold
FROM 
    products AS p
INNER JOIN 
    stocks AS st ON p.product_id = st.product_id
INNER JOIN 
    stores AS s ON st.store_id = s.store_id
LEFT JOIN 
    order_items AS oi ON p.product_id = oi.product_id
GROUP BY 
    p.product_name, 
    s.store_name,
     st.quantity
ORDER BY 
    p.product_name ASC;


