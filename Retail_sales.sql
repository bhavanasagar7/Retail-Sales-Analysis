create database if not exists salesDataWalmart;

create table if not exists sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,
    total DECIMAL(12,4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12,4) NOT NULL,
    rating FLOAT(2,1)
);

-- -------------------------------------------------------------------------------------------
-- ---------------------------Feature Engineering---------------------------------------------

-- time_of_day
select
	time,
    (CASE
		WHEN `time` BETWEEN "00:00:00" and "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" and "16:00:00" THEN "Afternoon"
        ELSE "Evening"
	END
    ) AS time_of_date
from sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
CASE
		WHEN `time` BETWEEN "00:00:00" and "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" and "16:00:00" THEN "Afternoon"
        ELSE "Evening"
END
);

-- day_name
select 
	date,
    DAYNAME(date) AS day_name
from sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);

-- month_name

select 
	date,
    MONTHNAME(date)
from sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(20);

UPDATE sales 
SET month_name = MONTHNAME(date);


-- -----------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------Generic---------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------

-- How many unique cities does the data have?
select 
	DISTINCT city
from sales;

-- In which city is each branch?
select 
	DISTINCT branch
from sales;

select 
	DISTINCT city,branch
from sales;

-- -----------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------Product---------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------

-- How many unique product lines does the data have?
select 
	count(distinct product_line)
from sales;

-- What is the most common payment method?
select 
	payment_method,
    count(payment_method) as cnt
from sales
group by payment_method
order by cnt desc;

-- What is the most selling product line?
select 
	product_line,
    count(product_line) as cnt_pd
from sales
group by product_line
order by cnt_pd desc;

-- What is the total revenue by month?
select 
	month_name as month,
    sum(total) as total_revenue
from sales
group by month_name
order by total_revenue desc;

-- What month had the largest COGS?
select 
    month_name as month,
    sum(cogs) as cogs
from sales
group by month_name
order by cogs desc;

-- What product line had the largest revenue?
select 
	product_line,
    sum(total) as total_revenue
from sales
group by product_line
order by total_revenue desc;

-- What is the city with the largest revenue?
select 
	branch,
    city,
    sum(total) as total_revenue
from sales
group by branch,city
order by total_revenue desc;

-- What product line had the largest VAT?
select 
	product_line,
    avg(VAT) as avg_tax
from sales
group by product_line
order by avg_tax desc;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT 
	AVG(quantity) AS avg_qnty
FROM sales;

SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;


-- Which branch sold more products than average product sold?
select 
	branch,
    sum(quantity) as qty 
from sales
group by branch
having sum(quantity) > (select avg(quantity) from sales);

-- What is the most common product line by gender?
select 
	gender,
    product_line,
    count(gender) as total_cnt
from sales
group by product_line,gender
order by total_cnt desc;
    
-- What is the average rating of each product line?
select 
	round(avg(rating),2) as avg_rating,
    product_line
from sales
group by product_line 
order by avg_rating desc;

-- --------------------------------------------------------------------
-- -------------------------- Customers -------------------------------
-- --------------------------------------------------------------------

-- How many unique customer types does the data have?
SELECT
	DISTINCT customer_type
FROM sales;

-- How many unique payment methods does the data have?
SELECT
	DISTINCT payment
FROM sales;


-- What is the most common customer type?
SELECT
	customer_type,
	count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*) AS CNT
FROM sales
GROUP BY customer_type;


-- What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- What is the gender distribution per branch?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;
-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.

-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day.alter


-- Which time of the day do customers give most ratings per branch?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.


-- Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;
-- Mon, Tue and Friday are the top best days for good ratings
-- why is that the case, how many sales are made on these days?



-- Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC;


-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- ---------------------------- Sales ---------------------------------
-- --------------------------------------------------------------------

-- Number of sales made in each time of the day per weekday 
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;
-- Evenings experience most sales, the stores are 
-- filled during the evening hours

-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue;

-- Which city has the largest tax/VAT percent?
SELECT
	city,
    ROUND(AVG(VAT), 2) AS avg_tax_pct
FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;

-- Which customer type pays the most in VAT?
SELECT
	customer_type,
	AVG(VAT) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------
