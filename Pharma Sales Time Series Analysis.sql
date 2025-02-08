----------------------------------CREATE DATABASE------------------------------
/*Create Database*/
Create  Database sales;
/*use Database*/
use sales;
--------------------------------------CREAT TABE------------------------------------------------
/* Create_table*/
Create Table Orders
(order_id int primary key identity (1,1),
Date_order Date Not Null ,
M01AB float, 
M01AE float,
N02BA float,
N02BE float,
N05B float,
N05C float,
R03	 float,
R06	 float,
Years  int,
Months int ,
Hours	int	,
Weekday_Name varchar (250), 
);
----------------------------------INSERT EXCEL FILE--------------------------------------------------------
/* Insert excel from PC*/
BULK INSERT Orders
FROM 'D:\Data Analysis\Project\Data Analysis\salesdaily.csv'
WITH (
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 -- Skip header row
);
----------------------------------UPDATE------------------------------------------
/*Update*/
UPDATE Orders
SET M01AB = 1, M01AE = 1
WHERE order_id = 1;
----------------------
UPDATE Orders
Set sum_order=M01AB+M01AE+N02BA+N02BE+N05B+N05C+R03+R06;
/*SELECT*/
-----------------------------------SELECT-----------------------------------------------------------
/*SELECT ALL*/
Select* from Orders;
/*Select non Dublicate*/
Select Distinct * from Orders;
-----------------------------------------------
/*Select not null*/
SELECT * 
FROM Orders
WHERE Weekday_Name IS NOT NULL;
----------------------------------------------------------------------
/*select sum_order by another  (sum of columns) */
Select M01AB,M01AB,M01AE,N02BA,N02BE,N05B,N05C,R03,R06,(M01AB+M01AE+N02BA+N02BE+N05B+N05C+R03+R06) as sum_order
From Orders;
---------------------------------------------------------------------
/*SelectOrdering sum Desc*/
Select * From Orders
Order By sum_order DESC;
/*Select WHERE CONDITION ON MONTH*/
Select M01AB,M01AB  from Orders
Where Months =1;
/*Select WHERE CONDITION ON YEARS*/
Select*  from Orders
Where Years BETWEEN 2014 AND 2016;
/*Select Where Day*/
Select*  from Orders
Where Weekday_Name ='Friday' ;
/*Ordering ASC*/
Select Date_order, M01AB from Orders
Order by M01AB ASC ;
/*Ordering DSC*/
Select Date_order,M01AE from Orders
Order by M01AE DESC;
/*Logical Conditions*/
Select  Date_order ,M01AB,M01AE from Orders
WHERE M01AB>3 AND M01AE>2
Order by M01AB ASC, M01AE DESC;
/*Logical Conditions*/
Select  Date_order,M01AB,M01AE
from Orders
WHERE M01AB<>0 AND M01AE<>0
Order by M01AB ASC, M01AE ASC;
/*Aggregrate sum*/
Select sum(M01AB) as Total_M01AB,
sum(M01AE) as Total_M01AE,
sum(N02BA) as Total_N02BA,
sum(N02BE) as Total_N02BE,
sum(N05B) as Total_N05B,
sum(N05C) as Total_N05C,
sum(R03) as Total_R03,
sum(R06) as Total_R06,
Greatest(sum(M01AE),
sum(N02BA),
sum(N02BE),
sum(N05B),
sum(N05C),
sum(R03),
sum(R06)
) As Max_Order
From Orders; 
/*Aggregrate Max*/
SELECT 
 MAX(M01AB) AS Max_M01AB,
MAX(M01AE) AS Max_M01AE,
 MAX(N02BA) AS Max_N02BA,
 MAX(N02BE) AS Max_N02BE,
 MAX(N05B) AS Max_N05B,
 MAX(N05C) AS Max_N05C,
 MAX(R03) AS Max_R03,
 MAX(R06) AS Max_R06
FROM Orders;
Use Sales;
----------------------------UPDATE0 TO NULL----------------------------
UPDATE Orders
SET M01AB = NULL
WHERE M01AB = 0;
SELECT * FROM Orders;
--------------------------------UPDATE0 TO NULL (NULLIF)---------------------
UPDATE Orders
SET M01AB =NULLIF(M01AB,0);
SELECT * FROM Orders;
--------------------------------Cleaning---------------------------------
UPDATE Orders
SET M01AB = 0
WHERE M01AB IS NULL;
SELECT * FROM Orders;
------------------------------Cleaning_Coalesce----------------------
UPDATE Orders
SET M01AB =COALESCE(M01AB,0)
SELECT * FROM Orders;
------------------------------------Questions---------------------------------
*Q1) Find the month with the highest total sales for the product M01AB
 in each year.*/
 -----------------------------------------Q------------------------------------------------
 /**We need use two select as following:
SELECT
Year,Month,Total_sales
FROM( 
SELECT Year,Month,SUM
FROM TABLE_NAME
 GROUP BY YEAR, MONTH
) As name
*/
SELECT Years, Months, Total_Sales_M01AB
FROM (
    SELECT 
        Years,Months,SUM(M01AB) AS Total_Sales_M01AB,
/*Assigns a rank to each month within a year based on total sales of M01AB, in descending order
Rank() over (partation by year order by sum as desc*/
        RANK() OVER (PARTITION BY Years ORDER BY SUM(M01AB) DESC) AS Rank
    FROM Orders
    GROUP BY Years, Months
) AS RankedSales
/*Filters the result to include only the top-ranked month for each year.*/
WHERE Rank = 1;
----------------------------------------------------------------------------------------------
/*Q2) Calculate the percentage of daily sales for the product M01AE
compared to the total sales of all products for each day.*/
--------------------------------------Q-------------------------------------------------------
/*We need use two select 
SELECT
DATE,SUM
FROM( 
SELECT DATE,ITEM,SUM
FROM TABLE_NAME
) As name
Group by DATE Order
*/
SELECT 
    Date_order,
    SUM(M01AE) AS Total_M01AE,
	/*IF SUM(Total Sales )=0 we need case condition*/
	/*Case   
	WHEN  Item=value THEN n_value
	ElSE other_value EndAS name
	*/
	CASE 
        WHEN SUM(TotalSales) = 0 THEN 0
        ELSE SUM(M01AE) * 100.0 / SUM(TotalSales)
    END AS Percentage_M01AE
FROM (
    SELECT 
        Date_order,
        M01AE,
        (M01AB + M01AE + N02BA + N02BE + N05B + N05C + R03 + R06) AS TotalSales
    FROM Orders
) AS DailySales
GROUP BY Date_order;
-----------------------------------------------------------------------------------------------
/*Q3)Find the days where sales for the product N05B were less than 10*/
----------------------------------------Q------------------------------------------------
SELECT 
    Date_order,
    N05B
FROM Orders
WHERE N05B < 10;
---------------------------------------------------------------------------------------------
/*Q4)Calculate the total sales for each product (M01AB, M01AE, N02BA, N02BE, N05B, N05C, R03, R06) for each year.*/ 
----------------------------------------------Q--------------------------------------------
SELECT 
    Years,
	SUM(M01AB) AS Total_M01AB,
    SUM(M01AE) AS Total_M01AE,
    SUM(N02BA) AS Total_N02BA,
    SUM(N02BE) AS Total_N02BE,
    SUM(N05B) AS Total_N05B,
    SUM(N05C) AS Total_N05C,
    SUM(R03) AS Total_R03,
    SUM(R06) AS Total_R06
FROM Orders
GROUP BY Years
ORDER BY Years;
-------------------------------------------------------------------------------------------------