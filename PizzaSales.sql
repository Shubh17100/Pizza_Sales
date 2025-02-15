use Pizzahut;
Select * from order_details;
Select * from orders;
Select * from pizza_types;
Select * from pizzas;
-- Basic:

-- Retrieve the total number of orders placed.
		Select count(Order_id) Total_Orders from orders;
        
-- Calculate the total revenue generated from pizza sales.
		Select round(sum(pz.price * od.quantity),2 ) Total_Revenue from pizzas pz
        join order_details od 
        on pz.pizza_id = od.pizza_id;

-- Identify the highest price pizza 
		Select pizzas.*, pt.name from pizzas
        join pizza_types pt
        on pizzas.pizza_type_id = pt.pizza_type_id
        where price =
        (Select Max(price) from pizzas);
        
-- Identify the most common pizza size ordered.
		Select size, sum(quantity) as Total_size_orders from pizzas
        join order_details od
        on od.pizza_id = pizzas.pizza_id
        group by size;
        
-- List the top 5 most ordered pizza types along with their quantities.
		Select pt.name,  sum(od.quantity) Total_quantity_type from pizzas pz
        join order_details od
        on pz.pizza_id = od.pizza_id
        join pizza_types pt on pz.pizza_type_id = pt.pizza_type_id
        group by 1
        order by 2 desc
        limit 5;
        
        

-- Intermediate:

-- Join the necessary tables to find the total quantity of each pizza category ordered.
			Select pt.category, sum(od.quantity) from pizza_types pt
            join pizzas pz
            on pt.pizza_type_id = pz.pizza_type_id
            join order_details od 
            on od.pizza_id = pz.pizza_id 
            group by 1;
            
-- Determine the distribution of orders by hour of the day.
		SELECT HOUR(o.time) AS order_hour,
        COUNT(o.order_id) AS total_orders  
		FROM orders o  
		GROUP BY order_hour  
		ORDER BY order_hour;
        
        select month(o.time) 
        , count(o.order_id)
        from orders o 
        group by 1
        order by 1;
        
        Select day(o.date) ,sum(pz.price * od.quantity),
        count(o.order_id) 
        from orders o 
        join order_details od on 
        od.order_id = o.order_id
        join pizzas pz 
        on pz.pizza_id = od.pizza_id
        group by 1 
        order by 1;
        
        SELECT 
    MONTH(o.date) AS order_month, 
    COUNT(DISTINCT o.order_id) AS total_orders, 
    SUM(od.quantity * p.price) AS total_revenue  
FROM orders o  
JOIN order_details od ON o.order_id = od.order_id  
JOIN pizzas p ON od.pizza_id = p.pizza_id  
GROUP BY order_month  
ORDER BY order_month;
        
        select distinct month(date) from orders;
        
        SELECT 
    MONTH(o.date) AS order_month, 
    COUNT(DISTINCT o.order_id) AS total_orders, 
    COALESCE(SUM(od.quantity * p.price), 0) AS total_revenue  
FROM orders o  
LEFT JOIN order_details od ON o.order_id = od.order_id  
LEFT JOIN pizzas p ON od.pizza_id = p.pizza_id  
GROUP BY order_month  
ORDER BY order_month;
		
        WITH months AS (
    SELECT 1 AS month UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL 
    SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL 
    SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL 
    SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
)
SELECT 
    m.month AS order_month, 
    COALESCE(COUNT(DISTINCT o.order_id), 0) AS total_orders, 
    COALESCE(SUM(od.quantity * p.price), 0) AS total_revenue  
FROM months m  
LEFT JOIN orders o ON MONTH(o.date) = m.month  
LEFT JOIN order_details od ON o.order_id = od.order_id  
LEFT JOIN pizzas p ON od.pizza_id = p.pizza_id  
GROUP BY m.month  
ORDER BY m.month;
        
        WITH months AS (
    SELECT 1 AS month UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL 
    SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL 
    SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL 
    SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
)
SELECT 
    m.month AS order_month, 
    COALESCE(COUNT(DISTINCT o.order_id), 0) AS total_orders, 
    COALESCE(SUM(od.quantity * p.price), 0) AS total_revenue  
FROM months m  
LEFT JOIN orders o ON MONTH(o.date) = m.month  
LEFT JOIN order_details od ON o.order_id = od.order_id  
LEFT JOIN pizzas p ON od.pizza_id = p.pizza_id  
GROUP BY m.month  
ORDER BY m.month;

-- Join relevant tables to find the category-wise distribution of pizzas.

		SELECT 
    pt.category, 
    COUNT(p.pizza_id) AS total_pizzas  
FROM pizzas p  
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id  
GROUP BY pt.category  
ORDER BY total_pizzas DESC;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
		
        SELECT 
    o.date, 
    SUM(od.quantity) AS total_pizzas_ordered,
    AVG(SUM(od.quantity)) OVER () AS avg_pizzas_per_day
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY o.date
ORDER BY o.date;
        
-- Determine the top 3 most ordered pizza types based on revenue.
	Select pt.name, sum(pz.price *od.quantity) revenue 
    from pizzas pz 
    join order_details od 
    on pz.pizza_id = od.pizza_id
    join pizza_types pt
	on pt.pizza_type_id = pz.pizza_type_id
    group by 1
    order by 2 desc
    limit 3;

-- Advanced:

-- Calculate the percentage contribution of each pizza type to total revenue.
		SELECT 
    pt.name AS pizza_type, 
    SUM(od.quantity * p.price) AS total_revenue,
    ROUND((SUM(od.quantity * p.price) / (SELECT SUM(od.quantity * p.price) 
                                          FROM order_details od
                                          JOIN pizzas p ON od.pizza_id = p.pizza_id)) * 100, 2) AS revenue_percentage
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC;

-- Analyze the cumulative revenue generated over time.
		SELECT 
    o.date, 
    SUM(od.quantity * p.price) AS daily_revenue,
    SUM(SUM(od.quantity * p.price)) OVER (ORDER BY o.date) AS cumulative_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.date
ORDER BY o.date;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
		Select pt.category,pt.name, sum(pz.price * od.quantity) revenue
        from pizzas pz
        join pizza_types pt 
        on pt.pizza_type_id = pz.pizza_type_id
        join order_details od 
        on od.pizza_id = pz. pizza_id
        group by 1 ,2
        order by 1;
        
        WITH PizzaRevenue AS (
    SELECT 
        pt.category, 
        pt.name AS pizza_type, 
        SUM(od.quantity * p.price) AS total_revenue
        -- RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS rank_order
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
)
SELECT category, pizza_type, total_revenue
FROM PizzaRevenue

