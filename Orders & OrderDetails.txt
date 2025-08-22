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
