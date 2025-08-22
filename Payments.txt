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
