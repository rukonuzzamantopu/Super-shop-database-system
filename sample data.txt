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
