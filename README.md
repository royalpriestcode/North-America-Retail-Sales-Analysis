# North America Retail Sales Optimization Analysis

## Project Overview
I analyzed the sales data for North America Retail, 
a leading company that offers a wide range of products to different customer segments. 
My analysis focused on extracting key insights
about profitability, overall business performance, and customer behavior.
To do this, I worked with datasets containing detailed information 
on customers, orders, products, locations, returns, and profits. 
My process involved identifying and building relationships within these datasets,
then clearly explaining these patterns. Through this work, 
I identified concrete growth opportunities and 
developed strategic recommendations to help optimize revenue and streamline operations.

## Data Source
The dataset used is Retail Supply Sales Chain Analysis.csv

## Tools Used
- SQL

## Data Cleaning and Preparation
1. Data Importation and Inspection
2. Splitted the data into facts and dimension Tables
3. Create an Entity Relationship Diagram(ERD)

## Objectives
1. What was the Average delivery days for different product subcategory?
2. What was the Average delivery days for each segment ?
3. What are the Top 5 Fastest delivered products and Top 5 slowest delivered products?
4. Which product Subcategory generate most profit?
5. Which segment generates the most profit?
6. Which Top 5 customers made the most profit?
7. What is the total number of products by Subcategory

## Data Analysis
### 1. What was the Average delivery days for different product subcategory?
```sql
SELECT Sub_Category, AVG(DATEDIFF(day, oft.Order_Date, oft.Ship_Date)) AS Delivery_Date
 FROM OrdersFactable AS oft
 LEFT JOIN DimProducts AS dp
 ON oft. Product_Key = dp.Product_Key
 GROUP BY Sub_Category;
 /* it takes an average of 32 days to deliver Products in the Clothes and bookcases subcategory
 and an average of 34 days to deliver the furnishings subcategory and also an average of 36 days to 
 deliver Products in the Tables subcategory*/
```
### 2. What was the Average delivery days for each segment ?
```sql
 SELECT Segment, AVG(DATEDIFF(day, Order_Date, Ship_Date)) AS Delivery_Date
 FROM OrdersFactable
 GROUP BY Segment
 ORDER BY 2 DESC
 /* it takes an avarage of 35 delivery days to get products to the corporate segment, 
 and average of 34 days to deliver products tothe consumer customer segment and
 31 days to deliver products to the Home Office customer segment*/
```
### 3. What are the Top 5 Fastest delivered products and Top 5 slowest delivered products?
```sql
 SELECT Top 5(dp.Product_Name), (DATEDIFF(day, oft.Order_Date, oft.Ship_Date)) AS Delivery_Date
 FROM OrdersFactable AS oft
 LEFT JOIN DimProducts AS dp
 ON oft. Product_Key = dp.Product_Key
 ORDER BY 2 ASC

 /* The top five fastest delivered products with 0 delivery days are
 Sauder Camden County Barrister Bookcase, Planked Cherry Finish
Sauder Inglewood Library Bookcases
O'Sullivan 2-Shelf Heavy-Duty Bookcases
O'Sullivan Plantations 2-Door Library in Landvery Oak
O'Sullivan Plantations 2-Door Library in Landvery Oak */


--What are the Top 5 slowest delivered products?
 SELECT Top 5(dp.Product_Name), (DATEDIFF(day, oft.Order_Date, oft.Ship_Date)) AS Delivery_Date
 FROM OrdersFactable AS oft
 LEFT JOIN DimProducts AS dp
 ON oft. Product_Key = dp.Product_Key
 ORDER BY 2 DESC;

 /* The top five slowest delivered products with 214 delivery days are
 Bush Mission Pointe Library
Hon Multipurpose Stacking Arm Chairs
Global Ergonomic Managers Chair
Tensor Brushed Steel Torchiere Floor Lamp
Howard Miller 11-1/2" Diameter Brentwood Wall Clock */
```
### 4. Which product Subcategory generate most profit?
``` sql
SELECT dp.Sub_Category, ROUND(SUM(oft.Profit),2) AS TotalProfit
 FROM OrdersFactable AS oft
 LEFT JOIN DimProducts AS dp
 ON oft. Product_Key = dp.Product_Key
 WHERE oft.Profit > 0
 GROUP BY Sub_Category
 ORDER BY 2 DESC;

 /*The Sub-category Chairs generates the highest profit with a total of $36471.1 
 while the least comes from table with 8358.33*/
```

### 5. Which segment generates the most profit?
``` sql
 SELECT Segment, ROUND(SUM(Profit),2) AS TotalProfit
 FROM OrdersFactable 
 WHere Profit > 0
 GROUP BY Segment
 ORDER BY 2 DESC;

 /* The Consumer Customer Segment generates the most profit
 with Total profit of 35427.03*/
```

### 6. Which Top 5 customers made the most profit?
``` sql
SELECT Top 5(dc.Customer_Name), ROUND(SUM(Profit),2) AS TotalProfit
FROM OrdersFactable AS oft
LEFT JOIN DimCustomer AS dc
ON oft.Customer_ID = dc.Customer_ID
WHERE Profit > 0
GROUP BY Customer_Name
ORDER BY 2 DESC

/* The top 5 customers that made the most profit are 
Laura Armstrong
Joe Elijah
Seth Vernon
Quincy Jones
Maria Etezadi
*/
```

### 7. What is the total number of products by Subcategory
``` sql
SELECT Sub_Category, COUNT(DISTINCT Product_Name) AS TotalProducts
FROM DimProducts
GROUP BY Sub_Category
/* The total products for each sub-category are 48, 87,184,34 for Bookcases,Chairs, Furnishings, Tables respectively.*/
```

### Insights

- Delivery times vary significantly, with Tables taking the longest to deliver (36 days), while Clothes and Bookcases average 32 days
- The Home Office segment receives orders fastest (31 days), while Corporate customers wait the longest (35 days)
- Some products, like certain Bookcases, ship the same day, while others, like select Furnishings, take up to 214 days
- Chairs generate significantly more profit than any other category, earning four times more than Tables
- The Consumer segment contributes the highest share of total profit compared to other customer groups
- Furnishings have the most product variety (184 items) while tables have least (34)

### Recommendations:

- Investigate and fix the extremely slow deliveries (214 days)
- Analyze why Chairs outperform Tables despite having similar delivery times to uncover replicable success factors
- Develop targeted strategies to increase spending within the high-value Consumer segment
- Work to reduce corporate customer delivery times
- Consider offering segment-specific delivery options, such as priority shipping for Corporate clients
- Examine what drives faster order processing for Home Office customers and apply similar methods across other segments
- Consider expanding table product variety since current selection is limited
