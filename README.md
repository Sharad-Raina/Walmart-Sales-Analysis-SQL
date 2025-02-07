# Walmart Sales Analysis - SQL Data Exploration Project

## 📌 Project Overview  
This project analyzes **Walmart sales data** (Kaggle dataset) to uncover transactional patterns, customer behavior, and product performance. The goal is to demonstrate SQL proficiency in data cleaning, exploratory analysis, and business intelligence-driven queries.

![9855345](https://github.com/user-attachments/assets/c16088a4-6cd5-4d25-ab2a-5273d0d880f4)



---

## 🛠️ Tools Used  
- **SQL** (T-SQL compatible) for end-to-end analysis  
- **Window Functions** (RANK, ROW_NUMBER)  
- **CTEs** and complex subqueries  
- **Aggregation** with dynamic metric calculations  

---

## 🔍 Key Analyses Performed  
1. **Data Quality Checks**  
   - Column schema validation (data types, null values)  
   - Basic statistics for numerical metrics (min/avg/max, missing values)  

2. **Customer Segmentation**  
   - Member vs. non-member revenue contribution  
   - Gender-based purchasing patterns  
   - City-level customer type distribution  

3. **Product & Sales Analysis**  
   - Hourly/daily/monthly sales trends by branch  
   - Product line performance across cities (market share %)  
   - Tax efficiency per product category  

4. **Operational Insights**  
   - Payment method preferences by region  
   - Bulk purchase profitability analysis  
   - Branch efficiency (revenue per transaction/customer)  

---

## 💡 Technical Skills Demonstrated  
- **Complex Joins**: Multi-layered CTEs for hierarchical calculations  
- **Time Intelligence**: `DATEPART` for hourly/monthly trend extraction  
- **Advanced Filtering**: `CASE WHEN` logic for dynamic segmentation  
- **Window Functions**: Ranked sales performance across dimensions  
- **Data Type Handling**: Conversion/casting for percentage metrics  

---
## 🔍 SQL Code Highlights  

### 1. **Monthly Sales Growth Calculation**  
```sql
-- CTE + Window Function for MoM Growth
WITH monthly_sales AS (
    SELECT 
        Branch, 
        DATEPART(MONTH, [Date]) AS Month,
        ROUND(SUM(Total), 2) AS Monthly_Total, 
        LAG(SUM(Total)) OVER (
            PARTITION BY Branch 
            ORDER BY DATEPART(MONTH, [Date])
        ) AS Previous_Month_Total 
    FROM dbo.[WalmartSalesData.csv]
    GROUP BY Branch, DATEPART(MONTH, [Date])
)
SELECT 
    Branch, 
    Month, 
    Monthly_Total, 
    CASE 
        WHEN Previous_Month_Total = 0 THEN 0 
        ELSE ROUND(
            ((Monthly_Total - Previous_Month_Total) / Previous_Month_Total) * 100, 
            2
        ) 
    END AS Growth_Percent
FROM monthly_sales;
```
### 2. **Product Line Market Share by City**  
```sql
-- Nested Aggregation with Window Functions
WITH city_sales AS (
    SELECT 
        City, 
        Product_line, 
        SUM(Total) AS Product_Revenue,
        SUM(SUM(Total)) OVER (PARTITION BY City) AS City_Total_Revenue 
    FROM dbo.[WalmartSalesData.csv]
    GROUP BY City, Product_line 
)
SELECT 
    City, 
    Product_line, 
    ROUND(
        (Product_Revenue / City_Total_Revenue) * 100, 
        2
    ) AS Market_Share_Percent
FROM city_sales
ORDER BY City, Market_Share_Percent DESC;

```


### 3. **Gender-Based Product Preferences**
```sql

-- Subquery + Ranking for Top 3 Products per Gender
SELECT Gender, Product_line, Total_Qty
FROM (
    SELECT
        Product_line,
        Gender,
        ROUND(SUM(Quantity), 2) AS Total_Qty,
        RANK() OVER (
            PARTITION BY Gender 
            ORDER BY SUM(Quantity) DESC
        ) AS Rank
    FROM dbo.[WalmartSalesData.csv]
    GROUP BY Product_line, Gender
) ranked_data 
WHERE Rank <= 3;


```



## 📈 Key Insights Highlight  
- **Premium Members** generate **~15% more revenue** than regular customers.  
- Peak sales occur at **11 AM** (Branch A) and **7 PM** (Branch B).  
- **Electronic accessories** dominate sales in Yangon (28% market share).  
- **Female customers** prefer health/beauty products (63% of sales).  

---

