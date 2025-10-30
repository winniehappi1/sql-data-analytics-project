--Calculate the total sales per month
-- and the running total of sales over time
USE DataWarehouseAnalytics
Go
-- Find the running total 
SELECT 
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales  --window function
FROM
(

SELECT 
    DATETRUNC(year, order_date) AS order_date,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(year, order_date)

) t
GO
-- find the moving average
SELECT 
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,  --window function
    AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_sales
FROM
(

    SELECT 
        DATETRUNC(year, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)

) t -- Understand how the business is growing