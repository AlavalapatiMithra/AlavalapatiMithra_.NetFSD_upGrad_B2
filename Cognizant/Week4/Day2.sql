USE sqlDB

--P1--
CREATE OR ALTER TRIGGER trg_UpdateStockAfterInsert
ON order_items
AFTER INSERT
AS
BEGIN

    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN orders o ON i.order_id = o.order_id
        JOIN stocks s 
            ON s.product_id = i.product_id
            AND s.store_id = o.store_id
        WHERE s.quantity < i.quantity
    )
    BEGIN
        THROW 50001, 'Stock is insufficient for the ordered product.', 1;
        ROLLBACK TRANSACTION;
        RETURN;
    END
    UPDATE s
    SET s.quantity = s.quantity - i.quantity
    FROM stocks s
    JOIN orders o 
        ON s.store_id = o.store_id
    JOIN inserted i
        ON i.product_id = s.product_id
        AND i.order_id = o.order_id;

END

BEGIN TRY

    BEGIN TRANSACTION;
    INSERT INTO orders
    (
        customer_id,
        order_status,
        order_date,
        required_date,
        shipped_date,
        store_id,
        staff_id
    )
    VALUES
    (
        1,
        1,  
        GETDATE(),
        DATEADD(DAY,5,GETDATE()),
        NULL,
        1,
        1
    );
    DECLARE @order_id INT;

    SET @order_id = SCOPE_IDENTITY();

    IF EXISTS (
        SELECT 1
        FROM stocks
        WHERE product_id = 1
        AND store_id = 1
        AND quantity < 2
    )
    BEGIN

        THROW 50002, 'Not enough stock available.', 1;

    END
    INSERT INTO order_items
    (
        order_id,
        item_id,
        product_id,
        quantity,
        list_price,
        discount
    )
    VALUES
    (
        @order_id,
        1,
        1,
        2,
        500,
        0.10
    );
    COMMIT TRANSACTION;
    PRINT 'Order placed successfully';
END TRY

BEGIN CATCH
    ROLLBACK TRANSACTION;

    PRINT 'Transaction failed';
    PRINT ERROR_MESSAGE();

END CATCH;

--P2--
DECLARE @order_id INT = 1; 

BEGIN TRY
    BEGIN TRANSACTION;
    PRINT 'Starting order cancellation...';
    SAVE TRANSACTION SaveBeforeStockRestore;
    UPDATE s
    SET s.quantity = s.quantity + oi.quantity
    FROM stocks s
    JOIN orders o 
        ON s.store_id = o.store_id
    JOIN order_items oi 
        ON oi.product_id = s.product_id
        AND oi.order_id = o.order_id

    WHERE o.order_id = @order_id;
    IF @@ROWCOUNT = 0
    BEGIN
        THROW 50001, 'Stock restoration failed.', 1;
    END
    UPDATE orders
    SET order_status = 3
    WHERE order_id = @order_id;
    COMMIT TRANSACTION;
    PRINT 'Order cancelled successfully and stock restored.';
END TRY
BEGIN CATCH
    PRINT 'Error occurred during cancellation.';
    PRINT ERROR_MESSAGE();
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION SaveBeforeStockRestore;
        PRINT 'Rolled back to SAVEPOINT.';
    END
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

END CATCH;