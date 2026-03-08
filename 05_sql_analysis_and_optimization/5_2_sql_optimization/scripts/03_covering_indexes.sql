/*
===============================================================================
03_covering_indexes.sql
===============================================================================
Purpose:
    - To demonstrate the "Tipping Point" where SQL Server ignores an index due to Key Lookups.
    - To solve the issue using a Covering Index with the INCLUDE clause.
===============================================================================
*/

USE StackOverflow2010;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- 1. Drop the old index that wasn't working for our specific query
DROP INDEX IX_Users_CreationDate ON dbo.Users;
GO

-- 2. Create the new COVERING Index
-- We index the date for searching, but we "INCLUDE" the DisplayName so the engine doesn't have to look it up.
CREATE NONCLUSTERED INDEX IX_Users_CreationDate_Covering 
ON dbo.Users(CreationDate)
INCLUDE (DisplayName);
GO

-- ============================================================================
-- SCENARIO: The SARGable Query with a Covering Index
-- ============================================================================
-- Now that the index "covers" all columns in our SELECT list, the engine will use it.

SELECT 
    Id, 
    DisplayName, 
    CreationDate
FROM dbo.Users
WHERE CreationDate >= '2009-01-01' AND CreationDate < '2010-01-01';