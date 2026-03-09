-- P1 --
SELECT 
    CONCAT(product_name, ' (', model_year, ')') AS product_info,
    list_price,
    list_price - (
        SELECT AVG(p2.list_price) 
        FROM products p2 
        WHERE p2.category_id = p1.category_id
    ) AS price_difference
FROM 
    products p1
WHERE 
    list_price > (
        SELECT AVG(p2.list_price) 
        FROM products p2 
        WHERE p2.category_id = p1.category_id
    );

-- P2 --
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    customer_totals.total_value,
    CASE 
        WHEN customer_totals.total_value > 10000 THEN 'Premium'
        WHEN customer_totals.total_value BETWEEN 5000 AND 10000 THEN 'Regular'
        ELSE 'Basic'
    END AS customer_class
FROM customers AS c
INNER JOIN (
    SELECT o.customer_id, SUM(oi.quantity * oi.list_price) AS total_value
    FROM orders AS o
    JOIN order_items AS oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
) AS customer_totals ON c.customer_id = customer_totals.customer_id

UNION
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    0 AS total_value,
    'No Activity' AS customer_class
FROM customers AS c
LEFT JOIN orders AS o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


--P3--

SELECT 
    s.store_name,
    p.product_name,
    SUM(sales.quantity) AS total_quantity_sold,
    SUM((sales.quantity * sales.list_price) - sales.discount) AS total_revenue
FROM
(
    SELECT 
        o.store_id, 
        oi.product_id, 
        oi.quantity, 
        oi.list_price, 
        oi.discount
    FROM orders o
    INNER JOIN order_items oi 
        ON o.order_id = oi.order_id
) AS sales
INNER JOIN stores s 
    ON sales.store_id = s.store_id
INNER JOIN products p 
    ON sales.product_id = p.product_id
GROUP BY 
    s.store_name, 
    p.product_name;

--P4--

--Create the table structure 
SELECT *
INTO archived_orders
FROM orders
WHERE 1 = 0;
GO

--Allow manual insertion of IDs and specify columns
SET IDENTITY_INSERT archived_orders ON;
GO
INSERT INTO archived_orders (order_id, customer_id, order_status, order_date, required_date, shipped_date, store_id, staff_id)
SELECT order_id, customer_id, order_status, order_date, required_date, shipped_date, store_id, staff_id
FROM orders
WHERE order_status = 3
AND order_date < DATEADD(YEAR, -1, GETDATE());
GO
SET IDENTITY_INSERT archived_orders OFF;
GO
--Delete Rejected Orders older than one year
DELETE FROM orders
WHERE order_status = 3
AND order_date < DATEADD(YEAR, -1, GETDATE());
GO

SELECT customer_id
FROM orders
GROUP BY customer_id
HAVING COUNT(*) =
(
    SELECT COUNT(*)
    FROM orders o2
    WHERE o2.customer_id = orders.customer_id
    AND o2.order_status = 4
);

SELECT 
    order_id, 
    DATEDIFF(DAY, order_date, shipped_date) AS processing_delay
FROM orders;

SELECT 
    order_id, 
    order_date, 
    required_date, 
    shipped_date, 
    CASE
        WHEN shipped_date > required_date THEN 'Delayed'
        ELSE 'On Time'
    END AS delivery_status
FROM orders;
GO




