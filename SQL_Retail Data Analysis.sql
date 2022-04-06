/*
Business Context
A retail store would like to understand customer behavior using their point of sale data (POS).

Data Availability
The data set we will be using for this exercise comprises of 3 tables:

Customer: Customer demographics
Transactions: Customer transaction details
Product category: Product category and sub category information 
*/
-----------------------------------------------------------------------------------------------
/* CREATING DATABASE */

CREATE DATABASE SQL_CASE_STUDY

USE SQL_CASE_STUDY

/* Viewing all table contents */
select * from Customer
select * from prod_cat_info
select * from Transactions

-----------------------------------------------------------------------------------------------

/* (A) DATA PREPARATION AND UNDERSTANDING */

/* A1.	What is the total number of rows in each of the 3 tables in the database? */

select count(customer_id) as 'No_of_Rows_in_Customer' from Customer

select count(prod_cat_code) as 'No_of_Rows_in_prod_cat_info' from prod_cat_info

select count(transaction_id) as 'No_of_Rows_in_Transactions' from Transactions


/* A2.	What is the total number of transactions that have a return? */

select count(transaction_id) as 'No_of_transactions_having_return' from Transactions
where Qty < 0


/* A3.	What is the time range of the transaction data available for analysis? 
        Show the output in number of days, months and years simultaneously in different columns.  */

select min(tran_date) as 'Start_date',
 max(tran_date) as 'End_date', 
 datediff(dd,min(tran_date),max(tran_date)) as 'Difference_in_days',
 datediff(mm,min(tran_date),max(tran_date)) as 'Difference_in_months',
 datediff(yy,min(tran_date),max(tran_date)) as 'Difference_in_years'
 from Transactions


 /* A4.	Which product category does the sub-category “DIY” belong to? */

 select prod_cat, prod_subcat from prod_cat_info
 where prod_subcat = 'DIY'

 -------------------------------------------------------------------------------------------------------------

 /* (B) DATA ANALYSIS */

 /* B1.	Which channel is most frequently used for transactions? */
 
 select Store_type,
 count(transaction_id) as 'Frequecy'
 from Transactions
 group by Store_type
 order by count(transaction_id) desc


 /* B2.	What is the count of Male and Female customers in the database? */

 select Gender,
 count(customer_Id) as 'count_of_gender' 
 from Customer
 group by Gender


 /* B3.	From which city do we have the maximum number of customers and how many? */

select
count(tbl1.city_code) as 'No_of_Customers',
city_code
from
(select 
city_code,customer_id,
count(customer_Id) as 'count_of_customer'
from
Customer inner join Transactions
on customer_Id = cust_id
group by city_code, customer_Id) as tbl1 
group by tbl1.city_code
order by count(tbl1.city_code) desc


/* B4.	How many sub-categories are there under the Books category? */

select distinct prod_subcat from prod_cat_info
where prod_cat = 'Books'


/* B5.	What is the maximum quantity of products ever ordered? */ 

select * from Transactions
where Qty = (select max(Qty) from Transactions)


/* B6.	What is the net total revenue generated in categories Electronics and Books? */

select prod_cat,
sum(total_amt) as 'net_total_revenue_generated'
from
Transactions inner join prod_cat_info
on Transactions.prod_subcat_code = prod_cat_info.prod_sub_cat_code and Transactions.prod_cat_code = prod_cat_info.prod_cat_code
where prod_cat in ('Electronics','Books')
group by prod_cat


/* B7.	How many customers have >10 transactions with us, excluding returns? */

select cust_id,
count(transaction_id) as 'no_of_transactions'
from Transactions
where total_amt > 0
group by cust_id
having count(transaction_id) > 10


/* B8.	What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”? */

select
sum(total_amt) as 'combined_revenue_Electronics_&_Clothing'
from
Transactions inner join prod_cat_info
on Transactions.prod_subcat_code = prod_cat_info.prod_sub_cat_code and Transactions.prod_cat_code = prod_cat_info.prod_cat_code
where Store_type = 'Flagship store' and prod_cat in ('Electronics','Clothing')


/* B9.	What is the total revenue generated from “Male” customers in “Electronics” category?
        Output should display total revenue by prod sub-cat. */

select
prod_subcat,
sum(total_amt) as 'total_revenue_from_male_customers'
from
Customer inner join Transactions
on Customer.customer_Id = Transactions.cust_id
inner join prod_cat_info
on Transactions.prod_subcat_code = prod_cat_info.prod_sub_cat_code and Transactions.prod_cat_code = prod_cat_info.prod_cat_code
where Gender = 'M' and prod_cat = 'Electronics'
group by prod_subcat


/* B10.	Display only top 5 sub categories in terms of sales? */

select top 5
prod_subcat,
sum(total_amt) as 'Sales_Amount'
from
Transactions inner join prod_cat_info
on Transactions.prod_subcat_code = prod_cat_info.prod_sub_cat_code and Transactions.prod_cat_code = prod_cat_info.prod_cat_code
group by prod_subcat
order by sum(total_amt) desc


/* B11.	For all customers aged between 25 to 35 years
        find what is the net total revenue generated by these consumers in last 30 days of transactions
		from max transaction date available in the data? */

select 
sum(total_amt) as 'last_30_days_revenue(age 25-35)'
from
(
select
*,
datediff(yy,DOB,getdate()) as 'Age'
from
Customer inner join Transactions
on customer_Id = cust_id
where tran_date > (select dateadd(dd,-30,(select max(tran_date) from Transactions)))
) as tbl3
where Age between 25 and 35


/* B12.	Which product category has seen the max value of returns in the last 3 months of transactions? */

select
prod_cat,
sum(total_amt) as 'total_returned_amount'
from
Transactions inner join prod_cat_info
on Transactions.prod_subcat_code = prod_cat_info.prod_sub_cat_code and Transactions.prod_cat_code = prod_cat_info.prod_cat_code
where tran_date > (select dateadd(mm,-3,max(tran_date)) from Transactions) and total_amt < 0
group by prod_cat
order by sum(total_amt) asc


/* B13.	Which store-type sells the maximum products; by value of sales amount and by quantity sold? */

select 
Store_type,
sum(cast(Qty as int)) as 'Qty_sold'
from Transactions
group by Store_type
order by sum(cast(Qty as int)) desc

select 
Store_type,
sum(total_amt) as 'sales_amount'
from Transactions
group by Store_type
order by sum(total_amt) desc


/* B14.	What are the categories for which average revenue is above the overall average. */

select * 
from
(
select
prod_cat,
avg(total_amt) as 'avg_revenue'
from
Transactions inner join prod_cat_info
on Transactions.prod_subcat_code = prod_cat_info.prod_sub_cat_code and Transactions.prod_cat_code = prod_cat_info.prod_cat_code
group by prod_cat
) as tbl4
where avg_revenue > (select avg(total_amt) from Transactions)


/* B15.	Find the average and total revenue by each subcategory for the categories which are among top 5 categories
        in terms of quantity sold. */

select
prod_subcat,
avg(total_amt) as 'Avg_Revenue',
sum(total_amt) as 'Total_Revenue'
from
Transactions inner join prod_cat_info
on Transactions.prod_subcat_code = prod_cat_info.prod_sub_cat_code and Transactions.prod_cat_code = prod_cat_info.prod_cat_code
where prod_cat in
(select top 5
prod_cat
from
Transactions inner join prod_cat_info
on Transactions.prod_subcat_code = prod_cat_info.prod_sub_cat_code and Transactions.prod_cat_code = prod_cat_info.prod_cat_code
group by prod_cat
order by sum(cast(Qty as int)) desc)
group by prod_subcat

--------------------------------------------------------------------------------------------------------------------------





























