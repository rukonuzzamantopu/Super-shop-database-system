

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


