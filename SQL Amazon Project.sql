SQL- Amazon Myanmar Sales Capstone Project
                    
Amazon Sales Data
First we CREATE Database Capstone:-

CREATE DATABASE Capstone;
USE Capstone;

Create Table: Sales
Insert Values
CREATE TABLE sales(
invoice_id VARCHAR(30) PRIMARY KEY not null,
Branch VARCHAR(5) not null,
City VARCHAR(30) not null,
Customer_type VARCHAR(30) not null,
Gender VARCHAR(10) not null,
Product_line varchar (100) not null,
Unit_price DECIMAL (10, 2) not null,
Quantity INT not null,
Tax_pct FLOAT not null,
Total FLOAT not null,
Date DATE not null,
Time TIME not null,
payment_method VARCHAR(50) not null,
cogs DECIMAL(10, 2) not null,
gross_margin_percentage FLOAT not null,
gross_income FLOAT not null,
rating FLOAT not null
);

Check for Null Values

Feature Engineering
For adding column timeofday

ALTER TABLE sales ADD COLUMN timeofday VARCHAR(20) NOT NULL;
SET SQL_SAFE_UPDATES = 0; OR You can use WHERE clause with a key column (like a primary key),
UPDATE sales
SET timeofday = CASE
    WHEN HOUR(time) BETWEEN 5 AND 11 THEN 'Morning'
    WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
    WHEN HOUR(time) BETWEEN 18 AND 21 THEN 'Evening'
    ELSE 'Night'
END
WHERE invoice_id IS NOT NULL;

For adding column named dayname 

ALTER TABLE sales ADD COLUMN dayname VARCHAR(10) NOT NULL;
UPDATE sales
SET dayname = LEFT(DAYNAME(date), 3);

For adding column named monthname 

ALTER TABLE sales ADD COLUMN monthname VARCHAR(10) NOT NULL;
UPDATE sales
SET monthname = LEFT(MONTHNAME(date), 3);

EDA (Exploratory Data Analysis)

/**
1.	What is the count of distinct cities in the dataset?
Query:
SELECT COUNT(DISTINCT city) AS distinct_city_count
FROM sales;
**\

/**
2.	For each branch, what is the corresponding city?
Query:
SELECT DISTINCT branch, city
FROM sales;
**\

/**
3.	What is the count of distinct product lines in the dataset?
Query:
SELECT COUNT(DISTINCT product_line) AS distinct_product_line_count
FROM sales;
**\

/**
4.	Which payment method occurs most frequently?
SELECT payment_method, COUNT(*) AS frequency
FROM sales
GROUP BY payment_method
ORDER BY frequency DESC
LIMIT 1;
**\

/**
5.	Which product line has the highest sales?
Query:
SELECT product_line, SUM(total) AS total_sales
FROM sales
GROUP BY product_line
ORDER BY total_sales DESC
LIMIT 1;
**\

/**
6.	How much revenue is generated each month?
Query:
SELECT
	MONTHNAME(date) AS month,
    SUM(total) AS monthly_revenue
FROM sales
GROUP BY MONTH(date), MONTHNAME(date)
ORDER BY MONTH(date);
**\

/**
7.	In which month did the cost of goods sold reach its peak?
Query:
SELECT
MONTHNAME(date) AS month,
SUM(cogs) AS total_cogs
FROM sales
GROUP BY MONTH(date), MONTHNAME(date)
ORDER BY total_cogs DESC
LIMIT 1;
**\

/**
8.	Which product line generated the highest revenue?
Query:
SELECT 
    product_line,
    SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC
LIMIT 1;
**\

/**
9.	In which city was the highest revenue recorded?
Query:
SELECT 
    city,
    SUM(total) AS total_revenue
FROM sales
GROUP BY city
ORDER BY total_revenue DESC
LIMIT 1;
**\

/**
10.	Which product line incurred the highest Value Added Tax?
Query:
SELECT Product_line, 
       ROUND(SUM(Tax_pct), 2) AS Total_VAT
FROM sales
GROUP BY Product_line
ORDER BY Total_VAT DESC
LIMIT 1;
**\

/**
11.	For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
Query:
SELECT 
    Product_line,
    SUM(Total) AS Total_Sales,
    CASE 
        WHEN SUM(Total) > (SELECT AVG(Total_Sales) 
                           FROM (SELECT Product_line, SUM(Total) AS Total_Sales 
                                 FROM sales 
                                 GROUP BY Product_line) AS avg_sales)
        THEN 'Good'
        ELSE 'Bad'
    END AS Sales_Category
FROM sales
GROUP BY Product_line;
**\

/**
12.	Identify the branch that exceeded the average number of products sold.
Query:
SELECT 
    Branch,
    SUM(Quantity) AS Total_Products_Sold
FROM sales
GROUP BY Branch
HAVING SUM(Quantity) > (
    SELECT AVG(Total_Quantity) 
    FROM (
        SELECT Branch, SUM(Quantity) AS Total_Quantity
        FROM sales
        GROUP BY Branch
    ) AS branch_totals );
**\

/**

13 Which product line is most frequently associated with each gender?
Query:
WITH ranked_product_lines AS (
    SELECT 
        gender,
        product_line,
        COUNT(*) AS frequency,
        RANK() OVER (PARTITION BY gender ORDER BY COUNT(*) DESC) AS rnk
    FROM sales
    GROUP BY gender, product_line
)
SELECT gender, product_line, frequency
FROM ranked_product_lines
WHERE rnk = 1;
**\

/**

14.Calculate the average rating for each product line.
Query
SELECT 
    product_line,
    ROUND(AVG(rating), 2) AS average_rating
FROM 
    sales
GROUP BY 
    product_line;
**\


/**
15.Count the sales occurrences for each time of day on every weekday.
Query
SELECT DAYNAME(Date) AS weekday,
    CASE
        WHEN HOUR(Time) BETWEEN 5 AND 11 THEN 'Morning'
        WHEN HOUR(Time) BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN HOUR(Time) BETWEEN 17 AND 20 THEN 'Evening'
        ELSE 'Night'
    END AS time_of_day,
    COUNT(*) AS sales_count
FROM sales
GROUP BY weekday, time_of_day
ORDER BY  FIELD(weekday, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'), time_of_day;
**\

/**
16 Identify the customer type contributing the highest revenue.
Query
SELECT customer_type, ROUND(SUM(total),2) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC
LIMIT 1;
**\

/**
17. Determine the city with the highest VAT percentage.
Query
SELECT city, ROUND(AVG(Tax_pct / total * 100), 2) AS average_vat_percentage
FROM sales
GROUP BY city
ORDER BY average_vat_percentage DESC
LIMIT 1;
**\

/**
18. Identify the customer type with the highest VAT payments.
Query
SELECT customer_type, ROUND(SUM(tax_pct), 2) AS total_vat
FROM sales
GROUP BY customer_type
ORDER BY total_vat DESC
LIMIT 1;
**\

/**
19. What is the count of distinct customer types in the dataset?
Query
SELECT COUNT(DISTINCT (customer_type)) AS distinct_customer_types_count
FROM sales;
**\

/**
20. What is the count of distinct payment methods in the dataset?
Query
SELECT COUNT(DISTINCT (payment_method)) AS distinct_payment_methods
FROM sales;
**\

/**
21. Which customer type occurs most frequently?
Query
SELECT customer_type, COUNT(*) AS frequency
FROM sales
GROUP BY customer_type
ORDER BY frequency DESC
LIMIT 1;
**\

/**
22. Identify the customer type with the highest purchase frequency.
Query
SELECT customer_type, COUNT(*) AS purchase_frequency
FROM sales
GROUP BY customer_type
ORDER BY purchase_frequency DESC
LIMIT 1;
**\

/**
23. Determine the predominant gender among customers.
Query
SELECT gender, COUNT(*) AS count
FROM sales
GROUP BY gender
ORDER BY count DESC
LIMIT 1;
**\

/**
24. Examine the distribution of genders within each branch.
Query
SELECT branch, gender, COUNT(*) AS count
FROM sales
GROUP BY branch, gender
ORDER BY branch, gender;
**\

/**
25. Identify the time of day when customers provide the most ratings.
Query
SELECT 
  CASE
    WHEN TIME(`Time`) BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
    WHEN TIME(`Time`) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
    WHEN TIME(`Time`) BETWEEN '18:00:00' AND '23:59:59' THEN 'Evening'
    ELSE 'Night'
  END AS time_of_day,
  COUNT(*) AS rating_count
FROM sales
GROUP BY time_of_day
ORDER BY rating_count DESC;
**\

/**
26. Determine the time of day with the highest customer ratings for each branch.
Query
SELECT branch, time_of_day, rating_count
FROM (
  SELECT branch,
    CASE
      WHEN TIME(`Time`) BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
      WHEN TIME(`Time`) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
      WHEN TIME(`Time`) BETWEEN '18:00:00' AND '23:59:59' THEN 'Evening'
      ELSE 'Night'
    END AS time_of_day,
    COUNT(*) AS rating_count,
    ROW_NUMBER() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rn
  FROM sales
  GROUP BY branch, time_of_day
) AS ranked
WHERE rn = 1;
**\

/**
27. Identify the day of the week with the highest average ratings.
Query
SELECT day_name, avg_rating
FROM (
  SELECT 
    DAYNAME(Date) AS day_name,
    ROUND(AVG(Rating),2) AS avg_rating,
    RANK() OVER (ORDER BY AVG(Rating) DESC) AS rk
  FROM sales
  GROUP BY DAYNAME(Date)
) AS ranked_days
WHERE rk = 1;
**\

/**
28. Determine the day of the week with the highest average ratings for each branch.
Query
SELECT branch, day_name, ROUND(avg_rating, 2)
FROM (
  SELECT 
    branch,
    DAYNAME(Date) AS day_name,
    AVG(Rating) AS avg_rating,
    ROW_NUMBER() OVER (
      PARTITION BY branch
      ORDER BY AVG(Rating) DESC
    ) AS rn
  FROM sales
  GROUP BY branch, DAYNAME(Date)
) AS ranked
WHERE rn = 1;
**\






