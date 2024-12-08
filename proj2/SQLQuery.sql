CREATE DATABASE pizza_project;
GO

-- RETRIEVE THE TOTAL NUMBER OF ORDERS PLACED
SELECT 
	COUNT(DISTINCT order_id) AS Total_Count
FROM orders;

-- CALCULATE TOTAL REVENUE GENERATED FROM PIZZA SALES
SELECT FLOOR(SUM(p.price * o.quantity)) AS Total_Revenue
FROM pizzas p
JOIN order_details o
ON p.pizza_id = o.pizza_id;

-- Identify the Highest Priced Pizza
SELECT TOP 1 *
FROM pizzas p
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC;

WITH highest_priced_pizza AS (
    SELECT 
        p.pizza_id,
		p.price,
        pt.*, 
        RANK() OVER (ORDER BY p.price DESC) AS rnk
    FROM pizzas p
    JOIN pizza_types pt
    ON p.pizza_type_id = pt.pizza_type_id
)
SELECT *
FROM highest_priced_pizza
WHERE rnk = 1;

-- IDENTIFY THE MOST COMMON PIZZA SIZE ORDERED
SELECT COUNT(DISTINCT order_id) AS Total, SUM(o.quantity) AS Total_Quantity, p.size
FROM order_details o
JOIN pizzas p
ON o.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY Total, Total_Quantity DESC

-- IDENTIFY THE 5 MOST ORDERED PIZZA TYPES ALONG WITH THEIR QUANTiTY
SELECT TOP 5 SUM(od.quantity) AS Total_Qty, pt.category, pt.name
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY category, name
ORDER BY Total_Qty DESC;

-- FIND THE TOTAL QUANTITY OF EACH PIZZA CATEGORY ORDERED
SELECT SUM(od.quantity) AS Total_Quantity, pt.category
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY category
ORDER BY Total_Quantity DESC;

-- DETERMINE THE DISTRIBUTION BY HOUR OF THE DAY
SELECT DATEPART(hour, time) AS hour_of_day, COUNT(DISTINCT order_id) AS 'No of orders'
FROM orders
GROUP BY DATEPART(hour, time)
ORDER BY [No of orders];

-- FIND THE CATEGORYWISE DISTRIBUTION OF PIZZAS
SELECT category, COUNT(DISTINCT pizza_type_id) AS [No of pizzas]
FROM pizza_types
GROUP BY category 
ORDER bY [No of pizzas]; 

-- CALCULATE THE AVERAGE NUMBER OF PIZZAS ORDERED BY DAY
SELECT AVG(Total_Qty) AS Average_Quantity
FROM (
    SELECT o.date, SUM(od.quantity) AS Total_Qty
    FROM orders o
    JOIN order_details od
    ON o.order_id = od.order_id
    GROUP BY o.date
) AS daily_totals;


-- DETERMINE THE TOP 3 MOST ORDERED PIZZAS TYPE BASED ON REVENUE
SELECT TOP 3 pt.name, FLOOR(SUM(p.price * o.quantity)) AS Total_Revenue
FROM pizzas p
JOIN order_details o
ON p.pizza_id = o.pizza_id
JOIN pizza_types pt
ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY Total_Revenue DESC;

-- CALCULATE THE PERCENTAGE CONTRIBUTION OF EACH PIZZA TYPE TO TOTAL REVENUE
SELECT 
    pt.name AS Pizza_Type, 
    SUM(p.price * o.quantity) AS Total_Revenue,
    ROUND(SUM(p.price * o.quantity) * 100.0 / SUM(SUM(p.price * o.quantity)) OVER(), 2) AS Percentage_Contribution
FROM pizzas p
JOIN order_details o
ON p.pizza_id = o.pizza_id
JOIN pizza_types pt
ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY Percentage_Contribution DESC;

-- CALCULATE THE PERCENTAGE CONTRIBUTION OF EACH PIZZA CATEGORY TO TOTAL REVENUE
SELECT 
    pt.category AS Pizza_category, 
    FLOOR(SUM(p.price * o.quantity)) AS Total_Revenue,
    CONCAT(ROUND(SUM(p.price * o.quantity) * 100.0 / SUM(SUM(p.price * o.quantity)) OVER(), 2), '%') AS Percentage_Contribution
FROM pizzas p
JOIN order_details o
ON p.pizza_id = o.pizza_id
JOIN pizza_types pt
ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY Percentage_Contribution DESC;

-- ANALYZE THE CUMMULATIVE REVENUE GENERATED OVER TIME
SELECT 
    o.date AS Order_Date, 
    SUM(p.price * od.quantity) AS Daily_Revenue,
    SUM(SUM(p.price * od.quantity)) OVER (ORDER BY o.date) AS Cumulative_Revenue
FROM orders o
JOIN order_details od
ON o.order_id = od.order_id
JOIN pizzas p
ON p.pizza_id = od.pizza_id
GROUP BY o.date
ORDER BY o.date;

-- DETERMINE THE TOP 3 MOST ORDERED PIZZA TYPES BASED ON REVENUE FOR EACH PIZZA
WITH Pizza_Revenue AS (
    SELECT 
        pt.name AS Pizza_Type, 
        p.pizza_id, 
        SUM(p.price * od.quantity) AS Total_Revenue
    FROM pizzas p
    JOIN order_details od
    ON p.pizza_id = od.pizza_id
    JOIN pizza_types pt
    ON pt.pizza_type_id = p.pizza_type_id
    GROUP BY pt.name, p.pizza_id
),
Ranked_Pizzas AS (
    SELECT 
        Pizza_Type, 
        pizza_id, 
        Total_Revenue,
        RANK() OVER (PARTITION BY Pizza_Type ORDER BY Total_Revenue DESC) AS rnk
    FROM Pizza_Revenue
)
SELECT 
    Pizza_Type, 
    pizza_id, 
    Total_Revenue
FROM Ranked_Pizzas
WHERE rnk <= 3
ORDER BY Pizza_Type, Total_Revenue DESC;
