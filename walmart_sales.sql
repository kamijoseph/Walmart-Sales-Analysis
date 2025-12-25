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
-- ----------------------------- products analysis -------------------------------------------------
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

-- ----------------------------- sales analysis -------------------------------------------------

-- find number of sales made in each time of the day per weekday
select time_of_day, count(*) as total_sales
from sales
where day_name = "Monday" -- replace Monday with all weekdays to find sale for each time per weekday
group by time_of_day
order by total_sales desc;

-- which customer type brings the most revenue?
select customer_type, avg(total) as avg_total, sum(total) as total_revenue
from sales
group by customer_type
order by total_revenue desc;
-- memberr type brings most revenue (avg: 327.79, total_revenue: 164223)

-- which city has the largest VAT?
select city, round(avg(vat), 2) as avg_vat
from sales
group by city
order by avg_vat desc;
-- naypyitaw has the largest average VAT: 16.05

-- which customer type pays the most in vat?
select customer_type, round(avg(vat), 2) as avg_vat
from sales
group by customer_type
order by avg_vat desc;
-- member type pays the most in vat: 15.61

-- ----------------------------- customer analysis -------------------------------------------------

-- how many unique customers does the data have?
select count(distinct customer_type)
from sales;

select distinct customer_type
from sales;
-- there is 2 distinct customer type (normal, member)

-- how many unique payment methods does the data have?
select count(distinct payment_method)
from sales;

select distinct payment_method
from sales;
-- there are 3 payment_methods: (credit_card, e-wallet, cash)

-- what is the most common customer type?
select customer_type, count(customer_type) as cust_type
from sales
group by customer_type
order by cust_type desc;
-- most common customer type is member at 501

-- which customer type buys the most?
select customer_type, count(*) as cust_count
from sales
group by customer_type
order by cust_count desc;
-- member customer type buys the most

-- what is the gender of most customers?
select gender, count(*) as gender_count
from sales
group by gender
order by gender_count desc;
-- female is the gender of most customers(female: 501, male: 499)

-- what is the gender distribution per branch?
select branch, gender, count(*) as gender_count
from sales
where branch ="C" -- --> replaced with A and B to find other branch
group by branch, gender;
-- branch A: male = 179, female = 161
-- branch B: male = 170, female = 162
-- branch C: male = 150, female = 178

-- which time of the day do customers give most ratings?
select time_of_day, round(avg(rating), 2) as rating
from sales
group by time_of_day
order by rating desc
;
-- afternoons has the highest average ration of 7:03 (morning: 6.96, evening: 6.93)

-- which time of the day do customers give most ratings per branch
select branch, time_of_day, round(avg(rating), 2) as rating
from sales
where branch = "A" -- --> replace with B, C for other branches
group by branch, time_of_day
order by rating desc;
-- branch A: afternoon (7.19 rating)
-- branch B: morning (6.89 rating)
-- branch C: evening (7.12 rating)

-- which day of the week has the best average rating
select day_name, round(avg(rating), 2) as rating
from sales
group by day_name
order by rating desc;
-- monday has the best average rating of (7.15)

-- which day of the week has the best average rating
select branch, day_name, round(avg(rating), 2) as rating
from sales
where branch = "C" -- --> to be replaced with other branches
group by day_name
order by rating desc;
-- branch A: friday (7.31 rating)
-- branch B: monday (7.34 rating)
-- branch C: friday (7.28 rating)

select *
from sales;