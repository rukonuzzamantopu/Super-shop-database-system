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
