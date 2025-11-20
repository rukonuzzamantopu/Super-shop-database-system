

/*creating new database with the name Lib_mngmt_system*/

create database lib_mngmt_system

use lib_mngmt_system

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    email VARCHAR(100) UNIQUE,
    address TEXT
);

CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    address TEXT
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    price_per_unit DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    category_id INT,
    supplier_id INT,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE SET NULL,
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id) ON DELETE SET NULL
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE OrderDetails (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    total_amount DECIMAL(10,2) DEFAULT 0.00,
    status ENUM('Processing', 'Confirmed', 'Delivered') DEFAULT 'Processing',
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE
);

CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    customer_id INT,
    payment_date DATE,
    amount DECIMAL(10,2),
    payment_method ENUM('Cash', 'Card', 'Mobile Banking'),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE Cart (
    customer_id INT,
    product_id INT,
    quantity INT NOT NULL,
    total_amount DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE
);

CREATE TABLE OrderDelivered (
    order_id INT UNIQUE,
    delivered_date DATE NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

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


-- Insert sample data
INSERT INTO Customers (customer_name, phone, email, address) VALUES
('Rahim Uddin', '01711111111', 'rahim@gmail.com', 'Mirpur, Dhaka'),
('Karim Ahmed', '01822222222', 'karim@yahoo.com', 'Gulshan, Dhaka'),
('Abdul Kalam', '01933333333', 'kalam@gmail.com', 'Chattogram'),
('Shamima Akhter', '01644444444', 'shamima@gmail.com', 'Sylhet'),
('Sultana Begum', '01555555555', 'sultana@gmail.com', 'Khulna');

INSERT INTO Categories (category_name) VALUES
('Grocery'), ('Beverages'), ('Snacks'), ('Personal Care'), ('Household');

INSERT INTO Suppliers (supplier_name, phone, address) VALUES
('Akash Traders', '01712345678', 'Old Dhaka'),
('Momin Enterprise', '01887654321', 'Chawkbazar, Dhaka'),
('Chattogram Supply House', '01911223344', 'Agrabad, Chattogram'),
('Sylhet Wholesale', '01655667788', 'Zindabazar, Sylhet'),
('Khulna Mart', '01599887766', 'Sonadanga, Khulna');

INSERT INTO Products (product_name, price_per_unit, stock, category_id, supplier_id) VALUES
('Aarong Milk 1L', 80.00, 50, 2, 1),
('ACI Pure Salt 1kg', 35.00, 100, 1, 2),
('Parachute Hair Oil 200ml', 150.00, 30, 4, 3),
('Lux Soap 100g', 45.00, 80, 4, 4),
('Radhuni Turmeric Powder 200g', 120.00, 40, 1, 5);


INSERT INTO Cart (customer_id, product_id, quantity) VALUES (1, 1, 2);
INSERT INTO Cart (customer_id, product_id, quantity) VALUES (1, 3, 1);
INSERT INTO Cart (customer_id, product_id, quantity) VALUES (3, 2, 3);
INSERT INTO Cart (customer_id, product_id, quantity) VALUES (2, 4, 2);
INSERT INTO Cart (customer_id, product_id, quantity) VALUES (4, 5, 1);
INSERT INTO Cart (customer_id, product_id, quantity) VALUES (5, 1, 1);
INSERT INTO Cart (customer_id, product_id, quantity) VALUES (3, 1, 3);
INSERT INTO Cart (customer_id, product_id, quantity) VALUES (5, 2, 4);

INSERT INTO Orders (customer_id, order_date) VALUES (1, CURDATE());
INSERT INTO Orders (customer_id, order_date) VALUES (3, CURDATE());
INSERT INTO Orders (customer_id, order_date) VALUES (1, CURDATE());
INSERT INTO Orders (customer_id, order_date) VALUES (5, CURDATE());
INSERT INTO Orders (customer_id, order_date) VALUES (2, CURDATE());

INSERT INTO Payments (customer_id, payment_date, amount, payment_method) VALUES (1, CURDATE(), 310.00, 'Cash');
INSERT INTO Payments (customer_id, payment_date, amount, payment_method) VALUES (1, CURDATE(), 90.00, 'Cash');
INSERT INTO Payments (customer_id, payment_date, amount, payment_method) VALUES (5, CURDATE(), 120.00, 'Mobile Banking');
INSERT INTO Payments (customer_id, payment_date, amount, payment_method) VALUES (2, CURDATE(), 80.00, 'Card');

INSERT INTO OrderDelivered (order_id, delivered_date) VALUES (1, CURDATE());
INSERT INTO OrderDelivered (order_id, delivered_date) VALUES (3, CURDATE());
INSERT INTO OrderDelivered (order_id, delivered_date) VALUES (4, CURDATE());


-- 7) Insert a new product under 'Snacks' with supplier 'Akash Traders'
INSERT INTO Products (product_name, price_per_unit, stock, category_id, supplier_id)
VALUES (
  'Mr. Twist Chips 50g',
  25.00,
  200,
  (SELECT category_id FROM Categories WHERE category_name = 'Snacks'),
  (SELECT supplier_id FROM Suppliers WHERE supplier_name = 'Akash Traders')
);

-- 8) Increase stock of 'Lux Soap' by 20
UPDATE Products
SET stock = stock + 20
WHERE product_name = 'Lux Soap 100g';

-- 9) Decrease stock of 'ACI Pure Salt 1kg' by 10 (floor at 0 just in case)
UPDATE Products
SET stock = GREATEST(stock - 10, 0)
WHERE product_name = 'ACI Pure Salt 1kg';

-- 10) Find all products that are out of stock
SELECT product_id, product_name, stock
FROM Products
WHERE stock = 0;

-- 11) List products with stock < 20
SELECT product_id, product_name, stock
FROM Products
WHERE stock < 20
ORDER BY stock ASC;

-- 12) Show product, category, supplier, price
SELECT p.product_id, p.product_name, p.price_per_unit, p.stock,
       c.category_name, s.supplier_name
FROM Products p
LEFT JOIN Categories c ON p.category_id = c.category_id
LEFT JOIN Suppliers s  ON p.supplier_id = s.supplier_id
ORDER BY c.category_name, p.product_name;

-- 13) Most expensive product
SELECT product_id, product_name, price_per_unit
FROM Products
ORDER BY price_per_unit DESC
LIMIT 1;

-- 14) Cheapest product in 'Personal Care'
SELECT p.product_id, p.product_name, p.price_per_unit
FROM Products p
JOIN Categories c ON p.category_id = c.category_id
WHERE c.category_name = 'Personal Care'
ORDER BY p.price_per_unit ASC
LIMIT 1;

-- 15) Average price by category
SELECT c.category_name, AVG(p.price_per_unit) AS avg_price
FROM Products p
JOIN Categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY avg_price DESC;


-- 35) Insert a new payment for an existing order (explicit order_id)
INSERT INTO Payments (order_id, customer_id, payment_date, amount, payment_method)
VALUES (
  1,
  (SELECT customer_id FROM Orders WHERE order_id = 1),
  CURDATE(),
  50.00,
  'Cash'
);

-- 36) Update the payment method for a customer's last payment (example: 'Rahim Uddin')
UPDATE Payments
SET payment_method = 'Mobile Banking'
WHERE payment_id = (
  SELECT payment_id FROM (
    SELECT p.payment_id
    FROM Payments p
    JOIN Customers c ON c.customer_id = p.customer_id
    WHERE c.customer_name = 'Rahim Uddin'
    ORDER BY p.payment_date DESC, p.payment_id DESC
    LIMIT 1
  ) x
);

-- 37) Delete a payment entry (example: smallest payment_id)
DELETE FROM Payments
WHERE payment_id = (SELECT MIN(payment_id) FROM Payments);

-- 38) Find all payments made via Mobile Banking
SELECT p.payment_id, c.customer_name, p.order_id, p.amount, p.payment_date
FROM Payments p
JOIN Customers c ON c.customer_id = p.customer_id
WHERE p.payment_method = 'Mobile Banking'
ORDER BY p.payment_date DESC, p.payment_id DESC;

-- 39) Total amount paid by each customer
SELECT c.customer_name, ROUND(COALESCE(SUM(p.amount),0),2) AS total_paid
FROM Customers c
LEFT JOIN Payments p ON p.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY total_paid DESC;

-- 40) Customers who haven’t made any payment
SELECT c.customer_id, c.customer_name, c.email
FROM Customers c
LEFT JOIN Payments p ON p.customer_id = c.customer_id
WHERE p.payment_id IS NULL
ORDER BY c.customer_id;


-- 26) Insert a new order for customer_id = 2 (trigger will copy cart, update stock, clear cart)
INSERT INTO Orders (customer_id, order_date)
VALUES (2, CURDATE());

-- 27) Update order_date for a specific order (example: set order_id=2 to yesterday)
UPDATE Orders
SET order_date = DATE_SUB(CURDATE(), INTERVAL 1 DAY)
WHERE order_id = 2;

-- 28) Delete an order by id (example: delete the highest id order)
DELETE FROM Orders
WHERE order_id = (SELECT MAX(order_id) FROM Orders);

-- 29) Find all orders made today
SELECT o.order_id, cu.customer_name, o.total_amount, o.order_date
FROM Orders o
JOIN Customers cu ON cu.customer_id = o.customer_id
WHERE o.order_date = CURDATE();

-- 30) Full order details (customer, product, qty, status)
SELECT o.order_id, o.order_date, cu.customer_name,
       p.product_name, od.quantity, od.total_amount, od.status
FROM OrderDetails od
JOIN Orders o     ON o.order_id = od.order_id
JOIN Customers cu ON cu.customer_id = o.customer_id
JOIN Products p   ON p.product_id = od.product_id
ORDER BY o.order_id, p.product_name;

-- 31) Total revenue from all orders (sum of OrderDetails total_amount is more granular)
SELECT ROUND(SUM(od.total_amount), 2) AS gross_revenue
FROM OrderDetails od;

-- 32) Top 3 customers by total purchase (from OrderDetails)
SELECT cu.customer_id, cu.customer_name, ROUND(SUM(od.total_amount), 2) AS total_spent
FROM Orders o
JOIN Customers cu ON cu.customer_id = o.customer_id
JOIN OrderDetails od ON od.order_id = o.order_id
GROUP BY cu.customer_id, cu.customer_name
ORDER BY total_spent DESC
LIMIT 3;

-- 33) Number of products in each order
SELECT o.order_id, cu.customer_name, COUNT(*) AS line_items, SUM(od.quantity) AS total_units
FROM Orders o
JOIN Customers cu ON cu.customer_id = o.customer_id
JOIN OrderDetails od ON od.order_id = o.order_id
GROUP BY o.order_id, cu.customer_name
ORDER BY o.order_id;

-- 34) Orders where total order amount > 200 (use Orders.total_amount)
SELECT o.order_id, cu.customer_name, o.total_amount, o.order_date
FROM Orders o
JOIN Customers cu ON cu.customer_id = o.customer_id
WHERE o.total_amount > 200
ORDER BY o.total_amount DESC;


-- 41) Insert a delivery record for order_id = 2 (if not already delivered)
INSERT INTO OrderDelivered (order_id, delivered_date)
SELECT 2, CURDATE()
WHERE NOT EXISTS (SELECT 1 FROM OrderDelivered WHERE order_id = 2);

-- 42) Update delivered_date for an order (example: order_id=3 -> set to yesterday)
UPDATE OrderDelivered
SET delivered_date = DATE_SUB(CURDATE(), INTERVAL 1 DAY)
WHERE order_id = 3;

-- 43) All delivered orders with customer names
SELECT odv.order_id, o.order_date, odv.delivered_date, c.customer_name
FROM OrderDelivered odv
JOIN Orders o   ON o.order_id = odv.order_id
JOIN Customers c ON c.customer_id = o.customer_id
ORDER BY odv.delivered_date DESC;

-- 44) Count how many order lines are still 'Processing'
SELECT COUNT(*) AS processing_lines
FROM OrderDetails
WHERE status = 'Processing';

-- 45) Count how many order lines are 'Delivered'
SELECT COUNT(*) AS delivered_lines
FROM OrderDetails
WHERE status = 'Delivered';


-- 1) Insert a new customer
INSERT INTO Customers (customer_name, phone, email, address)
VALUES ('Nasrin Jahan', '01766666666', 'nasrin@example.com', 'Banani, Dhaka');

-- 2) Update address of customer 'Rahim Uddin'
UPDATE Customers
SET address = 'Mirpur DOHS, Dhaka'
WHERE customer_name = 'Rahim Uddin';

-- 3) Delete a customer by id (example: delete the last inserted customer if needed)
DELETE FROM Customers
WHERE customer_id = (SELECT MAX(customer_id) FROM Customers);

-- 4) Find all customers from Dhaka
SELECT customer_id, customer_name, phone, email, address
FROM Customers
WHERE address LIKE '%Dhaka%';

-- 5) Count total number of customers
SELECT COUNT(*) AS total_customers FROM Customers;

-- 6) Get the latest 3 registered customers by id
SELECT customer_id, customer_name, email, address
FROM Customers
ORDER BY customer_id DESC
LIMIT 3;


-- 16) Add category 'Electronics' (idempotent-ish; ignore if exists)
INSERT INTO Categories (category_name)
SELECT 'Electronics'
WHERE NOT EXISTS (SELECT 1 FROM Categories WHERE category_name = 'Electronics');

-- 17) Add supplier 'BD Wholesale'
INSERT INTO Suppliers (supplier_name, phone, address)
VALUES ('BD Wholesale', '01300123456', 'Motijheel, Dhaka');

-- 18) Number of products per supplier
SELECT s.supplier_name, COUNT(p.product_id) AS product_count
FROM Suppliers s
LEFT JOIN Products p ON p.supplier_id = s.supplier_id
GROUP BY s.supplier_name
ORDER BY product_count DESC, s.supplier_name;

-- 19) Number of products per category
SELECT c.category_name, COUNT(p.product_id) AS product_count
FROM Categories c
LEFT JOIN Products p ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY product_count DESC, c.category_name;

-- 20) Suppliers that supply more than 2 products
SELECT s.supplier_name, COUNT(p.product_id) AS product_count
FROM Suppliers s
JOIN Products p ON p.supplier_id = s.supplier_id
GROUP BY s.supplier_name
HAVING COUNT(p.product_id) > 2
ORDER BY product_count DESC;


-- 21) Insert an item into Karim Ahmed's cart: add 'Lux Soap 100g' x3
INSERT INTO Cart (customer_id, product_id, quantity)
VALUES (
  (SELECT customer_id FROM Customers WHERE customer_name = 'Karim Ahmed'),
  (SELECT product_id FROM Products WHERE product_name = 'Lux Soap 100g'),
  3
);

-- 22) Update quantity of a cart item: increase Karim's 'Lux Soap 100g' by +2
UPDATE Cart
SET quantity = quantity + 2,
    total_amount = (SELECT price_per_unit FROM Products WHERE product_id = Cart.product_id) * (quantity + 2)
WHERE customer_id = (SELECT customer_id FROM Customers WHERE customer_name = 'Karim Ahmed')
  AND product_id = (SELECT product_id FROM Products WHERE product_name = 'Lux Soap 100g');

-- 23) Delete all items from a customer's cart (example: 'Shamima Akhter')
DELETE FROM Cart
WHERE customer_id = (SELECT customer_id FROM Customers WHERE customer_name = 'Shamima Akhter');

-- 24) Total cart value per customer
SELECT c.customer_id, cu.customer_name, SUM(c.total_amount) AS cart_total
FROM Cart c
JOIN Customers cu ON cu.customer_id = c.customer_id
GROUP BY c.customer_id, cu.customer_name
ORDER BY cart_total DESC;

-- 25) List cart items with product names for a given customer (example: 'Karim Ahmed')
SELECT cu.customer_name, p.product_name, c.quantity, c.total_amount
FROM Cart c
JOIN Customers cu ON cu.customer_id = c.customer_id
JOIN Products  p  ON p.product_id = c.product_id
WHERE cu.customer_name = 'Karim Ahmed';


-- 46) Top-selling product by total quantity
SELECT p.product_id, p.product_name, SUM(od.quantity) AS total_sold_units
FROM OrderDetails od
JOIN Products p ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_sold_units DESC
LIMIT 1;

-- 47) Monthly sales report (by order_date month from Orders, using OrderDetails amounts)
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS yyyymm,
       ROUND(SUM(od.total_amount), 2) AS monthly_sales
FROM Orders o
JOIN OrderDetails od ON od.order_id = o.order_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY yyyymm DESC;

-- 48) Customers who ordered more than 3 times
SELECT c.customer_id, c.customer_name, COUNT(*) AS order_count
FROM Orders o
JOIN Customers c ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(*) > 3
ORDER BY order_count DESC;

-- 49) Supplier-wise revenue (sum of OrderDetails for products supplied by each supplier)
SELECT s.supplier_name, ROUND(SUM(od.total_amount), 2) AS supplier_revenue
FROM OrderDetails od
JOIN Products p ON p.product_id = od.product_id
JOIN Suppliers s ON s.supplier_id = p.supplier_id
GROUP BY s.supplier_name
ORDER BY supplier_revenue DESC;

-- 50) Pending orders (any line still 'Processing') with customer names (distinct orders)
SELECT DISTINCT o.order_id, o.order_date, c.customer_name
FROM Orders o
JOIN OrderDetails od ON od.order_id = o.order_id
JOIN Customers c ON c.customer_id = o.customer_id
WHERE od.status = 'Processing'
ORDER BY o.order_date DESC, o.order_id DESC;
