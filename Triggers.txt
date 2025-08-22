-- Triggers
DELIMITER $$

-- Before inserting into Cart, calculate total_amount
CREATE TRIGGER before_cart_insert
BEFORE INSERT ON Cart
FOR EACH ROW
BEGIN
    DECLARE unit_price DECIMAL(10,2);
    SELECT price_per_unit INTO unit_price
    FROM Products
    WHERE product_id = NEW.product_id;
    SET NEW.total_amount = unit_price * NEW.quantity;
END$$


-- Before inserting into Orders, calculate total amount from Cart
CREATE TRIGGER before_order_insert
BEFORE INSERT ON Orders
FOR EACH ROW
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(c.quantity * p.price_per_unit)
    INTO total
    FROM Cart as c
    JOIN Products as p ON c.product_id = p.product_id
    WHERE c.customer_id = NEW.customer_id;
    SET NEW.total_amount = total;
END$$


-- After inserting into Orders, update OrderDetails, update stock, clear cart
CREATE TRIGGER after_order_insert
AFTER INSERT ON Orders
FOR EACH ROW
BEGIN
    INSERT INTO OrderDetails (order_id, product_id, quantity, total_amount)
    SELECT NEW.order_id, c.product_id, c.quantity, c.total_amount
    FROM Cart as c
    WHERE c.customer_id = NEW.customer_id;

    UPDATE Products as p
    JOIN Cart as c ON p.product_id = c.product_id
    SET p.stock = p.stock - c.quantity
    WHERE c.customer_id = NEW.customer_id;

    DELETE FROM Cart WHERE customer_id = NEW.customer_id;
END$$


-- After payment, update OrderDetails status
CREATE TRIGGER after_payment_insert
AFTER INSERT ON Payments
FOR EACH ROW
BEGIN
    UPDATE OrderDetails
    SET status = 'Confirmed'
    WHERE order_id = NEW.order_id;
END$$


-- After delivery, update OrderDetails status
CREATE TRIGGER after_order_delivered_insert
AFTER INSERT ON OrderDelivered
FOR EACH ROW
BEGIN
    UPDATE OrderDetails
    SET status = 'Delivered'
    WHERE order_id = NEW.order_id;
END$$


-- Before payment, insert order_id into payment table
CREATE TRIGGER before_payment_insert
BEFORE INSERT ON Payments
FOR EACH ROW
BEGIN
    IF NEW.order_id IS NULL THEN
        SET NEW.order_id = (
            SELECT order_id
            FROM Orders
            WHERE customer_id = NEW.customer_id
            ORDER BY order_date DESC, order_id DESC
            LIMIT 1
        );
    END IF;
END$$


--give error message 
DELIMITER $$

-- Prevent adding to Cart if quantity is zero or negative
CREATE TRIGGER validate_cart_quantity
BEFORE INSERT ON Cart
FOR EACH ROW
BEGIN
    IF NEW.quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Quantity must be greater than zero.';
    END IF;
END$$
