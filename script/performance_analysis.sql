/*Analyze the yearly performance of products
by comparing each product's sales to both
its average sales performance and the previous year's sales
*/

USE DataWarehouseAnalytics;
GO

--Yearly performance of the product

SELECT
    YEAR(f.order_date) AS order_year,
    p.product_name,
    SUM(f.sales_amount) AS current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY
    YEAR(f.order_date),
    p.product_name
GO 

-- Comparing each product sales

WITH yearly_product_sales AS (

    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY
        YEAR(f.order_date),
        p.product_name

) 

SELECT
    order_year,
    product_name,
    current_sales,
    -- average sales performance
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
    CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN  'Below Avg'
        ELSE 'Avg'
    END avg_change,

    --Year over Year analysis
    -- compare the current sales with previous year sales
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales, --window function
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
    CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN  'Decrease'
        ELSE 'No change'
    END py_change
FROM yearly_product_sales
ORDER BY 
    product_name, 
    order_year