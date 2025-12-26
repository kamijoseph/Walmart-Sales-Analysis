Below are the **two requested sections only**, structured exactly as specified.

---

# README.md

## Project Overview

This project analyzes transactional sales data from a Walmart-like retail dataset using **SQL (MySQL-compatible)**.
The goal is threefold:

1. **Schema definition** – create a normalized, query-friendly sales table.
2. **Feature engineering** – derive temporal features (time of day, weekday, month) directly in SQL to enrich analysis.
3. **Exploratory Data Analysis (EDA)** – answer business questions around products, sales performance, customers, revenue, VAT, and ratings using aggregate SQL queries.

The workflow follows a realistic analytics pipeline: raw data → engineered features → descriptive insights.

---

## Database & Table Setup

### Database creation

```sql
create database if not exists salesDataWalmart;
```

### Sales table schema

The `sales` table stores transactional-level data with pricing, customer, time, and profitability fields.

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

Feature engineering is performed **in-database** to avoid recomputation and keep analysis reproducible.

### 1. Time of Day

Logic:

* Morning: before 12:00
* Afternoon: before 16:00
* Evening: otherwise

Exploration:

```sql
select
    sale_time,
    case
        when sale_time < '12:00:00' then 'morning'
        when sale_time < '16:00:00' then 'afternoon'
        else 'evening'
    end as time_of_day
from sales;
```

Schema update and persistence:

```sql
alter table sales add column time_of_day varchar(20);

update sales
set time_of_day = case
    when sale_time < '12:00:00' then 'morning'
    when sale_time < '16:00:00' then 'afternoon'
    else 'evening'
end;
```

---

### 2. Day of Week

```sql
alter table sales add column day_name varchar(10);

update sales
set day_name = dayname(sale_date);
```

---

### 3. Month Name

```sql
alter table sales add column month_name varchar(12);

update sales
set month_name = monthname(sale_date);
```

These engineered columns enable time-based aggregation without repeated function calls.

---

## Exploratory Data Analysis (EDA)

### Product & Location Analysis

**Unique cities**

```sql
select count(distinct city) from sales;
select distinct city from sales;
```

**Branch per city**

```sql
select distinct city, branch from sales;
```

**Unique product lines**

```sql
select count(distinct product_line) from sales;
select distinct product_line from sales;
```

**Most common payment method**

```sql
select payment_method, count(*) as cnt
from sales
group by payment_method
order by cnt desc;
```

**Most selling product line**

```sql
select product_line, count(*) as cnt
from sales
group by product_line
order by cnt desc;
```

---

### Revenue & Cost Analysis

**Total revenue by month**

```sql
select month_name, sum(total) as total_revenue
from sales
group by month_name
order by total_revenue desc;
```

**Month with highest COGS**

```sql
select month_name, sum(cogs) as cogs
from sales
group by month_name
order by cogs desc;
```

**Revenue by product line**

```sql
select product_line, sum(total) as total_revenue
from sales
group by product_line
order by total_revenue desc;
```

**Revenue by city**

```sql
select city, sum(total) as total_revenue
from sales
group by city
order by total_revenue desc;
```

**Highest VAT by product line**

```sql
select product_line, avg(vat) as avg_vat
from sales
group by product_line
order by avg_vat desc;
```

---

### Sales Volume Analysis

**Average quantity sold**

```sql
select avg(quantity) from sales;
```

**Branches selling above average**

```sql
select branch, sum(quantity) as qty
from sales
group by branch
having sum(quantity) > (select avg(quantity) from sales);
```

**Most common product line by gender**

```sql
select gender, product_line, count(*) as gender_count
from sales
group by gender, product_line
order by gender_count desc;
```

**Average rating per product line**

```sql
select product_line, round(avg(rating), 2) as avg_rating
from sales
group by product_line
order by avg_rating desc;
```

---

### Time-Based Sales Analysis

**Sales per time of day per weekday**

```sql
select time_of_day, count(*) as total_sales
from sales
where day_name = 'Monday'
group by time_of_day
order by total_sales desc;
```

---

### Customer & VAT Analysis

**Revenue by customer type**

```sql
select customer_type, avg(total) as avg_total, sum(total) as total_revenue
from sales
group by customer_type
order by total_revenue desc;
```

**VAT by city**

```sql
select city, round(avg(vat), 2) as avg_vat
from sales
group by city
order by avg_vat desc;
```

**VAT by customer type**

```sql
select customer_type, round(avg(vat), 2) as avg_vat
from sales
group by customer_type
order by avg_vat desc;
```

---

### Customer Demographics

**Customer types**

```sql
select count(distinct customer_type) from sales;
select distinct customer_type from sales;
```

**Payment methods**

```sql
select count(distinct payment_method) from sales;
select distinct payment_method from sales;
```

**Most common customer type**

```sql
select customer_type, count(*) as cust_type
from sales
group by customer_type
order by cust_type desc;
```

**Gender distribution**

```sql
select gender, count(*) as gender_count
from sales
group by gender
order by gender_count desc;
```

**Gender per branch**

```sql
select branch, gender, count(*) as gender_count
from sales
where branch = 'C'
group by branch, gender;
```

---

### Ratings Analysis

**Ratings by time of day**

```sql
select time_of_day, round(avg(rating), 2) as rating
from sales
group by time_of_day
order by rating desc;
```

**Ratings by time of day per branch**

```sql
select branch, time_of_day, round(avg(rating), 2) as rating
from sales
where branch = 'A'
group by branch, time_of_day
order by rating desc;
```

**Ratings by weekday**

```sql
select day_name, round(avg(rating), 2) as rating
from sales
group by day_name
order by rating desc;
```

**Ratings by weekday per branch**

```sql
select branch, day_name, round(avg(rating), 2) as rating
from sales
where branch = 'C'
group by day_name
order by rating desc;
```

---
