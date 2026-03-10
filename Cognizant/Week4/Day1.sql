--P1--
--1. Scalar Function,Calculate total price after discount--

CREATE FUNCTION fn_CalculateDiscountedPrice
(
    @quantity INT,
    @list_price DECIMAL(10,2),
    @discount DECIMAL(4,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN

    DECLARE @total DECIMAL(10,2)

    SET @total = (@quantity * @list_price) -
                 (@quantity * @list_price * ISNULL(@discount,0))

    RETURN @total

END

--2. Stored Procedure, Total sales amount per store--

CREATE PROCEDURE sp_TotalSalesPerStore
AS
BEGIN

    SELECT 
        s.store_name,

        SUM(
            dbo.fn_CalculateDiscountedPrice(
                oi.quantity,
                oi.list_price,
                oi.discount
            )
        ) AS total_sales

    FROM stores s

    JOIN orders o
        ON s.store_id = o.store_id

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY s.store_name

    ORDER BY total_sales DESC

END

--3. Stored Procedure, Retrieve orders by date range--

CREATE PROCEDURE sp_GetOrdersByDateRange
(
    @start_date DATE,
    @end_date DATE
)
AS
BEGIN

    SELECT 
        o.order_id,
        c.first_name,
        c.last_name,
        o.order_date,
        o.order_status,
        s.store_name

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id

    JOIN stores s
        ON o.store_id = s.store_id

    WHERE o.order_date 
        BETWEEN @start_date AND @end_date

    ORDER BY o.order_date

END

--4. Table-Valued Function, Return Top 5 selling products--

CREATE FUNCTION fn_Top5SellingProducts()
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 5

        p.product_name,
        SUM(oi.quantity) AS total_quantity_sold

    FROM order_items oi

    JOIN products p
        ON oi.product_id = p.product_id

    GROUP BY p.product_name

    ORDER BY total_quantity_sold DESC
)


--Example Execution--

-- Run procedure: total sales per store
EXEC sp_TotalSalesPerStore

-- Run procedure: orders between two dates
EXEC sp_GetOrdersByDateRange '2016-01-01','2016-12-31'


-- Use scalar function
SELECT 
    dbo.fn_CalculateDiscountedPrice(2, 500, 0.10) 
    AS discounted_price


-- Use table-valued function
SELECT * 
FROM dbo.fn_Top5SellingProducts()


--P2--

--Trigger: Auto Update Stock After Order Item Insert--

CREATE TRIGGER trg_UpdateStockAfterOrder
ON order_items
AFTER INSERT
AS
BEGIN

    SET NOCOUNT ON;

    BEGIN TRY

        --Check if stock is sufficient--

        IF EXISTS (
            SELECT 1
            FROM inserted i
            JOIN orders o 
                ON i.order_id = o.order_id
            JOIN stocks s 
                ON s.product_id = i.product_id
                AND s.store_id = o.store_id
            WHERE s.quantity < i.quantity
        )
        BEGIN

            THROW 50001, 'Stock is insufficient for this product.', 1;

        END


        --Update stock quantity--

        UPDATE s
        SET s.quantity = s.quantity - i.quantity

        FROM stocks s
        JOIN orders o
            ON s.store_id = o.store_id
        JOIN inserted i
            ON i.product_id = s.product_id
            AND i.order_id = o.order_id

    END TRY

    BEGIN CATCH

        ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000);

        SET @ErrorMessage = ERROR_MESSAGE();

        RAISERROR(@ErrorMessage, 16, 1);

    END CATCH

END


--P3--
CREATE TRIGGER trg_ValidateOrderStatus
ON orders
AFTER UPDATE
AS
BEGIN

    SET NOCOUNT ON;

    BEGIN TRY

        --Check if order is marked Completed but shipped_date is NULL--

        IF EXISTS (
            SELECT 1
            FROM inserted
            WHERE order_status = 4
            AND shipped_date IS NULL
        )
        BEGIN

            THROW 50002, 
            'Order cannot be marked as Completed without a shipped date.', 
            1;

        END

    END TRY

    BEGIN CATCH

        ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000);

        SET @ErrorMessage = ERROR_MESSAGE();

        RAISERROR(@ErrorMessage, 16, 1);

    END CATCH

END

--P4--
IF OBJECT_ID('tempdb..#OrderRevenue') IS NOT NULL
DROP TABLE #OrderRevenue;

CREATE TABLE #OrderRevenue
(
    order_id INT,
    store_id INT,
    revenue DECIMAL(12,2)
);

DECLARE @order_id INT
DECLARE @store_id INT
DECLARE @revenue DECIMAL(12,2)

DECLARE order_cursor CURSOR FOR

SELECT order_id, store_id
FROM orders
WHERE order_status = 4;

BEGIN TRY

    BEGIN TRANSACTION;

    OPEN order_cursor;

    FETCH NEXT FROM order_cursor INTO @order_id, @store_id;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        SELECT @revenue =
        SUM((quantity * list_price) - (quantity * list_price * discount))
        FROM order_items
        WHERE order_id = @order_id;

        SET @revenue = ISNULL(@revenue,0);

        INSERT INTO #OrderRevenue
        VALUES (@order_id, @store_id, @revenue);

        FETCH NEXT FROM order_cursor INTO @order_id, @store_id;

    END

    CLOSE order_cursor;
    DEALLOCATE order_cursor;

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    ROLLBACK TRANSACTION;

    PRINT 'Error occurred during revenue calculation';
    PRINT ERROR_MESSAGE();

END CATCH;

SELECT 
    s.store_name,
    SUM(r.revenue) AS total_store_revenue
FROM #OrderRevenue r
JOIN stores s
    ON r.store_id = s.store_id
GROUP BY s.store_name
ORDER BY total_store_revenue DESC;


