-- 1. Get number of monthly active customers.
select * from rental;

create or replace view sakila.customer_activity as
select customer_id, rental_date as Activity_Date,
date_format(convert(rental_date, date), '%m') as Activity_Month,
date_format(convert(rental_date, date), '%Y') as Activity_Year
from sakila.rental;

select * from sakila.customer_activity;

create or replace view sakila.monthly_active_customers as
select Activity_Year, Activity_Month, count(distinct customer_id) as Active_Customers
from sakila.customer_activity
group by Activity_Year, Activity_Month;

select * from sakila.monthly_active_customers;

-- 2. Active users in the previous month.
create or replace view sakila.previous_month_active_customers as
select Activity_Year, Activity_Month, Active_Customers,
lag(Active_Customers) over (order by Activity_Year, Activity_Month) as Last_Month
from sakila.monthly_active_customers;

select * from sakila.previous_month_active_customers;

-- 3. Percentage change in the number of active customers.
select Activity_Year, Activity_Month, Active_Customers,
lag(Active_Customers) over (order by Activity_Year, Activity_Month) as Last_Month,
(Active_Customers / Last_Month -1) * 100 as Percentage_Change
from sakila.previous_month_active_customers;

-- 4. Retained customers every month.
-- step 1: get the unique active users per month
create or replace view customer_activity2 as
select distinct customer_id as Active_Customer, Activity_Year, Activity_Month
from sakila.customer_activity
order by Activity_Year, Activity_Month, customer_id;

select * from customer_activity2;

create or replace view sakila.retained_customers as
select c1.Active_Customer, c1.Activity_Year, c1.Activity_Month, c2.Activity_Month as Previous_Month 
from sakila.customer_activity2 c1 join sakila.customer_activity2 c2
on c1.Activity_Year = c2.Activity_Year
and c1.Activity_Month = c2.Activity_Month + 1 
and c1.Active_Customer = c2.Active_Customer
order by Activity_Year, Activity_Month, Active_Customer;

select * from sakila.retained_customers;

create or replace view sakila.total_retained_customers as
select Activity_Year, Activity_Month, count(Active_Customer) as Retained_Customers
from sakila.retained_customers
group by Activity_Year, Activity_Month;

select * from sakila.total_retained_customers;