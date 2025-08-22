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
