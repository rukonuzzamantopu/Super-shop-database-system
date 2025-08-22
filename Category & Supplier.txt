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
