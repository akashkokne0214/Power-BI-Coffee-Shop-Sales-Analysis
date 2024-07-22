create database coffee_shop_sales_db

show databases

use coffee_shop_sales_db

show tables

select * from coffee_shop_sales

describe coffee_shop_sales

update coffee_shop_sales
set transaction_date = STR_TO_DATE(transaction_date, '%d-%m-%Y');

Alter table coffee_shop_sales modify column transaction_date DATE;

SET SQL_SAFE_UPDATES = 0;

describe coffee_shop_sales

update coffee_shop_sales modify column transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s') 

Alter table coffee_shop_sales modify column transaction_time TIME

describe coffee_shop_sales

alter table coffee_shop_sales change column ï»¿transaction_id transaction_id INT 

describe coffee_shop_sales

##Total sales analysis:
#1.Calculate the total sales for each respective month
-- select round(sum(unit_price * transaction_qty),1) AS Total_Sales from coffee_shop_sales
-- where
-- month(transaction_date) = 3 -- MAY MONTH

select 
sum(unit_price * transaction_qty) AS Total_Sales 
from 
coffee_shop_sales
where
month(transaction_date) = 3 -- MAY MONTH

select 
concat((round(sum(unit_price * transaction_qty)))/1000, "K") AS Total_Sales 
from 
coffee_shop_sales
where
month(transaction_date) = 3

#2.Determine the month-on-month increase or decrease in sales.
#3.Calculate the difference in sales between the salected month and the previous month.
select
month(transaction_date) as month, -- No of month
round(sum(unit_price * transaction_qty)) as total_sales, -- total sales column
(sum(unit_price * transaction_qty) - lag(sum(unit_price * transaction_qty), 1) -- month sales difference
over (order by month(transaction_date)))/lag(sum(unit_price * transaction_qty), 1) -- division by PM sales
over (order by month(transaction_date)) * 100 as mom_increase_percentage -- percentage
from 
coffee_shop_sales
where
month(transaction_date) in (4,5)
group by
month(transaction_date)
order by
month(transaction_date)

##Total Order Analysis:
#4.Calculate the total no. of orders for each respective month.
select 
count(transaction_id) as total_orders
from 
coffee_shop_sales
where
month(transaction_date) =3 -- MARCH MONTH

#5.Determime the month-on-month increase or decrease in the no. of orders.
#6.Calculate the difference in the no. of orders between the selected month & the previous month.
select
month(transaction_date) as month,
round(sum(transaction_id)) as total_orders,
(count(transaction_id) - lag(count(transaction_id),1)
over (order by month(transaction_date))) / lag(count(transaction_id),1)
over (order by month(transaction_date)) * 100 as mom_increase_percentage
from
coffee_shop_sales
where
month(transaction_date) in (4,5)
group by
month(transaction_date)
order by
month(transaction_date)

##Total Quantity Sold Analysis:
#7.Calculate the total quantity sold for each respective month.
select sum(transaction_qty) as total_quantity_sold
from coffee_shop_sales
where
month(transaction_date) = 5 -- MAY MONTH

#8.Determime the month-on-month increase or decrease in the total quantity sold.
#9.Calculate the difference in the total quantity sold between the selected month & the previous month.
select 
month(transaction_date) as month,
round(sum(transaction_qty)) as total_quantity_sold,
(sum(transaction_qty) - lag(sum(transaction_qty), 1)
over (order by month(transaction_date))) / lag(sum(transaction_qty), 1)
over (order by month(transaction_date)) * 100 as mom_increase_percentage
from
coffee_shop_sales
where
month(transaction_date) in (4,5) -- for april and may
group by
month(transaction_date)
order by
month(transaction_date)

## Calendar Heat Map:
#10.Implement a calender heat map that dynamically ajdusts based on the selected month from a sclier.
#11.Each day on the calender will be color-coded to represent sales volumn, with darker shades indicating higher sales.
#12.Implement tooltips to display detailed metrics (Sales, Order, Quantity) when hovering over a specific day.
select 
concat(round(sum(unit_price * transaction_qty)/1000,1), 'K') as Total_sales,
concat(round(sum(transaction_qty)/1000,1),'K') as Total_Qty_Sold,
concat(round(count(transaction_id)/1000,1),'K') as Total_Orders
from coffee_shop_sales
where
transaction_date = '2023-03-27'

##Sales Analysis by Weekdays and Weekends:
#13.Segment sales data into weekdays and weekends to analyse performance variation.
#14.Provide insights into whether sales patterns differ significantly between weekdays and weekends.
select
case when dayofweek(transaction_date) in (1,7) then 'Weekends'
else 'weekdays'
end as day_types,
concat(round(sum(unit_price * transaction_qty)/1000,1), 'K') as Total_sales
from coffee_shop_sales
where month(transaction_date) = 5  -- May Month
group by
case when dayofweek(transaction_date) in (1,7) then 'weekends'
else 'weekdays'
end

##Sales Analysis by store Location:
select
store_location,
concat(round(sum(unit_price * transaction_qty)/1000,1), 'K') as Total_Sales
from coffee_shop_sales
where month(transaction_date) = 5 -- May
group by store_location
order by sum(unit_price * transaction_qty) desc

##Daily Sales Analysis with average line:
select concat(round(avg(total_sales)/1000,1),'K') as Avg_Sales
from 
(
select sum(transaction_qty * unit_price) as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by transaction_date
) as internal_query

#Daily Sales
select
day(transaction_date) as day_of_month,
sum(unit_price * transaction_qty) as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by day(transaction_date)
order by day(transaction_date)

select
day_of_month,
case
when total_sales > avg_sales then 'Above Average'
when total_sales < avg_sales then 'Below Average'
else 'Average'
end as sales_status,
total_sales
from(
select
day(transaction_date) as day_of_month,
sum(unit_price * transaction_qty) as total_sales,
avg(sum(unit_price * transaction_qty)) over() as avg_sales
from
coffee_shop_sales
where
month(transaction_date) = 5
group by
day(transaction_date)
) as sales_data
order by
day_of_month

## Sales Analysis by Sales Category:
select
product_category,
concat(round(sum(unit_price * transaction_qty)/1000,1),'K') as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by product_category
order by sum(unit_price * transaction_qty) desc


## Top 10 Products by Sales:
select
product_type,
concat(round(sum(unit_price * transaction_qty)/1000,1),'K') as total_sales
from coffee_shop_sales
where month(transaction_date) = 5 and product_category ="Coffee"
group by product_type
order by sum(unit_price * transaction_qty) desc

##Sales Analysis by days & hours:
select
concat(round(sum(unit_price * transaction_qty)/1000,1),'K') as total_sales,
concat(round(sum(transaction_qty)/1000,1),'K') as total_qty_sold,
count(*) as Total_Orders
from coffee_shop_sales
where month(transaction_date) = 5
and dayofweek(transaction_date) = 1  -- Monday
and hour(transaction_time) = 14 -- no. of hrs


select
hour(transaction_time),
sum(unit_price * transaction_qty) as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by hour(transaction_time)
order by hour(transaction_time)

select
case
when dayofweek(transaction_date) = 2 then 'Monday'
when dayofweek(transaction_date) = 3 then 'Tuesday'
when dayofweek(transaction_date) = 4 then 'Wednesday'
when dayofweek(transaction_date) = 5 then 'Thursday'
when dayofweek(transaction_date) = 6 then 'Friday'
when dayofweek(transaction_date) = 7 then 'Saturday'
else 'Sunday'
end as Day_of_Week,
round(sum(unit_price * transaction_qty)) as Total_Sales
from
coffee_shop_sales
where
month(transaction_date) = 5
group by
case
when dayofweek(transaction_date) = 2 then 'Monday'
when dayofweek(transaction_date) = 3 then 'Tuesday'
when dayofweek(transaction_date) = 4 then 'Wednesday'
when dayofweek(transaction_date) = 5 then 'Thursday'
when dayofweek(transaction_date) = 6 then 'Friday'
when dayofweek(transaction_date) = 7 then 'Saturday'
else 'Sunday'
end;
