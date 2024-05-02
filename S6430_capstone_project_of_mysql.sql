USE amazon;            # using amazon database

SELECT * FROM amazon;   #fetching all the coulumns of amazon database

SET SQL_SAFE_UPDATES = 0;  #disabling safe update, allowing to use UPDATE and DELETE statement

-- -- Feature Engineering -- --
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*  Adding a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening. 
	This will help answer the question on which part of the day most sales are made. */

ALTER TABLE amazon
ADD COLUMN timeofday VARCHAR(20);

UPDATE amazon
SET timeofday = CASE
    WHEN HOUR(time) < 12 THEN 'Morning'
    WHEN HOUR(time) < 18 THEN 'Afternoon'
    ELSE 'Evening'
END;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*  Add a new column named dayname that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). 
    This will help answer the question on which week of the day each branch is busiest.*/

ALTER TABLE amazon
ADD COLUMN dayname VARCHAR(3);


UPDATE amazon
SET dayname = UPPER(SUBSTRING(DAYNAME(date), 1, 3));

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Add a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar). 
   Help determine which month of the year has the most sales and profit.*/

ALTER TABLE amazon
ADD COLUMN monthname VARCHAR(3);

UPDATE amazon
SET monthname = UPPER(SUBSTRING(MONTHNAME(date), 1, 3));

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


SET SQL_SAFE_UPDATES = 1;   #enables the safe update



SELECT * FROM amazon;  #fetching the updated table with all columns

-- -- Business Questions To Answer: -- --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q1 What is the count of distinct cities in the dataset? --

SELECT 
       COUNT(DISTINCT city) AS count_of_cities
FROM amazon; 
  
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
-- Q2 For each branch, what is the corresponding city? --

SELECT 
       branch, city
FROM amazon 
GROUP BY branch,city;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------     
-- Q3 What is the count of distinct product lines in the dataset? --

SELECT 
	   DISTINCT product_line
FROM amazon;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------     
-- Q4 Which payment method occurs most frequently? --

SELECT 
      payment_method, COUNT(*) as frequency
FROM amazon
GROUP BY payment_method
ORDER BY count(*) DESC 
LIMIT 1;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------         
-- Q5 Which product line has the highest sales? --

SELECT 
      product_line, sum(total) AS total_sales
FROM amazon
GROUP BY product_line
ORDER BY sum(total) DESC 
LIMIT 1;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q6 How much revenue is generated each month? --

SELECT 
       monthname, sum(total) AS total_revenue
FROM amazon
GROUP BY monthname;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------        
-- Q7 In which month did the cost of goods sold reach its peak? --

SELECT 
        monthname, sum(total) AS total_revenue
FROM amazon
GROUP BY monthname
ORDER BY sum(total) DESC 
LIMIT 1;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q8 Which product line generated the highest revenue? --

SELECT  
       product_line, sum(total) as revenue
FROM amazon
GROUP BY product_line
ORDER BY sum(total) DESC
LIMIT 1;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q9 In which city was the highest revenue recorded?

SELECT 
       city, sum(total)
FROM amazon
GROUP BY city
ORDER BY sum(total) DESC 
LIMIT 1;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q10 Which product line incurred the highest Value Added Tax? --

SELECT 
      product_line,sum(VAT) AS Total_VAT
FROM amazon
GROUP BY product_line
ORDER BY sum(VAT) DESC 
LIMIT 1;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q11 For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."--

SELECT 
    product_line,
    CASE 
        WHEN sales > avg_sales THEN 'Good'
        ELSE 'Bad'
    END AS sales_status
FROM (
    SELECT 
        product_line,
        SUM(total) AS sales,
        AVG(SUM(total)) OVER () AS avg_sales
    FROM amazon
    GROUP BY product_line
) AS subquery_alias;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q12 Identify the branch that exceeded the average number of products sold. -- 

SELECT 
      branch, TOTAL_PRODUCTS, AVERAGE_PRODUCTS 
FROM(
     SELECT 
           branch , SUM(quantity) AS TOTAL_PRODUCTS, AVG(SUM(quantity)) OVER()  AVERAGE_PRODUCTS  
	 FROM amazon 
     GROUP BY branch) 
AS subquery
WHERE TOTAL_PRODUCTS> AVERAGE_PRODUCTS;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q13 Which product line is most frequently associated with each gender? --

SELECT 
      product_line, gender, COUNT(*) AS frequency
FROM amazon
GROUP BY Product_line,gender
ORDER BY gender, COUNT(*) DESC;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q14 Calculate the average rating for each product line. --

SELECT 
      product_line, FORMAT(AVG(rating),2) AS average_rating
FROM amazon
GROUP BY product_line;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q15 Count the sales occurrences for each time of day on every weekday.--

SELECT 
      timeofday, count(*) AS SALES_OCCURRENCES 
FROM amazon WHERE dayname= "WED"
GROUP BY timeofday; 

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q16 Identify the customer type contributing the highest revenue.

SELECT 
       customer_type, sum(total) AS Revenue
FROM amazon
GROUP BY customer_type
ORDER BY Revenue DESC
LIMIT 1;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q17 Determine the city with the highest VAT percentage. --

SELECT 
       city ,( (SUM(VAT) / SUM(total) )*100) AS vat_percentage
FROM amazon
GROUP BY city
ORDER BY vat_percentage DESC
LIMIT 1;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q18 Identify the customer type with the highest VAT payments. --

SELECT 
       customer_type , SUM(VAT) AS total_vat_payments
FROM amazon
GROUP BY customer_type
ORDER BY total_vat_payments DESC
LIMIT 1;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q19 What is the count of distinct customer types in the dataset? --

SELECT 
       COUNT(DISTINCT customer_type) AS Count_of_customer_types
FROM amazon;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q20 What is the count of distinct payment methods in the dataset? --

SELECT 
      COUNT( DISTINCT payment_method) AS Count_of_payment_method
FROM amazon;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q21 Which customer type occurs most frequently? --

SELECT 
      customer_type, count(*) AS frequency
FROM amazon
GROUP BY customer_type
ORDER BY frequency DESC
LIMIT 1;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q22 Identify the customer type with the highest purchase frequency. --

SELECT 
      customer_type, COUNT(*) AS total_purchases
FROM amazon
GROUP BY customer_type
ORDER BY COUNT(*) DESC
LIMIT 1;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q23 Determine the predominant gender among customers. --

SELECT 
       gender, COUNT(gender) AS frequency
FROM amazon
GROUP BY gender
ORDER BY frequency DESC
LIMIT 1;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q24 Examine the distribution of genders within each branch. --

SELECT 
      branch, gender,count(gender) AS frequency
FROM amazon
GROUP BY branch, gender
ORDER BY branch,gender;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q25 Identify the time of day when customers provide the most ratings. --

SELECT 
         timeofday, COUNT(*) AS rating_count 
FROM amazon
GROUP BY timeofday
ORDER BY count(*) DESC;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q26 Determine the time of day with the highest customer ratings for each branch. --

SELECT 
       branch, timeofday, rating_count
FROM  (SELECT
             branch, timeofday ,count(rating) AS rating_count, DENSE_RANK() OVER(PARTITION BY branch ORDER BY count(rating) DESC) AS ranking 
             FROM amazon
             GROUP BY branch, timeofday) AS subquery
WHERE ranking=1;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q27 Identify the day of the week with the highest average ratings. --

SELECT 
       dayname, AVG(rating) AS average_rating 
FROM amazon
GROUP BY dayname
ORDER BY AVG(rating) DESC
LIMIT 1;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q28 Determine the day of the week with the highest average ratings for each branch.

SELECT 
       branch, dayname, average_rating 
FROM  (SELECT
             branch, dayname ,AVG(rating) AS average_rating ,DENSE_RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS ranking 
             FROM amazon
             GROUP BY branch, dayname) AS subquery
WHERE ranking=1;









