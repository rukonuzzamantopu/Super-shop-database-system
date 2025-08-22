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
