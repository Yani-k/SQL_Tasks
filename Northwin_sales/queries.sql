--1 Show the categoryname and description from the categories table sorted by category_name.

SELECT categoryname, description
FROM categories
ORDER BY categoryname 

--2 Exclusion
--Show all the contactname, address, city of all customers which are not from 'Germany', 'Mexico', 'Spain'

SELECT contactname, address, city
FROM customers
WHERE country NOT IN ('Germany','Mexico', 'Spain')

--3 Filter + Dates
--Show orderdate, shippeddate, customerid, Freight of all orders placed on 1996-07-08

SELECT orderdate, shippeddate, customerid, freight
FROM orders
WHERE orderdate ='1996-07-08'

--4 Filter + Dates
--Show the employee_id, order_id, customer_id, required_date, shipped_date from all orders shipped later than the required date
SELECT employeeid, orderid, customerid, requireddate, shippeddate
FROM orders
WHERE shippeddate > requireddate

--5 Filter + Even Number
--Show all the even numbered Order_id from the orders table
SELECT orderid
FROM orders
WHERE MOD(orderid, 2)=0


--6 Show the city, company_name, contact_name of all customers from cities which contains the letter 'L' in the city name, sorted by contact_name

SELECT city, companyname, contactname
FROM customers
WHERE LOWER(city) LIKE '%l%' --Lower is needed so capital Ls will also be considered
ORDER BY contactname

-- 7 Show the company_name, contact_name, fax number of all customers that has a fax number. (not null)
SELECT companyname, contactname, fax
FROM customers
WHERE fax IS NOT null

--8 Show the first_name, last_name. hire_date of the most recently hired employee.

SELECT firstname, lastname, hiredate
FROM employees	
WHERE hiredate = (SELECT max(hiredate) FROM employees)


--9 Show the average unit price rounded to 2 decimal places, the total units in stock, total discontinued products from the products table.
--casted as :: numeric because AVG returns 'double prcision' type

SELECT ROUND(AVG(unitprice)::numeric,2), SUM(unitsinstock), SUM(discontinued)
FROM products

-- 10 Multiple Joins
--Show the ProductName, CompanyName, CategoryName from the products, suppliers, and categories table

SELECT p.productname, s.companyname, c.categoryname 
FROM products p
JOIN suppliers s ON s.supplierid = p.supplierid
JOIN categories c On c.categoryid = p.categoryid

-- 11 Joins + Aggregate
--Show the category_name and the average product unit price for each category rounded to 2 decimal places.

SELECT c.categoryname, ROUND(AVg(p.unitprice)::numeric,2) as averageunitprice 
FROM categories c
JOIN products p On c.categoryid = p.categoryid
group by c.categoryname

-- 12 UNION (Joining 2 queries)
--Show the city, company_name, contact_name from the customers and suppliers table merged together.
--Create a column which contains 'customers' or 'suppliers' depending on the table it came from.
  		
SELECT city, companyname, contactname, 'customers' AS relationship 
FROM customers
UNION
SELECT city, companyname, contactname, 'suppliers' AS relationship 
FROm suppliers

-- 12 DATEs in Postgress using EXTRACT
--Show the total amount of orders for each year/month.

SELECT 
EXTRACT(YEAR FROM orderdate) AS order_year, EXTRACT(MONTH FROM orderdate) AS order_month, COUNT(*) AS number_of_orders
FROM orders
GROUP BY 1,2


--14 JOIN + CASE WHEN
--Show the employee's first_name and last_name, a "num_orders" column with a count of the orders taken, and a column called "Shipped" that displays "On Time" if the order shipped_date is less or equal to the required_date, "Late" if the order shipped late, "Not Shipped" if shipped_date is null.

Order by employee last_name, then by first_name, and then descending by number of orders.

SELECT e.firstname, e.lastname, Count(*) as num_orders, 
CASE 
WHEN shippeddate <= requireddate THEN 'On time'
WHEN shippeddate > requireddate THEN 'Late'
ELSE 'Not Shipped' END AS status
FROM orders o
JOIN employees e on e.employeeid=o. employeeid
GROUP BY e.firstname, e.lastname, status
ORDER BY e.lastname, e.firstname, num_orders DESC

-- 15  DATES + ROUND 
--Show how much money the company lost due to giving discounts each year, order the years from most recent to least recent. Round to 2 decimal places 
SELECT  EXTRACT(YEAR FROM orderdate) as order_year, ROUND(SUM(unitprice*quantity*discount):: numeric,2) as discount_amount
FROM order_details od
JOIN orders o ON o.orderid=od.orderid
GROUP BY order_year



