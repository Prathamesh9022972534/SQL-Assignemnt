-- Creating Database 
CREATE DATABASE ECommerceDB ;

USE ECommerceDB;

-- Creating Columns With Constraints Specified
CREATE TABLE Category
(
CategoryID INT PRIMARY KEY,
CategoryName VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Products
(
ProductID INT PRIMARY KEY,
ProductName VARCHAR(100) NOT NULL UNIQUE,
CategoryID INT,
FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID),
Price DECIMAL(10,2) NOT NULL,
StockQuantity INT
);

CREATE TABLE Customer
(
CustomerID INT PRIMARY KEY,
CustomerName VARCHAR(100) NOT NULL,
Email VARCHAR(100) UNIQUE,
JoinDate DATE
);

CREATE TABLE Orderds
(
OrderID INT PRIMARY KEY,
CustomerID INT,
FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
OrderDate DATE NOT NULL,
TotalAmount DECIMAL(10,2)
);

-- Correcting My Mistake
ALTER TABLE Orderds
RENAME Orders;

-- Inserting Given Data 
INSERT INTO Category (CategoryID, CategoryName) VALUES
(1, 'Electronics'),
(2, 'Books'),
(3, 'Home Goods'),
(4, 'Apparel');

INSERT INTO Products (ProductID, ProductName, CategoryID, Price, StockQuantity) VALUES
(101, 'Laptop Pro', 1 , 1200, 50),
(102, 'SQL Handbook', 2, 45.50, 200),
(103, 'Smart Speaker', 1, 99.99, 150),
(104, 'Coffee Maker', 3, 75, 80),
(105, 'Novel: The Great SQL ', 2, 25, 120),
(106, 'Wireless Earbuds',1 , 150, 100),
(107, 'Blender X', 3, 120, 60),
(108, 'T-Shirt Casual', 4, 20,300);

INSERT INTO Customer (CustomerID, CustomerName, Email, JoinDate) VALUES 
(1, 'Alice Wonderland', 'alice@example.com', '2023-01-10'),
(2, 'Bob The Builder', 'bob@example.com', '2022-11-25'),
(3, 'Charlie Chaplin', 'charlie@example.com', '2023-03-01'),
(4, 'Diana Prince', 'diana@example.com','2021-01-26' );

INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount) VALUES
(1001, 1, '2023-04-12', 1245.50),
(1002, 2, '2023-10-12', 99.99),
(1003, 1, '2023-07-01', 145),
(1004, 3, '2023-01-14', 150),
(1005, 2, '2023-09-24', 120),
(1006, 1, '2023-06-19', 20);

/* 7 Generate a report showing CustomerName, Email, and the TotalNumberofOrders for each customer. Include customers who have not 
placed any orders, in which case their TotalNumberofOrders should be 0. Order the results by CustomerName */

SELECT C.CustomerName, C.Email, COUNT(O.OrderID) TotalNumberofOrders
FROM Orders O
RIGHT JOIN Customer C ON C.CustomerID = O.CustomerID 
GROUP BY C.CustomerName, C.Email, C.CustomerID
ORDER BY C.CustomerName;

/* 8 Retrieve Product Information with Category: Write a SQL query to 
display the ProductName, Price, StockQuantity, and CategoryName for all 
products. Order the results by CategoryName and then ProductName alphabetically */

SELECT P.ProductName, P.Price, P.StockQuantity, C.CategoryName
FROM Products p 
JOIN Category C ON C.CategoryID = P.CategoryID
ORDER BY C.CategoryName, P.ProductName;

/* 9 Write a SQL query that uses a Common Table Expression (CTE) and a 
Window Function (specifically ROW_NUMBER() or RANK()) to display the 
CategoryName, ProductName, and Price for the top 2 most expensive products in 
each CategoryName */ 
WITH ProductList AS
(
SELECT C.CategoryName, P.ProductName, P.Price ProductPrice
FROM Products P
JOIN Category C ON C.CategoryID = P.CategoryID 
), Ranking AS
(
SELECT PL.ProductName, PL.CategoryName, PL.ProductPrice, 
ROW_NUMBER () OVER(PARTITION BY PL.CategoryName ORDER BY PL.ProductPrice DESC) ProductRank
FROM ProductList PL
)
SELECT R.CategoryName, R.ProductName, R.ProductPrice, R.ProductRank
FROM Ranking R 
WHERE R.ProductRank <= 2 
ORDER BY  R.ProductPrice ,R.ProductRank DESC;


USE Sakila;
/*10 You are hired as a data analyst by Sakila Video Rentals, a global movie 
rental company. The management team is looking to improve decision-making by 
analyzing existing customer, rental, and inventory data.*/

/* i) Identify the top 5 customers based on the total amount they’ve spent. Include customer name, 
email, and total amount spent */

SELECT C.Customer_ID,CONCAT(C.First_Name,' ',C.Last_Name) CustomerName, C.Email, SUM(P.Amount) TotalAmtSpend
FROM Customer C
JOIN Payment P ON C.Customer_ID = P.Customer_ID 
GROUP BY C.First_Name, C.Last_Name, C.Email, C.Customer_ID
ORDER BY TotalAmtSpend DESC
LIMIT 5;

/* ii) Which 3 movie categories have the highest rental counts? Display the category name 
and number of times movies from that category were rented */

SELECT C.Category_ID, C.Name CategoryName, COUNT(R.Rental_ID) RentalFilmCount 
FROM Film F 
JOIN Film_Category FC ON FC.Film_ID = F.Film_ID
JOIN Category C ON C.Category_ID = FC.Category_ID
JOIN Inventory I ON I.Film_ID = F.Film_ID 
JOIN Rental R ON R.Inventory_ID = I.Inventory_ID 
GROUP BY C.Category_ID, C.Name 
ORDER BY RentalFilmCount DESC
LIMIT 3;

/* iii) Calculate how many films are available at each store and how many of those have 
never been rented*/
-- Store 
-- Film
-- Rental 
WITH FilmList AS
(
SELECT S.Store_ID, I.Inventory_ID, F.Film_ID, R.Inventory_ID RentalInventoryID,R.Rental_ID
FROM Film F
JOIN Inventory I ON I.Film_ID = F.Film_ID
JOIN Store S ON S.Store_ID = I.Store_ID
JOIN Rental R ON R.Inventory_ID = I.Inventory_ID 
), FilmCountAtStore AS
(
SELECT FL.Store_ID, COUNT(FL.Film_ID) FilmCount
FROM FilmList FL 
GROUP BY FL.Store_ID
), FilmNotRented AS
(
SELECT COUNT(FL.Film_Id) FilmNotRent
FROM FilmList FL 
WHERE FL.Inventory_ID <> FL.RentalInventoryID
)
SELECT FCT.Store_ID, FCT.FilmCount, FNR.FilmNotRent
FROM FilmCountAtStore FCT
CROSS JOIN FilmNotRented FNR;

SELECT I.Store_ID, Count(DISTINCT I.Film_ID) Film_Count, 
COUNT(CASE 
	WHEN I.Inventory_ID = R.Inventory_ID THEN 'Not Found'
    END) AS FilmNotRented
FROM Inventory I 
RIGHT JOIN Rental R ON R.Inventory_ID = I.Inventory_ID
GROUP BY I.Store_ID;

/* iv) Show the total revenue per month for the year 2023 to analyze business seasonality.*/
-- As There Is No Data For Year 2023, Only 2005 And 2006 Data Are Available So,
SELECT YEAR(P.Payment_Date) YEAR, MONTHNAME(P.Payment_Date) MonthName, SUM(P.Amount) Total_Revenue
FROM Payment P 
-- WHERE YEAR(P.Payment_Date) = 2023
GROUP BY YEAR(P.Payment_Date), MONTHNAME(P.Payment_Date)
ORDER BY YEAR, MonthName;

/* v) Identify customers who have rented more than 10 times in the last 6 months */
WITH CustomerList AS
(
SELECT YEAR(R.Rental_Date) Year, MONTHNAME(R.Rental_Date) MonthName, R.Customer_ID, 
CONCAT(C.First_Name," ",C.Last_Name) CustomerName, COUNT(Rental_ID) RentalMovieCount 
FROM Rental R 
JOIN Customer C ON C.Customer_ID = R.Customer_ID
-- WHERE R.Rental_Date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY YEAR(R.Rental_Date), MONTHNAME(R.Rental_Date), R.Customer_ID, C.First_Name, C.Last_Name
ORDER BY RentalMovieCount DESC
) 
SELECT CL.YEAR, CL.MonthName, CL.Customer_ID, CL.CustomerName, CL.RentalMovieCount 
FROM CustomerList CL 
WHERE CL.RentalMovieCount > 10 
ORDER BY CL.RentalMovieCount DESC;
