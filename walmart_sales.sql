create database if not exists salesDataWalmart;

create table if not exists sales (
    invoice_id varchar(30) not null primary key,
    branch varchar(5) not null,
    city varchar(30) not null,
    customer_type varchar(30) not null,
    gender varchar(10) not null,
    product_line varchar(100) not null,
    unit_price decimal(10, 2) not null,
    quantity int not null,
    vat decimal(6, 4) not null,
    total decimal(12, 2) not null,
    sale_date date not null,
    sale_time time not null,
    payment_method varchar(15) not null,
    cogs decimal(10, 2) not null,
    gross_margin_pct decimal(5, 4) not null,
    gross_income decimal(10, 2) not null,
    rating decimal(3, 1) not null
);

-- -------------------------------------------------- feature engineering --------------------------------------------------------
-- time of day
select
    sale_time,
    case
        when sale_time < '12:00:00' then 'morning'
        when sale_time < '16:00:00' then 'afternoon'
        else 'evening'
    end as time_of_day
from sales;

alter table sales add column time_of_day varchar(20);

update sales
set time_of_day = (
	case
        when sale_time < '12:00:00' then 'morning'
        when sale_time < '16:00:00' then 'afternoon'
        else 'evening'
    end
);

select time_of_day
from sales;

-- day name
select sale_date, dayname(sale_date)
from sales;

alter table sales add column day_name varchar(10);

update sales
set day_name = dayname(sale_date);

select *
from sales;

-- month_name
select sale_date, monthname(sale_date)
from sales;

alter table sales
add column month_name varchar(12);

update sales
set month_name = monthname(sale_date);

select *
from sales;


-- ----------------------------- exploratory data analysis ---------------------------------------------

-- how many unique cities are in the data?
select count(distinct city)
from sales;

select distinct city
from sales;
-- there are three unique cities (yangon, naypyitaw, mandalay)

-- in which city is every branch?
select distinct city, branch
from sales;
-- (yangon: A, naypyitaw: C, mandalay: B)

-- how many unique products lines does the data have
select count(distinct product_line)
from sales;

select distinct product_line
from sales;
-- we have 6 unique product lines

-- what is the most common payment method?
select payment_method, count(payment_method) as cnt
from sales
group by payment_method
order by cnt desc
;
-- common payment method is the e-wallet method with 345 counts

-- what is the most selling product line/
select product_line, count(product_line) as cnt
from sales
group by product_line
order by cnt desc;
-- most selling product_line is fashion accesories with 178 counts

-- what is the total revenue by month
select sum(total) as total_revenue, month_name
from sales
group by month_name
order by total_revenue desc;
-- january: 116292.11, february: 97219.58, march: 109455.74

-- what month had the largest cogs?
select month_name, sum(cogs) as cogs
from sales
group by month_name
order by cogs desc;
-- january had the most cogs at 110754.16

-- what product line has the largest revenue?
select product_line, sum(total) as total_revenue
from sales
group by product_line
order by total_revenue desc;
-- the product line with the largest revenue is food and beverages at 56144.96

-- what is the city wth the largest revenue?
select city, sum(total) as total_revenue
from sales
group by city
order by total_revenue desc;
-- the city with the largest revenue is Naypyitaw wit a total of 110568.86

-- what is the product line with the largest vat
select product_line, avg(vat) as avg_vat
from sales
group by product_line
order by avg_vat desc;
-- the product_line with the largest vat is Home and Lifestyle with an of 16.03 vat

-- fetch each product_line and add a column to those product line showing "good", "bad". good if its greater thn average sales
select product_line;

-- which branch sold more products than average product sold?
select avg(quantity)
from sales;
-- average quantity sold: 5.51

select branch, sum(quantity) as qty
from sales
group by branch
having sum(quantity) > (select avg(quantity) from sales)
;
-- all branch sold products above the average quantity
-- branch A: 1859, branch B: 1831, branch C: 1820

-- what is the most common product line by gender?
select gender, product_line, count(gender) as gender_count
from sales
group by gender, product_line
order by gender_count desc;

-- what is the average rating of each product_line
select product_line, round(avg(rating), 2) as avg_rating
from sales
group by product_line
order by avg_rating desc
;
-- food and beverages: 7.11
-- fashion accessories; 7.03
-- health and beauty: 7.00
-- sports and travel: 6.92
-- electronic accessories: 6.92
-- home and lifestyle: 6.84

select *
from sales;