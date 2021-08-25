--*************************************************************************--
-- Title: Assignment07
-- Author: SarahHogan
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,SarahHogan,Created File
-- github: https://github.com/SarahEH/DBFoundations-Module07
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_SarahHogan')
	 Begin 
	  Alter Database [Assignment07DB_SarahHogan] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_SarahHogan;
	 End
	Create Database Assignment07DB_SarahHogan;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_SarahHogan;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
******************************************************************************************/

-- Question 1 (5% of pts): What built-in SQL Server function can you use to show a list 
-- of Product names, and the price of each product, with the price formatted as US dollars?
-- Order the result by the product!

/*
--Step 1: Examine Products view data
Select * from vProducts;
go
--Step 2: down-select to the Name & Price, enforce order by
Select ProductName, UnitPrice
From vProducts
Order by ProductName;
go
*/
--Step 3: format dollars /// FINAL STEP
Select ProductName, 
	Format(UnitPrice, 'C', 'en-US') as UnitPrice
From vProducts
Order by ProductName;
go


-- Question 2 (10% of pts): What built-in SQL Server function can you use to show a list 
-- of Category and Product names, and the price of each product, 
-- with the price formatted as US dollars?
-- Order the result by the Category and Product!

/*
-- Step 1: start with code from Question 1
Select ProductName, 
	Format(UnitPrice, 'C', 'en-US') as UnitPrice
From vProducts
Order by ProductName;
go
*/
-- Step 2: incorporate join with category table for category name, and incorporate category name in order by /// FINAL
Select c.CategoryName,
	p.ProductName, 
	Format(p.UnitPrice, 'C', 'en-US') as UnitPrice
From vProducts p
	Join vCategories c 
		on p.CategoryID = c.CategoryID
Order by c.CategoryName, p.ProductName;
go

-- Question 3 (10% of pts): What built-in SQL Server function can you use to show a list 
-- of Product names, each Inventory Date, and the Inventory Count,
-- with the date formatted like "January, 2017?" 
-- Order the results by the Product, Date, and Count!

/*
-- Step 1: Start with Assignment 05, Question 2
Select P.ProductName, I.InventoryDate, I.Count
From vProducts P
Inner Join vInventories I 
  on P.ProductID = I.ProductID
Order by I.InventoryDate, P.ProductName, I.Count;
go
-- Step 2: rearrange order by
Select P.ProductName, I.InventoryDate, I.Count
From vProducts P
Inner Join vInventories I 
  on P.ProductID = I.ProductID
Order by P.ProductName, I.InventoryDate, I.Count;
go
*/
--Step 2: format inventory date /// FINAL
Select P.ProductName, 
	concat(datename(month,I.InventoryDate), ', ', datepart(year, I.InventoryDate)) as InventoryDate,
	I.Count
From vProducts P
	Join vInventories I 
		on P.ProductID = I.ProductID
Order by P.ProductName, datepart(month, InventoryDate), I.Count;
go

-- Question 4 (10% of pts): How can you CREATE A VIEW called vProductInventories 
-- That shows a list of Product names, each Inventory Date, and the Inventory Count, 
-- with the date FORMATTED like January, 2017? Order the results by the Product, Date,
-- and Count!
/*
--Step 1: start with code from question 3
Select P.ProductName, 
	concat(datename(month,I.InventoryDate), ', ', datepart(year, I.InventoryDate)) as InventoryDate,
	I.Count
From vProducts P
	Join vInventories I 
		on P.ProductID = I.ProductID
Order by P.ProductName, I.InventoryDate, I.Count;
go
*/
--Step 2: wrap it in a create view statement, using 'top' to retain ordering /// FINAL
Create --Drop
View vProductInventories
As 
	Select Top 1000000000
		P.ProductName, 
		concat(datename(month,I.InventoryDate), ', ', datepart(year, I.InventoryDate)) as InventoryDate,
		I.Count as InventoryCount
	From vProducts P
		Join vInventories I 
			on P.ProductID = I.ProductID
	Order by P.ProductName, datepart(month, InventoryDate), I.Count;
go

Select * From vProductInventories;
go

-- Question 5 (10% of pts): How can you CREATE A VIEW called vCategoryInventories 
-- that shows a list of Category names, Inventory Dates, 
-- and a TOTAL Inventory Count BY CATEGORY, with the date FORMATTED like January, 2017?

/*
-- Step 1: start with script from question 3
Select P.ProductName, 
	concat(datename(month,I.InventoryDate), ', ', datepart(year, I.InventoryDate)) as InventoryDate,
	I.Count
From vProducts P
	Join vInventories I 
		on P.ProductID = I.ProductID
Order by P.ProductName, I.InventoryDate, I.Count;
go
-- Step 2: Incorporate category name via join to vCategories table, change order by to category name, date
Select 
	C.CategoryName,
	P.ProductName, 
	concat(datename(month,I.InventoryDate), ', ', datepart(year, I.InventoryDate)) as InventoryDate,
	I.Count
From vProducts P
	Join vInventories I 
		on P.ProductID = I.ProductID
	Join vCategories C
		on C.CategoryID = P.CategoryID
Order by C.CategoryName, I.InventoryDate, I.Count;
go
--Step 3: drop product name, sum the count by category and inventory date
Select 
	C.CategoryName, 
	concat(datename(month,I.InventoryDate), ', ', datepart(year, I.InventoryDate)) as InventoryDate,
	sum(I.[Count]) as InventoryCountbyCategory
From vProducts P
	Join vInventories I 
		on P.ProductID = I.ProductID
	Join vCategories C
		on C.CategoryID = P.CategoryID
Group by C.CategoryName, InventoryDate
Order by C.CategoryName, I.InventoryDate;
go
*/
-- Step 4: wrap it in a view, including 'top; to make the order by work
Create -- Drop
View vCategoryInventories
As
	Select Top 1000000000
		C.CategoryName, 
		concat(datename(month,I.InventoryDate), ', ', datepart(year, I.InventoryDate)) as InventoryDate,
		sum(I.[Count]) as InventoryCountbyCategory
	From vProducts P
		Join vInventories I 
			on P.ProductID = I.ProductID
		Join vCategories C
			on C.CategoryID = P.CategoryID
	Group by C.CategoryName, InventoryDate
	Order by C.CategoryName, datepart(month, InventoryDate);
go
Select * From vCategoryInventories;
go

-- Question 6 (10% of pts): How can you CREATE ANOTHER VIEW called 
-- vProductInventoriesWithPreviouMonthCounts to show 
-- a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month
-- Count? Use a functions to set any null counts or 1996 counts to zero. Order the
-- results by the Product, Date, and Count. This new view must use your
-- vProductInventories view!
/*
-- Step 1: examine vProductInventories
Select * from vProductInventories
go
-- Step 2: implement lag to compare current month to previous month
Select 
	ProductName,
	InventoryDate,
	InventoryCount,
	PreviousMonthCount = Lag(InventoryCount,1,0) Over(partition by (ProductName) order by (InventoryDate))
From vProductInventories
*/
-- Step 3: wrap it in a view
Create -- Drop
View vProductInventoriesWithPreviousMonthCounts
As
	Select Top 100000000
		ProductName,
		InventoryDate,
		InventoryCount,
		PreviousMonthCount = Lag(InventoryCount,1,0) Over(partition by (ProductName) 
			order by (datepart(month, InventoryDate)))
	From vProductInventories
	Order by ProductName, datepart(month, InventoryDate), InventoryCount;
go

Select * From vProductInventoriesWithPreviousMonthCounts;
go

-- Question 7 (20% of pts): How can you CREATE one more VIEW 
-- called vProductInventoriesWithPreviousMonthCountsWithKPIs
-- to show a list of Product names, Inventory Dates, Inventory Count, the Previous Month 
-- Count and a KPI that displays an increased count as 1, 
-- the same count as 0, and a decreased count as -1? Order the results by the 
-- Product, Date, and Count!
/*
--Step 1: examine vProductInventoriesWithPreviousMonthCounts
Select * From vProductInventoriesWithPreviousMonthCounts;
go
-- Step 2: establish kpi
Select
	ProductName,
	InventoryDate,
	InventoryCount,
	PreviousMonthCount,
	CountvsPreviousCountwithKPI = 
		Case 
			When InventoryCount > PreviousMonthCount then '1'
			When InventoryCount = PreviousMonthCount then '0'
			When InventoryCount < PreviousMonthCount then '-1'
			Else 'check me!'
		End
From vProductInventoriesWithPreviousMonthCounts
go
*/
--Step 3: wrap in a view, use 'top' to retain order by 
Create -- Drop
View vProductInventoriesWithPreviousMonthCountsWithKPIs
As 
	Select Top 100000000
		ProductName,
		InventoryDate,
		InventoryCount,
		PreviousMonthCount,
		CountvsPreviousCountwithKPI = 
			Case 
				When InventoryCount > PreviousMonthCount then '1'
				When InventoryCount = PreviousMonthCount then '0'
				When InventoryCount < PreviousMonthCount then '-1'
				Else 'check me!'
			End
	From vProductInventoriesWithPreviousMonthCounts
	Order by ProductName, datepart(month, InventoryDate), InventoryCount;
go

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): How can you CREATE a User Defined Function (UDF) 
-- called fProductInventoriesWithPreviousMonthCountsWithKPIs
-- to show a list of Product names, Inventory Dates, Inventory Count, the Previous Month
-- Count and a KPI that displays an increased count as 1, the same count as 0, and a
-- decreased count as -1 AND the result can show only KPIs with a value of either 1, 0,
-- or -1? This new function must use you
-- ProductInventoriesWithPreviousMonthCountsWithKPIs view!
-- Include an Order By clause in the function using this code: 
-- Year(Cast(v1.InventoryDate as Date))
-- and note what effect it has on the results.
/*
--Step 1: outline select statement from ProductInventoriesWithPreviousMonthCountsWithKPIs
Select ProductName, 
	InventoryDate, 
	InventoryCount, 
	PreviousMonthCount
From vProductInventoriesWithPreviousMonthCountsWithKPIs
Where CountvsPreviousCountwithKPI = 0 --VARIABLE 1, 0, -1--
go

--Step 2: structure function to pass KPI variable
Create -- Drop
Function dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(@KPI int)
 Returns Table 
 AS 
   Return(
    Select ProductName, 
		InventoryDate, 
		InventoryCount, 
		PreviousMonthCount
	From vProductInventoriesWithPreviousMonthCountsWithKPIs
	Where CountvsPreviousCountwithKPI = @KPI
	);
go
*/
--Step 3: implement order by
Create -- Drop
Function dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(@KPI int)
 Returns Table 
 AS 
   Return(
    Select ProductName, 
		InventoryDate, 
		InventoryCount, 
		PreviousMonthCount
	From vProductInventoriesWithPreviousMonthCountsWithKPIs
	Where CountvsPreviousCountwithKPI = @KPI
	);
go

--Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
go

/***************************************************************************************/