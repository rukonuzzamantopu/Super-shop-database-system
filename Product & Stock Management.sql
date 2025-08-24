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
