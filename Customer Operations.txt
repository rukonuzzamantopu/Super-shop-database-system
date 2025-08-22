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
