SELECT * FROM [Sales Retail]

--To create a DimCustomer Table from the Sales retail table
SELECT * INTO DimCustomer 
FROM 
	(SELECT Customer_ID, Customer_Name FROM [Sales Retail])
AS
DimCust

SELECT * FROM DimCustomer;

-- to remove duplicates from the DImCustomertable
WITH CTE_DimCust
AS
	(SELECT Customer_ID, Customer_Name, ROW_NUMBER() OVER (PARTITION BY Customer_ID, Customer_Name ORDER BY Customer_ID ASC) AS RowNum
	 FROM DimCustomer)

	DELETE CTE_DimCust WHERE RowNum > 1; 



--to create the table for location from Sales Retails
SELECT * INTO DimLocation
FROM
	(SELECT Postal_Code, Country, City, State, Region
	FROM [Sales Retail]
	) 
AS DimLoc
SELECT * FROM DimLocation

-- to remove duplicates from the DImLocationtable
WITH CTE_DimL
AS
	(SELECT Postal_Code, Country, City, State, Region, ROW_NUMBER() OVER (PARTITION BY Postal_Code, Country, City, State, Region ORDER BY Postal_Code ASC) AS RowNum
	 FROM DimLocation)

	DELETE CTE_DimL WHERE RowNum > 1; 



--to create the table for products from Sales Retails
SELECT * INTO DimProducts
FROM
	(SELECT Product_ID, Category, Sub_Category, Product_Name
	FROM [Sales Retail]
	)
AS DimProd

SELECT * FROM DimProducts
DROP TABLE DimProducts
--to remove duplicates from te DimpProducts table

WITH CTE_DimP
AS
	(SELECT  Product_ID, Category, Sub_Category, Product_Name, ROW_NUMBER() OVER(Partition by Product_ID, Category, Sub_Category, Product_Name ORDER BY Product_ID ASC) AS RowNum
	FROM DimProducts)

DELETE CTE_DImP where RowNum > 1

SELECT * FROM DimProducts



--to create the OrdersFactable

SELECT * INTO OrdersFactable
FROM
	(SELECT Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, Segment, Postal_Code, Retail_Sales_People, Product_ID, Returned, Sales, Quantity, Discount, Profit
	FROM [Sales Retail]
	)
AS OrdersFact
SELECT * FROM OrdersFactable

--to remove duplicates from the OrdersFactable table

WITH CTE_Orders
AS
	(SELECT  Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, Postal_Code, Retail_Sales_People, Product_ID, Returned, Sales, Quantity, Discount, Profit, ROW_NUMBER() 
	OVER(Partition by Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, Postal_Code, Retail_Sales_People, Product_ID, Returned, Sales, Quantity, Discount, Profit
	ORDER BY Order_ID ASC) AS RowNum
	FROM OrdersFactable)

DELETE CTE_Orders where RowNum > 1



--for searching duplicate key in DimProducts
SELECT * FROM DimProducts
WHERE Product_ID = 'FUR-FU-10004091'

--to add a new column(surrogate key) called Product KEy to serve as a unique identifier for the table Dimproducts. 
ALTER TABLE DimProducts
ADD Product_Key INT IDENTITY (1,1) PRIMARY KEY;

--to add the product key to the OrdersFactable
ALTER TABLE OrdersFactable
ADD Product_Key INT;

UPDATE OrdersFactable
SET Product_Key = DimProducts.Product_Key
FROM OrdersFactable
JOIN DimProducts
ON OrdersFactable.Product_ID = DimProducts.Product_ID

--to drop the Product_ID in the DimProducts

ALTER TABLE DimProducts
DROP COLUMN Product_ID

--to drop the Product_ID in the DimProducts
ALTER TABLE OrdersFactable
DROP COLUMN Product_ID

SELECT * FROM OrdersFactable
WHERE
 Order_ID = 'CA-2014-102652'

 --to add a unique identifier to the OdersFactable
 ALTER TABLE OrdersFactable
 ADD Row_ID INT IDENTITY (1,1)




 --Exploratory Analysis 

 -- What was the Average delivery days for different product subcategory?
 SELECT Sub_Category, AVG(DATEDIFF(day, oft.Order_Date, oft.Ship_Date)) AS Delivery_Date
 FROM OrdersFactable AS oft
 LEFT JOIN DimProducts AS dp
 ON oft. Product_Key = dp.Product_Key
 GROUP BY Sub_Category;
 /* it takes an average of 32 days to deliver Products in the Clothes and bookcases subcategory
 and an average of 34 days to deliver the furnishings subcategory and also an average of 36 days to 
 deliver Products in the Tables subcategory*/


 --What was the Average delivery days for each segment?
  SELECT Segment, AVG(DATEDIFF(day, Order_Date, Ship_Date)) AS Delivery_Date
 FROM OrdersFactable
 GROUP BY Segment
 ORDER BY 2 DESC
 /* it takes an avarage of 35 delivery days to get products to the corporate segment, 
 and average of 34 days to deliver products tothe consumer customer segment and
 31 days to deliver products to the Home Office customer segment*/


 --What are the Top 5 Fastest delivered products and Top 5 slowest delivered products?
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


--Which product Subcategory generate most profit
 SELECT dp.Sub_Category, ROUND(SUM(oft.Profit),2) AS TotalProfit
 FROM OrdersFactable AS oft
 LEFT JOIN DimProducts AS dp
 ON oft. Product_Key = dp.Product_Key
 WHERE oft.Profit > 0
 GROUP BY Sub_Category
 ORDER BY 2 DESC;

 /*The Sub-category Chairs generates the highest profit with a total of $36471.1 
 while the least comes from table with 8358.33*/


 --Which segment generates the most profit?
 SELECT Segment, ROUND(SUM(Profit),2) AS TotalProfit
 FROM OrdersFactable 
 WHere Profit > 0
 GROUP BY Segment
 ORDER BY 2 DESC;

 /* The Consumer Customer Segment generates the most profit 
 with Total profit of 35427.03*/


 --Which Top 5 customers made the most profit
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
C:\Users\user\AppData\Local\Temp\~vs808C.sql
-- What is the total number of Products by SubCategory

SELECT Sub_Category, COUNT(DISTINCT Product_Name) AS TotalProducts
FROM DimProducts
GROUP BY Sub_Category
/* THe total products for each sub-category are 48, 87,184,34 for Bookcases,Chairs, Furnishings, Tables respectively.*/