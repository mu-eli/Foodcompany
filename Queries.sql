/* List all last names beginning with the letter M */
select * from customers
where last_name like 'M%';

/* List all customers with B in their first name*/
select * from customers
where first_name like '%b%';

/* Allows multiple conditions in a single bracket. List customers from USA, France & Germany */
select * from customers
where country in ('USA', 'France', 'Germany');

/* List customers not from USA, France & Germany */
select * from customers
where country not in ('USA', 'France', 'Germany');

/* Unique list of customers' cities */
select distinct city from customers;

/* Customer list in ascending order by last name */
select * from customers
order by last_name;

/* List of employees with an I in their first name ordered in ascending order by last name */
select * from employees
where first_name like '%i%'
order by last_name;

/* Displays the speicifed columns from both the customers and orders table */
select e1.customerID, e1.first_name, e1.last_name, e2.order_date, e2.payment_method, e2.total_amount from customers e1
join orders e2 on 
e1.customerID = e2.customerID;

/* Return results with same columns and in the same order */
select * from shippers
union all
select * from suppliers;

/* Sums up columns with the same date by grouping them*/
select paymentdate, sum(total_amount) as total from orders
group by paymentdate;

/* List all customer payments over 3000 and arrange them in ascending order by payment date */
select paymentdate, sum(total_amount) as total from orders
group by paymentdate
having total > 3000
order by paymentdate;

/* Counts the number of orders shipped on the selected date */
select count(orderID) as orders  from orders
where shipping_date = '2008-01-30';

/* Shows the max and min amount on the specified day */
select 
paymentdate, 
max(total_amount) as highest_amount,
min(total_amount) as lowest_amount
from orders
group by paymentdate
having paymentdate = '2015-02-26';

/* Displays the average amount for each date rounded off to one decimal place. Arranged in ascending order */
select paymentdate, round(avg(total_amount),1) as recieved_payment
from orders
group by paymentdate
order by paymentdate;

/* joins customers and orders table then Shows the customers' name with the most amount of orders made */
select first_name, count(orderID) as orders from customers b1
join orders b2
on b1.customerID = b2.customerID
group by first_name
order by orders desc
limit 1;

/* Shows customers' first name with their first and last order */
select first_name, min(order_date) as first_order, max(order_date) as last_order from customers b1
join orders b2
on b1.customerID = b2.customerID
group by first_name;

/* Average orders made in a day after the specified date using subquery */
select round(avg(ord),2) from
(select order_date, count(orderID) as ord from orders
group by order_date) t1
where order_date > '2008-01-06';

with average_order as (select order_date, count(orderID) ord from orders
group by order_date)
select round(avg(ord), 1) from average_order;

/* Displays the highest and lowest discount of each order */
select order_detailID, max(discount) as highest_discount, min( discount) as lowest_discount 
from orderdetails
group by order_detailID;

/* Displays the highest and lowest discount of each order in descending order */
with t1 as
(select order_detailID, max(discount) as highest_discount, min( discount) as lowest_discount 
from orderdetails
group by order_detailID)
select order_detailID, highest_discount, lowest_discount from t1
order by highest_discount, lowest_discount desc;

/* Displays the status for all the orders */
select
case when order_status = 'Delivered' then 'a: Delivered to customer'
when order_status = 'Pending' then 'b: Not yet delivered'
when order_status = 'Cancelled' then 'c: Cancelled by customer'
when order_status = 'Shipped' then 'd: In route to costumer'
when order_status = 'Processing' then 'e: Being Processed by company'
else 'other' end as package_status,
count(distinct c.orderID) as packages
from foodcompany.orders c
group by package_status;

/* Shows how many orders were made for each given range */
select 
case when total_amount between 1000 and 20000 then '1000 - 20000'
when total_amount between 20000 and 40000 then '20000 - 60000'
when total_amount between 40000 and 60000 then '40000 - 60000'
when total_amount between 60000 and 80000 then '60000 - 80000'
else 'Other' end as order_range,
count(distinct c.order_detailID) as price_range
from foodcompany.orderdetails c
group by order_range;

/* Flags all orders that meet both conditions in the case statement */
select e1.orderID, order_date, e2.quantity, e2.total_amount,
case when quantity > 1000 and e2.total_amount > 10000 then 'Yes' else 'No' end as excess_purchase
from orders e1
join orderdetails e2
on e1.orderID = e2.orderID;

with exc_purchase as
(select e1.orderID, order_date, e2.quantity, e2.total_amount,
case when quantity > 1000 and e2.total_amount > 10000 then 'Yes' else 'No' end as excess_purchase
from orders e1
join orderdetails e2
on e1.orderID = e2.orderID)
select * from exc_purchase
order by order_date;

/* flags all the orders that were either paid in cash or delivered */
select *, 
case when payment_method = 'Cash' or order_status = 'delivered' then 'true' else 'false' end as paid_cash
from orders;

/* multiple flag statements */
select *, case when shipping_method = 'International' then 1 else 0 end as ship_method,
case when shipping_date > '2019-03-20' then 1 else 0 end as ship_date,
case when total_amount >= 5000 then 1 else 0 end as fee
from orders;

/* Lists each customers orders in a set ordered by date from oldest to newest */
select e1.customerID, last_name, first_name, orderID, order_date,
row_number() over(partition by customerID order by order_date) as purchases_made
from customers e1
join orders e2 on e1.customerID = e2.customerID;

/* Accesses data in the next row of ordered output. Lists the payments made by each customer after the first payment */
select customerID, orderID, order_date, total_amount,
lead(total_amount) over (partition by customerID order by order_date) as next_payment
from orders;

/* Accesses data in the previous row of ordered output. Lists payments made previously */
select customerID, orderID, order_date, total_amount,
lag (total_amount) over ( partition by customerID order by order_date) as prev_payment
from orders;

/* Lists payments made previously by the specified customer */
with pre_payment as
(select customerID, orderID, order_date, total_amount,
lag (total_amount) over ( partition by customerID order by order_date) as prev_payment
from orders)
select * from pre_payment
where customerID = '1';

/* Gives the difference from each previous payment made */
with pre_payment as
(select customerID, orderID, order_date, total_amount,
lag (total_amount) over ( partition by customerID order by order_date) as prev_payment
from orders)
select *, total_amount - prev_payment as diff
from pre_payment;

/* Displays the second orders made by each employee and the date it was made */
with made_orders as
(select order_date, orderID, employeeID,
row_number() over (partition by employeeID order by orderID) as orders_made
from orders e1
join customers e2 on e1.customerID = e2.customerID)
select * from made_orders
where orders_made = '2';




