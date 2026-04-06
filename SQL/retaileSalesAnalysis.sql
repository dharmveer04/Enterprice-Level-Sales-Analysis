SELECT * FROM superstore.superstore;
select 
sum(case when profit is null then 1 else 0 end) as null_profit,
sum(case when sales is null then 1 else 0 end) as null_sales,
sum(case when `order date` is null then 1 else 0 end) as null_orderdate
from superstore.superstore;
-- top 10 product by revenue
select `Product Name`,
round(sum(Sales),2) as total_revenue
from superstore.superstore
group by `Product Name`
order by total_revenue desc
limit 10;
-- top 5 customer by revenue
select `Customer Name`,
round(sum(Sales),2) as total_revenue
from superstore.superstore
group by `Customer Name`
order by total_revenue desc
limit 5;
-- total Profit and Sales
SELECT
  ROUND(SUM(sales),2) AS total_sales,
  ROUND(SUM(profit),2) AS total_profit
FROM superstore.superstore;

-- Top Customer Name by Region wise
with customer_sales as(
select Region, `Customer Name`,
round(sum(sales),2) as total_sales
from superstore.superstore
group by Region,`Customer Name`
),
Ranked_customer as(
select Region,`Customer Name`,total_sales,
rank() over (partition by Region order by total_sales desc) as rnk 
from customer_sales
)
select  Region,`Customer Name`,total_sales
from Ranked_customer
where rnk <= 1
order by Region , rnk;

-- Previous day Sales vs OverallSales
select `customer id`,sales,`order date`,
lag(sales) over (partition by `customer id` order by `order date`) as previous_sales,
sales - lag(sales) over (partition by `customer id` order by `order date`) as sales_change
from superstore.superstore;

 select `order id`, count(*)
 from superstore.superstore
 group by `order id`
 having count(*)>1
 order by `order id` desc
 limit 3; 

-- total Sale by months and Years
select
    year(str_to_date(`order date`, '%m/%d/%Y')) as order_year,
    month(str_to_date(`order date`, '%m/%d/%Y')) as order_month,
   round( sum(sales),2)as total_sales
from superstore.superstore
group by
    year(str_to_date(`order date`, '%m/%d/%y')),
    month(str_to_date(`order date`, '%m/%d/%y'))
order by
    order_year,
    order_month;
-- Daily Sales vs running Sales
select 
    `order date`,
    sum(sales) as daily_sales,
    sum(sum(sales)) over (order by `order date`) as running_sales
from superstore.superstore
group by `order date`
order by `order date`
limit 5;


-- total sales by years
SELECT
   year(str_to_date(`order date`, '%m/%d/%Y')) as order_year,
  ROUND(SUM(sales),2) AS yearly_sales
FROM superstore.superstore
GROUP BY year(str_to_date(`order date`, '%m/%d/%Y'))
ORDER BY order_year;
-- profit margin in percentage
SELECT
  ROUND((SUM(profit)/SUM(sales))*100,2) AS profit_margin_pct
FROM superstore.superstore;

-- top 5 loss Product
SELECT
 `product name` ,
  ROUND(SUM(profit),2) AS top_loss_product
FROM superstore.superstore
GROUP BY `product name`
HAVING  top_loss_product < 0
ORDER BY top_loss_product desc
limit 5;
-- findout total sales and profit if give discount
SELECT
  discount,
  ROUND(SUM(sales),2) AS sales,
  ROUND(SUM(profit),2) AS profit
FROM superstore.superstore
GROUP BY discount
ORDER BY discount;

-- top 5 customer id have max time order
SELECT
  `customer id`,
  COUNT(DISTINCT `order id`) AS total_orders
FROM superstore.superstore
GROUP BY `customer id`
HAVING total_orders > 1
order by total_orders desc
limit 5;


-- check how totalsale vs previous sales and then find out yoy growtg %
WITH yearly_sales AS (
  SELECT
    YEAR(str_to_date(`order date`,'%m/%d/%Y')) AS year,
   round( SUM(sales),2) AS total_sales
  FROM superstore.superstore
  GROUP BY YEAR(str_to_date(`order date`,'%m/%d/%Y'))
)
SELECT
  year,
  total_sales,
 round( LAG( total_sales) OVER (ORDER BY year),2) AS prev_year_sales,
  ROUND(
    ( total_sales - LAG( total_sales) OVER (ORDER BY year))
    / nullif(LAG( total_sales) OVER (ORDER BY year),0) * 100, 2
  ) AS yoy_growth_pct
FROM yearly_sales;
--  product name rank by total sales
SELECT
  `product name`,
  SUM(sales) AS total_sales,
  RANK() OVER (ORDER BY SUM(sales) DESC) AS sales_rank
FROM superstore.superstore
GROUP BY `product name`;
-- comulative sales percentage
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
-- top 5 customer name of lifetimesales,totalorder,AOV
SELECT
  `customer name`,
  ROUND(SUM(sales),2) AS lifetime_sales,
  COUNT(DISTINCT `order id`) AS total_orders,
  ROUND(AVG(sales),2) AS avg_order_value
FROM superstore.superstore
GROUP BY `customer name`
order by total_orders desc
limit 5;
-- check discount performence
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

-- regionwise previouse year performence and YOY growth
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
 round( LAG(sales) OVER (PARTITION BY region ORDER BY year),2) AS prev_year_sales,
  ROUND(
    (sales - LAG(sales) OVER (PARTITION BY region ORDER BY year))
    /nullif( LAG(sales) OVER (PARTITION BY region ORDER BY year),2)* 100, 2
  ) AS yoy_growth
FROM region_year_sales;




-- we find out the revenue by growth  year of yaer
with revenue_yoy as(
select 
   YEAR(str_to_date(`order date`,'%m/%d/%Y'))  AS year,
round(sum(quantity*sales),2) as total_revenue
from superstore.superstore
group by   YEAR(str_to_date(`order date`,'%m/%d/%Y'))
)
select 
Year, total_revenue,
round(lag(total_revenue) over ( order by year) ,2)as privesous_year_revenue,
round((total_revenue)-(lag(total_revenue) over ( order by year))/lag(total_revenue) over ( order by year)*100,2) as
total_growth_yoy  
from revenue_yoy
order by year;
  
--   we find out top 10 customer by profit
select `Customer Name`,region,
round(sum(profit),2) as total_profit
from superstore.superstore
group by `customer name`,region
order by total_profit desc
limit 10;

WITH customer_profit AS (
    SELECT 
        `Customer Name`,
        region,
        ROUND(SUM(profit), 2) AS total_profit
    FROM superstore.superstore
    GROUP BY `Customer Name`, region
)
SELECT 
    `Customer Name`,
    region,
    total_profit,
    profit_rank
FROM (
    SELECT 
        `Customer Name`,
        region,
        total_profit,
        RANK() OVER (ORDER BY total_profit DESC) AS profit_rank
    FROM customer_profit
) ranked
WHERE profit_rank <= 10
ORDER BY profit_rank;
 
 select category,
 round(sum(profit),2) as categorywiseprofit
 from superstore.superstore
 group by Category
 order by categorywiseprofit desc;
--  findout top 7 loss making product
  SELECT 
    `product name`,
    ROUND(SUM(profit), 2) AS Loss_making_product
FROM superstore.superstore
GROUP BY `product name`
HAVING SUM(profit) <= 0
ORDER BY Loss_making_product asc
limit 7;
-- monthwise and yearwise totalprofit in category
select category,
  Month(str_to_date(`order date`,'%m/%d/%Y')) AS monthwise,
   Year(str_to_date(`order date`,'%m/%d/%Y')) AS yearwise,
round(sum(profit),2) total_profit
from superstore.superstore
group by category,Month(str_to_date(`order date`,'%m/%d/%Y')), Year(str_to_date(`order date`,'%m/%d/%Y')) 
order by monthwise,yearwise;

-- regionwaise top revenue of customer and product name
with customer_revenue as(
select `customer name`,region,`product name`,
round(
sum(profit),2) as total_profit,
round(sum(sales),2) as toatl_sales
from superstore.superstore
group by `customer name`, region , `product name`
)
select `customer name`,region, `product name`,total_profit, toatl_sales
from(
 select  `customer name`,region,`product name`,total_profit, toatl_sales,
 rank()over (partition by region order by  toatl_sales desc,total_profit desc) as rnk
 from customer_revenue
 )ranked
 where rnk = 1
 order by region ;
 
-- findout repeate customer-- 
with repeate_customer as(
select `customer name` ,`product name`,region,category,
count(`order id`) as most_valuable_customer 
from superstore.superstore
 GROUP BY `Customer Name`, `Product Name`, region, category
)
select `customer name` ,`product name`,region,category,most_valuable_customer
from( select
 `customer name` ,`product name`,region,category,most_valuable_customer,
   RANK() OVER (PARTITION BY region ORDER BY most_valuable_customer  DESC) AS rnk
    FROM repeate_customer
) ranked
where rnk =1 and most_valuable_customer>1
order by region, most_valuable_customer DESC ;

