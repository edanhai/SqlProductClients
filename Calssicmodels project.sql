-- Calculate the average order amount for each country
select country,avg(priceEach * quantityOrdered) as avg_order_value
from customers c
inner join orders o on c.customerNumber = o.customerNumber
inner join orderdetails od on o.orderNumber = od.orderNumber
group by country
order by avg_order_value desc;

-- Calculte the total sales amount for each prduct line
select productLine, sum(priceEach * quantityOrdered) as sales_value
from orderdetails od
inner join products p on od.productCode = p.productCode
group by productLine;

-- List the top 10 best selling prducts based on total quantity sold
select productName,sum(quantityOrdered) as units_sold
from orderdetails od
inner join products p on od.productCode = p.productCode
group by productName
order by units_sold desc
limit 10
;

-- Evaluate the sales preformace of each sales represetative
select e.firstName,e.lastName, sum(quantityOrdered*priceEach) as order_value
from employees e
inner join customers c
on employeeNumber = salesRepEmployeeNumber and e.jobTitle = 'Sales Rep'
left join orders o 
on c.customerNumber = o.customerNumber
left join orderdetails od
on o.orderNumber = od.orderNumber
group by e.firstName,e.lastName 
;

-- Calculate the average number of orders placed by each customer
select count(o.orderNumber)/count(distinct c.customerNumber)
from customers c
left join orders o
on c.customerNumber = o.customerNumber;


-- Calculate the precentage of orders that were shipped on time
select sum(case when shippedDate <= requiredDate then 1 else 0 end)/count(orderNumber)*100 as perecent_on_time
from orders;

-- Calclate the profit margin for each produnt by subtracting the cost of goods sold (COGS) from each revnue
select productName,sum((priceEach*quantityOrdered) - (buyPrice * quantityOrdered)) as net_profit
from products p 
inner join orderdetails o 
on p.productCode = o.productCode
group by productName;


-- Segment customers baesed on their total pruchase amount
select c.*,customer_segment
from customers c
left join
(select *,
case when total_purchase_value > 100000 then 'high value'
	when total_purchase_value between 50000 and 100000 then 'medium value'
    when total_purchase_value < 50000 then 'low value'
else 'other' end as customer_segment
from 
	(select customerNumber, sum(priceEach*quantityOrdered) as total_purchase_value
	from orders o 
	inner join orderdetails od
	on o.orderNumber = od.orderNumber
	group by customerNumber)t1
	)t2
on c.customerNumber = t2.customerNumber;

-- Identify frequently co-purchased products to understand cross selling opportunities
select od.productCode, p.productName, od2.productCode, p2.productName, count(*) as purchased_together
from orderdetails od
inner join orderdetails od2
on od.orderNumber = od2.orderNumber and od.productCode <> od2.productCode
inner join products p 
on od.productCode = p.productCode
inner join products p2
on od2.productCode = p2.productCode
group by od.productCode, p.productName, od2.productCode, p2.productName
order by purchased_together desc;

