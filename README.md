# Walmart Sales Analysis

## Project Overview

This project performs an end-to-end **SQL-based exploratory data analysis (EDA)** on a retail sales dataset modeled after Walmart transactions.
The analysis follows a structured pipeline:

1. Database and schema definition
2. Feature engineering directly in SQL
3. Business-driven analytical queries across products, sales, customers, revenue, VAT, and ratings

All transformations and insights are derived **in-database**, ensuring reproducibility and analytical rigor.

---

## Database & Table Setup

A relational database (`salesDataWalmart`) is created to store transactional sales data.
The `sales` table captures invoice-level details including pricing, quantity, customer attributes, temporal fields, and profitability metrics.

```sql
create database if not exists salesDataWalmart;
```

```sql
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
```

---

## Feature Engineering

### What time of day did each sale occur?

Sales are categorized into **morning, afternoon, and evening** based on transaction time.

```sql
alter table sales add column time_of_day varchar(20);

update sales
set time_of_day = case
    when sale_time < '12:00:00' then 'morning'
    when sale_time < '16:00:00' then 'afternoon'
    else 'evening'
end;
```

**Finding:**
Afternoon transactions dominate sales volume and tend to receive higher customer ratings.

---

### What day of the week did each sale occur?

```sql
alter table sales add column day_name varchar(10);

update sales
set day_name = dayname(sale_date);
```

**Finding:**
Weekday-based patterns reveal rating and sales concentration differences across branches.

---

### What month did each sale occur?

```sql
alter table sales add column month_name varchar(12);

update sales
set month_name = monthname(sale_date);
```

**Finding:**
January leads in both revenue and cost of goods sold (COGS).

---

## Product & Location Analysis

### How many unique cities are in the data?

```sql
select count(distinct city) from sales;
select distinct city from sales;
```

**Finding:**
There are **3 cities**: Yangon, Naypyitaw, and Mandalay.

---

### In which city is every branch?

```sql
select distinct city, branch from sales;
```

**Finding:**

* Yangon → Branch A
* Mandalay → Branch B
* Naypyitaw → Branch C

---

### How many unique product lines does the data have?

```sql
select count(distinct product_line) from sales;
select distinct product_line from sales;
```

**Finding:**
There are **6 unique product lines**.

---

### What is the most common payment method?

```sql
select payment_method, count(*) as cnt
from sales
group by payment_method
order by cnt desc;
```

**Finding:**
**E-wallet** is the most frequently used payment method.

---

### What is the most selling product line?

```sql
select product_line, count(*) as cnt
from sales
group by product_line
order by cnt desc;
```

**Finding:**
**Fashion accessories** has the highest number of transactions.

---

## Revenue & Cost Analysis

### What is the total revenue by month?

```sql
select month_name, sum(total) as total_revenue
from sales
group by month_name
order by total_revenue desc;
```

**Finding:**

* January: highest revenue
* March: second
* February: lowest

---

### What month had the largest COGS?

```sql
select month_name, sum(cogs) as cogs
from sales
group by month_name
order by cogs desc;
```

**Finding:**
January incurs the highest operational cost.

---

### What product line has the largest revenue?

```sql
select product_line, sum(total) as total_revenue
from sales
group by product_line
order by total_revenue desc;
```

**Finding:**
**Food and beverages** generate the most revenue overall.

---

### What is the city with the largest revenue?

```sql
select city, sum(total) as total_revenue
from sales
group by city
order by total_revenue desc;
```

**Finding:**
**Naypyitaw** leads all cities in total revenue.

---

### What is the product line with the largest VAT?

```sql
select product_line, avg(vat) as avg_vat
from sales
group by product_line
order by avg_vat desc;
```

**Finding:**
**Home and lifestyle** has the highest average VAT.

---

## Sales Volume Analysis

### Which branch sold more products than the average product sold?

```sql
select avg(quantity) from sales;
```

```sql
select branch, sum(quantity) as qty
from sales
group by branch
having sum(quantity) > (select avg(quantity) from sales);
```

**Finding:**
All branches (A, B, C) sold quantities above the overall average.

---

### What is the most common product line by gender?

```sql
select gender, product_line, count(*) as gender_count
from sales
group by gender, product_line
order by gender_count desc;
```

**Finding:**
Purchase preferences vary by gender, with fashion and food-related products dominating.

---

### What is the average rating of each product line?

```sql
select product_line, round(avg(rating), 2) as avg_rating
from sales
group by product_line
order by avg_rating desc;
```

**Finding:**
**Food and beverages** receive the highest average ratings.

---

## Sales & Customer Analysis

### Find number of sales made in each time of the day per weekday

```sql
select time_of_day, count(*) as total_sales
from sales
where day_name = 'Monday'
group by time_of_day
order by total_sales desc;
```

**Finding:**
Afternoon sales dominate weekdays, particularly Mondays.

---

### Which customer type brings the most revenue?

```sql
select customer_type, avg(total), sum(total) as total_revenue
from sales
group by customer_type
order by total_revenue desc;
```

**Finding:**
**Members** generate significantly more revenue than normal customers.

---

### Which city has the largest VAT?

```sql
select city, round(avg(vat), 2) as avg_vat
from sales
group by city
order by avg_vat desc;
```

**Finding:**
Naypyitaw has the highest average VAT.

---

### Which customer type pays the most VAT?

```sql
select customer_type, round(avg(vat), 2)
from sales
group by customer_type
order by avg(vat) desc;
```

**Finding:**
Member customers pay more VAT on average.

---

## Customer & Ratings Analysis

### What is the gender of most customers?

```sql
select gender, count(*) from sales
group by gender;
```

**Finding:**
The dataset is nearly balanced, with **slightly more female customers**.

---

### Which time of the day do customers give most ratings?

```sql
select time_of_day, round(avg(rating), 2)
from sales
group by time_of_day
order by avg(rating) desc;
```

**Finding:**
Afternoon purchases receive the highest ratings.

---

### Which time of the day do customers give most ratings per branch?

```sql
select branch, time_of_day, round(avg(rating), 2)
from sales
where branch = 'A'
group by branch, time_of_day
order by avg(rating) desc;
```

**Finding:**

* Branch A: Afternoon
* Branch B: Morning
* Branch C: Evening

---

### Which day of the week has the best average rating?

```sql
select day_name, round(avg(rating), 2)
from sales
group by day_name
order by avg(rating) desc;
```

**Finding:**
Monday has the highest overall ratings.

---

### Which day of the week has the best average rating per branch?

```sql
select branch, day_name, round(avg(rating), 2)
from sales
where branch = 'C'
group by branch, day_name
order by avg(rating) desc;
```

**Finding:**

* Branch A: Friday
* Branch B: Monday
* Branch C: Friday

---