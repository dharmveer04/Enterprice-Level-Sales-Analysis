select * from superstore.store limit 5;

select 
sum(case when profit is null then 1 else 0 end) as null_profit,
sum(case when sales is null then 1 else 0 end) as null_sales,
sum(case when `order date` is null then 1 else 0 end) as null_orderdate
from superstore.store;
 
 select `order id`, count(*)
 from superstore.store
 group by `order id`
 having count(*)>1;
 
 select `order id`,
 year(str_to_date(`order date`,'%m/%d/%Y')) as order_year,
 month(str_to_date(`order date`,'%m/%d/%Y')) as orde_month
 from superstore.superstore ;

 select
    year(str_to_date(`order date`, '%m/%d/%Y')) as order_year,
    month(str_to_date(`order date`, '%m/%d/%Y')) as order_month,
    sum(sales) as total_sales
from superstore.superstore
group by order_year, order_month
order by order_year, order_month;

select
    year(str_to_date(`order date`, '%m/%d/%Y')) as order_year,
    month(str_to_date(`order date`, '%m/%d/%Y')) as order_month,
    sum(sales) as total_sales
from superstore.superstore
group by
    year(str_to_date(`order date`, '%m/%d/%y')),
    month(str_to_date(`order date`, '%m/%d/%y'))
order by
    order_year,
    order_month;

select 
    `order date`,
    sum(sales) as daily_sales,
    sum(sum(sales)) over (order by `order date`) as running_sales
from superstore.superstore
group by `order date`
order by `order date`;

SELECT
  ROUND(SUM(sales),2) AS total_sales,
  ROUND(SUM(profit),2) AS total_profit
FROM superstore.superstore;

SELECT
   year(str_to_date(`order date`, '%m/%d/%Y')) as order_year,
  ROUND(SUM(sales),2) AS yearly_sales
FROM superstore.superstore
GROUP BY year(str_to_date(`order date`, '%m/%d/%Y'))
ORDER BY order_year;

SELECT
  ROUND((SUM(profit)/SUM(sales))*100,2) AS profit_margin_pct
FROM superstore.superstore;

SELECT
  `product name`,
  ROUND(SUM(sales),2) AS total_sales
FROM superstore.superstore
GROUP BY `product name`
ORDER BY total_sales DESC
LIMIT 10;

SELECT
 `product name` ,
  ROUND(SUM(profit),2) AS total_profit
FROM superstore.superstore
GROUP BY `product name`
HAVING total_profit < 0
ORDER BY total_profit;

SELECT
  discount,
  ROUND(SUM(sales),2) AS sales,
  ROUND(SUM(profit),2) AS profit
FROM superstore.superstore
GROUP BY discount
ORDER BY discount;

SELECT
  region,
  ROUND(SUM(sales),2) AS total_sales
FROM superstore.superstore
GROUP BY region;

SELECT
  `customer id`,
  COUNT(DISTINCT `order id`) AS total_orders
FROM superstore.superstore
GROUP BY `customer id`
HAVING total_orders > 1;

SELECT
  `order date`,
  SUM(sales) AS daily_sales,
  SUM(SUM(sales)) OVER (ORDER BY `order date`) AS running_sales
FROM superstore.superstore
GROUP BY   `order date`
ORDER BY   `order date`;

WITH yearly_sales AS (
  SELECT
    YEAR(str_to_date(`order date`,'%m/%d/%Y')) AS year,
    SUM(sales) AS total_sales
  FROM superstore.superstore
  GROUP BY YEAR(str_to_date(`order date`,'%m/%d/%Y'))
)
SELECT
  year,
  total_sales,
  LAG( total_sales) OVER (ORDER BY year) AS prev_year_sales,
  ROUND(
    ( total_sales - LAG( total_sales) OVER (ORDER BY year))
    / nullif(LAG( total_sales) OVER (ORDER BY year),0) * 100, 2
  ) AS yoy_growth_pct
FROM yearly_sales;

SELECT
  `product name`,
  SUM(sales) AS total_sales,
  RANK() OVER (ORDER BY SUM(sales) DESC) AS sales_rank
FROM superstore.superstore
GROUP BY `product name`;

WITH product_sales AS (
  SELECT
    `product name`,
    SUM(sales) AS total_sales
  FROM superstore.superstore
  GROUP BY `product name`
),
sales_contribution AS (
  SELECT
    `product name`,
    total_sales,
    SUM(total_sales) OVER (ORDER BY total_sales DESC) AS cumulative_sales,
    SUM(total_sales) OVER () AS overall_sales
  FROM product_sales
)
SELECT
  `product name`,
  total_sales,
  ROUND(cumulative_sales / overall_sales * 100, 2) AS cumulative_pct
FROM sales_contribution
ORDER BY total_sales DESC;

SELECT
  `customer id`,
  ROUND(SUM(sales),2) AS lifetime_sales,
  COUNT(DISTINCT `order id`) AS total_orders,
  ROUND(AVG(sales),2) AS avg_order_value
FROM superstore.superstore
GROUP BY `customer id`;

SELECT
  CASE
    WHEN discount = 0 THEN 'No Discount'
    WHEN discount <= 0.2 THEN 'Low Discount'
    WHEN discount <= 0.4 THEN 'Medium Discount'
    ELSE 'High Discount'
  END AS discount_bucket,
  ROUND(SUM(sales),2) AS total_sales,
  ROUND(SUM(profit),2) AS total_profit
FROM superstore.superstore
GROUP BY discount_bucket;

WITH region_year_sales AS (
  SELECT
    region,
    YEAR(str_to_date(`order date`,'%m/%d/%Y')) AS year,
    SUM(sales) AS sales
  FROM superstore.superstore
  GROUP BY region, YEAR(str_to_date(`order date`,'%m/%d/%Y'))
)
SELECT
  region,
  year,
 round(sales,2),
 round( LAG(sales) OVER (PARTITION BY region ORDER BY year),2) AS prev_year_sales,
  ROUND(
    (sales - LAG(sales) OVER (PARTITION BY region ORDER BY year))
    /nullif( LAG(sales) OVER (PARTITION BY region ORDER BY year),2)* 100, 2
  ) AS yoy_growth
FROM region_year_sales;



 