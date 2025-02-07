-- CHECKING COLUMN NAMES, DATA TYPES, AND CONSTRAINTS
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'WalmartSalesData.csv';

-- THE DATASET CONTAINS A MIX OF STRING (NVARCHAR), NUMERICAL (FLOAT, TINYINT), AND DATE/TIME (DATE, TIME) DATA TYPES.

-- PERFORMING BASIC EDA ON THE DATASET

-- EXPLORING STRING DATA
SELECT DISTINCT BRANCH, COUNT(CASE WHEN BRANCH IS NULL THEN 1 END) AS NA_COUNT FROM dbo.[WalmartSalesData.csv] GROUP BY BRANCH; 
SELECT DISTINCT CITY, COUNT(CASE WHEN CITY IS NULL THEN 1 END) AS NA_COUNT FROM dbo.[WalmartSalesData.csv] GROUP BY CITY; 
SELECT DISTINCT CUSTOMER_TYPE, COUNT(CASE WHEN CUSTOMER_TYPE IS NULL THEN 1 END) AS NA_COUNT FROM dbo.[WalmartSalesData.csv] GROUP BY CUSTOMER_TYPE; 
SELECT DISTINCT PRODUCT_LINE, COUNT(CASE WHEN PRODUCT_LINE IS NULL THEN 1 END) AS NA_COUNT FROM dbo.[WalmartSalesData.csv] GROUP BY PRODUCT_LINE; 
SELECT DISTINCT PAYMENT, COUNT(CASE WHEN PAYMENT IS NULL THEN 1 END) AS NA_COUNT FROM dbo.[WalmartSalesData.csv] GROUP BY PAYMENT;

-- EXPLORING NUMERICAL DATA
SELECT 'PRODUCT PRICE' AS METRIC, 
       MIN(UNIT_PRICE) AS MIN_VALUE, 
       ROUND(AVG(UNIT_PRICE), 2) AS AVG_VALUE, 
       MAX(UNIT_PRICE) AS MAX_VALUE,
       COUNT(CASE WHEN UNIT_PRICE IS NULL THEN 1 END) AS NA_COUNT
FROM dbo.[WalmartSalesData.csv]

UNION ALL

SELECT 'QTY SOLD', MIN(QUANTITY), ROUND(AVG(QUANTITY), 2), MAX(QUANTITY),
       COUNT(CASE WHEN QUANTITY IS NULL THEN 1 END) AS NA_COUNT
FROM dbo.[WalmartSalesData.csv]

UNION ALL

SELECT 'TAX PAID', MIN(TAX_5), ROUND(AVG(TAX_5), 2), MAX(TAX_5),
       COUNT(CASE WHEN TAX_5 IS NULL THEN 1 END) AS NA_COUNT
FROM dbo.[WalmartSalesData.csv]

UNION ALL

SELECT 'COST OF PURCHASE', MIN(TOTAL), ROUND(AVG(TOTAL), 2), MAX(TOTAL),
       COUNT(CASE WHEN TOTAL IS NULL THEN 1 END) AS NA_COUNT
FROM dbo.[WalmartSalesData.csv]

UNION ALL

SELECT 'COST SOLD', MIN(COGS), ROUND(AVG(COGS), 2), MAX(COGS),
       COUNT(CASE WHEN COGS IS NULL THEN 1 END) AS NA_COUNT
FROM dbo.[WalmartSalesData.csv]

UNION ALL

SELECT 'GMP', MIN(GROSS_MARGIN_PERCENTAGE), ROUND(AVG(GROSS_MARGIN_PERCENTAGE), 2), MAX(GROSS_MARGIN_PERCENTAGE),
       COUNT(CASE WHEN GROSS_MARGIN_PERCENTAGE IS NULL THEN 1 END) AS NA_COUNT
FROM dbo.[WalmartSalesData.csv]

UNION ALL

SELECT 'GROSS INCOME', MIN(GROSS_INCOME), ROUND(AVG(GROSS_INCOME), 2), MAX(GROSS_INCOME),
       COUNT(CASE WHEN GROSS_INCOME IS NULL THEN 1 END) AS NA_COUNT
FROM dbo.[WalmartSalesData.csv]

UNION ALL

SELECT 'PRODUCT RATING', MIN(RATING), ROUND(AVG(RATING), 2), MAX(RATING),
       COUNT(CASE WHEN RATING IS NULL THEN 1 END) AS NA_COUNT
FROM dbo.[WalmartSalesData.csv];

--------------------------------------------- PRODUCT LINE -----------------------------------------------------------------------

-- WHICH PRODUCT LINE HAS HIGHEST QTY SOLD
SELECT PRODUCT_LINE , SUM(QUANTITY) AS TOTAL_QTY_SOLD 
FROM dbo.[WalmartSalesData.csv]
GROUP BY PRODUCT_LINE
ORDER BY TOTAL_QTY_SOLD DESC;
-- MAX QTY SOLD IS FOR ELECTRONICS AND MIN IS FOR HEALTH AND BEAUTY

-- WHICH PRODUCT LINE HAS HIGHEST UNIT PRICE
SELECT PRODUCT_LINE , ROUND(AVG(UNIT_PRICE), 2) [ AVG_PRICE_OF_PRODUCT ] 
FROM dbo.[WalmartSalesData.csv]
GROUP BY PRODUCT_LINE
ORDER BY [ AVG_PRICE_OF_PRODUCT ] DESC ;
-- FASHION PRODUCTS HAVE HIGHEST UNIT PRICE WHEREAS ELECTRONICS HAVE MINIMUM.

-- WHICH PRODUCT LINE GENERATES MAX REVENUE.
SELECT PRODUCT_LINE , ROUND(SUM(TOTAL), 2) AS TOTAL_REVENUE_GENERATED
FROM dbo.[WalmartSalesData.csv]
GROUP BY PRODUCT_LINE
ORDER BY TOTAL_REVENUE_GENERATED DESC;
-- FOOD AND BEVERAGES GENERATE MAX REVENUE AND LEAST IS FOR HEALTH AND BEAUTY

-- WHICH PRODUCT LINE HAS THE HIGHEST RATING.
SELECT PRODUCT_LINE , ROUND(AVG(RATING), 2) AS AVG_RATING 
FROM dbo.[WalmartSalesData.csv]
GROUP BY PRODUCT_LINE
ORDER BY AVG_RATING DESC;
-- FOOD AND BEVERAGES HAVE THE HIGHEST RATING

-- CTE COMBINING THE ABOVE RESULTS
WITH PRODUCT_LINE_STATS AS (
    SELECT 
        PRODUCT_LINE,
        SUM(QUANTITY) AS TOTAL_QTY_SOLD,
        ROUND(AVG(UNIT_PRICE), 2) AS AVG_PRICE_OF_PRODUCT,
        ROUND(SUM(TOTAL), 2) AS TOTAL_REVENUE_GENERATED,
        ROUND(AVG(RATING), 2) AS AVG_RATING,
        ROUND(SUM(TAX_5), 2) AS TAX_LEVIED
    FROM dbo.[WalmartSalesData.csv]
    GROUP BY PRODUCT_LINE
)
SELECT 
    PRODUCT_LINE,
    TOTAL_QTY_SOLD,
    AVG_PRICE_OF_PRODUCT,
    TOTAL_REVENUE_GENERATED,
    AVG_RATING,
    TAX_LEVIED,
    CASE 
        WHEN TOTAL_QTY_SOLD = (SELECT MAX(TOTAL_QTY_SOLD) FROM PRODUCT_LINE_STATS) THEN 'HIGHEST QTY SOLD'
        ELSE NULL 
    END AS MAX_QTY_STATUS,
    CASE 
        WHEN AVG_PRICE_OF_PRODUCT = (SELECT MAX(AVG_PRICE_OF_PRODUCT) FROM PRODUCT_LINE_STATS) THEN 'HIGHEST UNIT PRICE'
        ELSE NULL 
    END AS MAX_PRICE_STATUS,
    CASE 
        WHEN TOTAL_REVENUE_GENERATED = (SELECT MAX(TOTAL_REVENUE_GENERATED) FROM PRODUCT_LINE_STATS) THEN 'MAX REVENUE'
        ELSE NULL 
    END AS MAX_REVENUE_STATUS,
    CASE 
        WHEN AVG_RATING = (SELECT MAX(AVG_RATING) FROM PRODUCT_LINE_STATS) THEN 'HIGHEST RATING'
        ELSE NULL 
    END AS MAX_RATING_STATUS
FROM PRODUCT_LINE_STATS
ORDER BY TOTAL_QTY_SOLD DESC, AVG_PRICE_OF_PRODUCT DESC, TOTAL_REVENUE_GENERATED DESC, AVG_RATING DESC;



-- WHICH PRODUCT IS FAMOUS WITH WHICH GENDER
SELECT Product_line, 
       COUNT(CASE WHEN Gender = 'FEMALE' THEN 1 END) AS Female_Count,
       COUNT(CASE WHEN Gender = 'MALE' THEN 1 END) AS Male_Count
FROM dbo.[WalmartSalesData.csv]
GROUP BY Product_line;



-- WHICH PRODUCT IS FAMOUS WITH WHICH CITY
select City  ,Product_line 
from 
(
select City  ,Product_line  ,SUM(Quantity) [Total QTY Sold] , 

RANK() OVER (partition by City ORDER by SUM(Quantity) desc) as rnk 

from dbo.[WalmartSalesData.csv]

group by City , Product_line
) x where rnk = 1 





--------------------------------------------- Customer Type -----------------------------------------------------------------------
-- Member differentiation by City
select City  , 
COUNT(case when Customer_type = 'Member' then 1 end)  as Premium_Members , 
COUNT(case when Customer_type = 'Normal' then 1 end) as Normal_Members 
from dbo.[WalmartSalesData.csv] 
group by City; 

-- Member differentiation by City and Gender
select City , 
COUNT(case when Customer_type = 'Member' and  Gender = 'Female' then 1 end )  as Premium_Female_Members ,
COUNT(case when Customer_type = 'Member' and  Gender = 'Male' then 1 end )  as Premium_Male_Members ,
COUNT(case when Customer_type = 'Normal' and  Gender = 'Female' then 1 end )  as Female_Normal_Count,
COUNT(case when Customer_type = 'Normal' and  Gender = 'Male' then 1 end )  as Male_Normal_Count
from dbo.[WalmartSalesData.csv] 
group by City; 

-- How much revenue does a premium member generate
SELECT Customer_type , round(sum(Total),2) as Revenue_Generated
from dbo.[WalmartSalesData.csv] 
group by Customer_type; 


-- What products do premium customers buy?
select Customer_type , Product_line , ranks from 
(
select Customer_type , Product_line , COUNT(Product_line) as QTY , 

ROW_NUMBER() OVER(partition by CUSTOMER_TYPE order by COUNT(Product_line)desc ) as ranks

from dbo.[WalmartSalesData.csv] 

group by Customer_type , Product_line 
) x where ranks in (1,2,5,6)

/* Premium Customers:
  - Prioritize everyday consumables and leisure/travel-related products (Food and beverages as rank 1; Sports and travel as rank 2).
  - Secondary interests include additional categories like Electronic accessories and Health and beauty.
  - Marketing strategies such as targeted promotions and loyalty programs should emphasize consumable and leisure/travel products.

- Normal Customers:
  - Favor tech-related and fashion accessory items (Electronic accessories as rank 1; Fashion accessories as rank 2).
  - Their secondary preferences include Health and beauty and Home and lifestyle products.
  - A distinct marketing approach tailored to tech and fashion trends would likely be more effective for this group. 
  */


--------------------------------------------------------------------------------------------------------------------------------------
/* 
1. Product Line Contribution by City
*/ 

With city_sales as 

(
select City , Product_line , SUM(Total) as Product_specific_revenue , 

SUM(SUM(Total)) OVER(partition by city) as Total_revenue_by_City 

from dbo.[WalmartSalesData.csv]
 group by City , Product_line 
)

SELECT City , Product_line , round((Product_specific_revenue / Total_revenue_by_City) * 100 , 2) as Percentage_Contribtion

from city_sales

ORDER by city , Percentage_Contribtion DESC ; 



/* 
2. Hourly Sales Trends 
*/

SELECT Branch, DATEPART(HOUR , [Time]) as Time_of_Day,

    SUM(Total) as Hourly_Sales , 

    RANK() OVER( partition  by DATEPART(HOUR , [Time]) order by SUM(Total) DESC ) as ranks

from dbo.[WalmartSalesData.csv]

group by [Branch] ,  DATEPART(HOUR , [Time]) ; 

/* 
Reveals which branch leads in sales for each specific hour.
Example: At 19:00 (7 PM), Branch B dominates sales, followed by C and A.
Useful for comparing branch performance in real-time (e.g., staffing or promotions during competitive hours).
 */


SELECT 
    Branch, 
    DATEPART(HOUR, Time) AS hour, 
    SUM(Total) AS hourly_sales,  
    RANK() OVER (PARTITION BY Branch ORDER BY SUM(Total) DESC) AS hour_rank  

FROM dbo.[WalmartSalesData.csv]  
GROUP BY Branch, DATEPART(HOUR, Time);  

/* 
Shows the best-performing hours for each branch.
Example: Branch A’s peak hour is 11 AM, while Branch B peaks at 7 PM.
Highlights unique sales patterns per branch, aiding localized strategies (e.g., inventory restocking during peak hours).
 */


/* 
3. Member vs. Non-Member Customer Value
Compare the average transaction value and purchase frequency between Member and Normal customers.
 */

SELECT 
    Customer_type , 
    AVG(Total) as Avg_Transaction_Value,
    sum(COUNT(Invoice_ID)) OVER(partition by Customer_type) as Avg_Transactions_per_customer

from dbo.[WalmartSalesData.csv] 
group by Customer_type; 


/* 
4. Gender-Based Product Preferences
Identify top-selling product lines by gender.
 */

select Gender, Product_line  , Total_Qty
from 
(
SELECT
    Product_line,
    Gender,
    round(SUM(Quantity),2) as Total_Qty,
    RANK() OVER( partition by gender  order by sum(Quantity) desc ) as rnk

from dbo.[WalmartSalesData.csv]
group by Product_line , Gender
) x 

WHERE rnk <=3


/* 
5. Payment Method Adoption by City
Analyze payment method preferences across cities.
 */
WITH Payment_Segmentation as 
(
SELECT
    City,
    Payment,
    COUNT(Payment) as Total_counts,
    sum(COUNT(Payment)) OVER (PARTITION by city) as Total_Payments_by_City

from dbo.[WalmartSalesData.csv]
group by City , Payment 
) 

select 
    city,
    payment , 
    round(cast(Total_counts as float) / CAST(Total_Payments_by_City as float)  * 100,2) as Payment_Preferrence
from payment_segmentation;



/* 
6. Monthly Sales Growth Rate
Calculate month-over-month sales growth for each branch.
 */
WITH monthly_sales AS (

    SELECT 
        Branch, 
        DATEPART(MONTH, [Date]) AS Month,
        ROUND(SUM(Total), 2) AS Monthly_Total, 
        LAG(ROUND(SUM(Total), 2)) OVER (PARTITION BY Branch ORDER BY DATEPART(MONTH, [Date])) AS Previous_Month_Total 
    FROM dbo.[WalmartSalesData.csv]
    GROUP BY Branch, DATEPART(MONTH, [Date])
)
SELECT 
    Branch, 
    Month, 
    Monthly_Total, 
    ROUND(((Monthly_Total - Previous_Month_Total) / Previous_Month_Total) * 100, 2) AS Growth_Percent
FROM monthly_sales;




/* 
7.Tax Efficiency by Product Line
 */
SELECT 
    Product_line,
    round(SUM(Tax_5),2) as Tax_Collected,
    round(SUM(Total),2) as Revenue_Collected , 
   round(( round(SUM(Tax_5),2) / round(SUM(Total),2) ) * 100 ,2) as Tax_Percentage

from dbo.[WalmartSalesData.csv]
group by Product_line;


/* 
8. Peak Sales Days for every Month
 */
WITH RankedSales AS (
    SELECT 
        DATENAME(MONTH, [Date]) AS Month,
        DATENAME(WEEKDAY, [Date]) AS Weekday,
        round(SUM(Total),2) AS Total_Sales,
        MONTH([Date]) AS Month_Number, 
        RANK() OVER (PARTITION BY DATENAME(MONTH, [Date]) ORDER BY SUM(Total) DESC) AS Rank
    FROM dbo.[WalmartSalesData.csv]
    GROUP BY DATENAME(MONTH, [Date]), DATENAME(WEEKDAY, [Date]), MONTH([Date])
)
SELECT 
    Month, 
    Weekday, 
    Total_Sales
FROM RankedSales
WHERE Rank IN (1,2,3)
ORDER BY Month_Number;  


/* 
9.  Gender-Product Line Alignment
 */
WITH gender_stats AS
(
    SELECT 
        Product_line,
        Gender,
        COUNT(Gender) AS Count_by_Gender,
        SUM(COUNT(Gender)) OVER (PARTITION BY Product_line) AS Total_Count
    FROM dbo.[WalmartSalesData.csv]
    GROUP BY Product_line, Gender
)
SELECT 
    Product_line,
    round(SUM(CASE WHEN Gender = 'Female' THEN CAST(Count_by_Gender * 1.0 / Total_Count AS FLOAT) * 100 ELSE 0 END),2) AS Female_percentage,
    round(SUM(CASE WHEN Gender = 'Male' THEN CAST(Count_by_Gender * 1.0 / Total_Count AS FLOAT) * 100 ELSE 0 END),2) AS Male_percentage
FROM gender_stats
GROUP BY Product_line;


/* 
10. Seasonal Product Performance
Identify product lines with >20% sales increase in specific months.
 */
WITH sales_stats AS 
(
    SELECT
        Product_line, 
        DATENAME(MONTH, [Date]) AS Month_Name,
        DATEPART(MONTH, [Date]) AS Month_Number, 
        SUM(Total) AS Monthly_Sales, 
        LAG(SUM(Total)) OVER (PARTITION BY Product_line ORDER BY DATEPART(MONTH, [Date])) AS previous_month_sales, 
        SUM(Total) - LAG(SUM(Total)) OVER (PARTITION BY Product_line ORDER BY DATEPART(MONTH, [Date])) AS difference
    FROM dbo.[WalmartSalesData.csv]
    GROUP BY Product_line, DATENAME(MONTH, [Date]), DATEPART(MONTH, [Date])
)

SELECT
    Product_line, 
    Month_Name,
    round(CAST(difference / previous_month_sales AS FLOAT) * 100,2) AS Percent_Change
FROM sales_stats 
WHERE  CAST(difference / previous_month_sales AS FLOAT) * 100 >= 20; 


/* 
10. Branch Efficiency
Compare branches by sales per transaction and customer volume.
 */
SELECT
    Branch,
    COUNT(Invoice_ID) as total_transactions , 
    round(round(SUM(Total) ,2) / COUNT(Invoice_ID),2) as Price_Per_Transaction,  
    round(SUM(Total) / COUNT(DISTINCT Customer_type),2) AS revenue_per_customer


from dbo.[WalmartSalesData.csv]
group by Branch 
order by branch;



/* 
11. Bulk Purchase Analysis
 */
SELECT 
  CASE 
    WHEN Quantity > 5 THEN 'Bulk'
    ELSE 'Regular'
  END AS purchase_type,
  COUNT(*) as Counts_Per_Purchase_Type,
  round(AVG(gross_income),2) AS avg_gross_income,
  round(SUM(gross_income) / SUM(Quantity),2) AS income_per_unit

FROM dbo.[WalmartSalesData.csv]
GROUP BY CASE 
    WHEN Quantity > 5 THEN 'Bulk'
    ELSE 'Regular'
  END;


/* 
12. Geographic Market Penetration
 */
WITH stats AS 
(
    SELECT
        City, 
        Product_line, 
        SUM(Total) AS Sales_per_product_line, 
        SUM(SUM(Total)) OVER (PARTITION BY City) AS Sales_per_City
    FROM dbo.[WalmartSalesData.csv]
    GROUP BY City, Product_line
),
ranked_stats AS 
(
    SELECT 
        City, 
        Product_line,
        ROUND(CAST(Sales_per_product_line AS FLOAT) / Sales_per_City * 100, 2) AS Market_Share,
        RANK() OVER (PARTITION BY City ORDER BY Sales_per_product_line DESC) AS rank_order
    FROM stats
)
SELECT 
    City, 
    Product_line, 
    Market_Share
FROM ranked_stats
WHERE rank_order = 1;














































