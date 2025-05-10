SELECT * FROM northwind.order_details;

-- 1. Sales analysis by time
 
select 
	o.id as order_id, 
    o.order_date, 
    od.product_id, 
    od.quantity, 
    od.unit_price, 
    od.discount
from orders o
join order_details od on o.id = od.order_id;

-- total number of orders 
select 
	o.id as order_id, 
    o.order_date, 
    od.product_id, 
    od.quantity, 
    od.unit_price, 
    od.discount, 
    count(distinct o.id) as totalOrders
from orders o
join order_details od on o.id = od.order_id; --  join tables by order id 

select 
	o.id as order_id, 
    o.order_date, 
    od.product_id, 
    od.quantity, 
    od.unit_price, 
    od.discount, 
    sum(od.quantity) as totalQuantity
from orders o
join order_details od on o.id = od.order_id; --  join tables by order id
  
select 
	o.id as order_id, 
    o.order_date, 
    od.product_id, 
    od.quantity, 
    od.unit_price, 
    od.discount, 
    ROUND((1 - od.discount / 100), 2) AS discountFactor,  --  round to two decimal places
    ROUND(od.quantity * od.unit_price * (1 - od.discount / 100), 2) as totalAmaount -- calculate the sales amount and round to two decimal places
from orders o
join order_details od on o.id = od.order_id; -- join tables by order id

select 
	date_format(o.order_date, '%Y-%m') as orderYearMonth, -- extracts the year and month 
    count(distinct o.id) as totalOrders,   -- counts unique orders
    sum(od.quantity) as totalQuantity, -- total amount of goods 
    round(sum(od.quantity * od.unit_price * (1 - od.discount / 100)), 2) as totalAmount -- estimated sales amount with discounts and round to two decimal places
from orders o
join order_details od on o.id = od.order_id -- join tables by order id 
group by date_format(o.order_date, '%Y-%m') -- grouping by date 
order by orderYearMonth; -- sort by date 

SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

-- 2. Sales analysis by product

select 
	p.product_name, 
    count(distinct od.order_id) as totalOrders, -- how many times the product was ordered 
    ROUND((1 - od.discount / 100), 2) AS discountFactor, -- calculates the discount factor and rounds it to two digits 
    round(sum(od.quantity * od.unit_price * (1 - od.discount/ 100)),2) as totalSales -- total sales amounts and round to two decimal places
from order_details od
join products p on od.product_id = p.id -- join tables by product id 
group by product_name -- grouping by product 
order by totalSales desc; -- Sort by sales amount from highest to lowest 

-- 3. Customer analysis
-- 3.1 Customer analysis by sales 

select
	c.company,
    c.country,
    ROUND(SUM(od.quantity * od.unit_price * (1 - od.discount / 100)), 2) AS totalSales -- calculates the discount factor and rounds it to two digits
from orders o
join customers c on o.customer_id = c.id -- join tables by customer id 
join order_details od on o.id = od.order_id -- join tables by order id
group by c.company, c.country -- grouping by company and country
order by totalSales desc; -- Sort by sales amount from highest to lowest

-- 3.2 Customer analysis by period

select
	month(o.order_date) AS orderMonth,
    c.company, 
    c.country,
    ROUND(SUM(od.quantity * od.unit_price * (1 - od.discount / 100)), 2) AS totalSales, -- calculates the discount factor and rounds it to two digits
    p.category as productCategory
from orders o
join customers c on o.customer_id = c.id -- join tables by customer id 
join order_details od on o.id = od.order_id -- join tables by order id
join products p on od.product_id = p.id
group by month(o.order_date), c.company, c.country, p.category -- grouping by month, company, country and products category
order by orderMonth, totalSales desc; -- sort by month and sales amount from highest to lowest

-- 4.  Analysis of the impact of discounts

select
    case 
        WHEN od.discount = 0 THEN '0%'
        WHEN od.discount BETWEEN 0.01 AND 3 THEN '1-3%'
        WHEN od.discount BETWEEN 3.01 AND 6 THEN '4-6%'
        WHEN od.discount BETWEEN 6.01 AND 10 THEN '7-10%'
        ELSE '10%+' 
    END AS discountRange,
    ROUND(SUM(od.quantity * od.unit_price * (1 - od.discount / 100)), 2) AS totalSales, -- estimated sales amount with discounts and round to two decimal places
    COUNT(*) AS orderLines
from order_details od
group by discountRange -- grouping by discount range 
order by totalSales DESC; -- sort by sales amount from highest to lowest 
    
-- 5.  Order delivery analysis
-- 5.1 Which countries are most often delivered to

select
	o.ship_country, -- shipping country 
	count(distinct o.id) as totalOrders, -- how many unique orders to that country 
	round(sum(od.quantity * od.unit_price * (1 - od.discount / 100)), 2) as totalSales -- estimated sales amount with discounts and round to two decimal places
from orders o
join order_details od ON o.id = od.order_id -- join tables by order id
group by o.ship_country -- grouping by ship country
order by totalSales; -- sort by total sales amount from highest to lowest

-- 5.2 Sales by delivery country

select 
	o.ship_country as country, -- the country to which the order was delivered
	count(distinct o.id) as totalOrders, -- counts unique orders 
	round(sum(od.quantity * od.unit_price * (1 - od.discount / 100)), 2) as totalSales -- estimated sales amount with discounts and round to two decimal places
from orders o
join order_details od on o.id = od.order_id -- join tables by order id
group by o.ship_country -- grouping by ship country
order by totalSales desc; -- sort by total sales amount from highest to lowest

-- 6.  Product category analysis

select 
	p.category,  -- product category
	count(distinct od.order_id) as totalOrders, -- how many unique orders included products from this category 
	sum(od.quantity) as totalQuantyti, -- how many units were sold in total 
	round(sum(od.quantity * od.unit_price * (1 - od.discount / 100)), 2) as totalSales -- estimated sales amount with discounts and round to two decimal places
from order_details od
join products p on od.product_id = p.id -- join tables by product id
group by p.category -- grouping by product category
order by totalSales; desc -- sort by total sales amount from highest to lowest

