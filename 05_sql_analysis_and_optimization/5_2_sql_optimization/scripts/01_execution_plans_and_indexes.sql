/*
===============================================================================
01_execution_plans_and_indexes.sql
===============================================================================
Purpose:
    - To demonstrate the performance impact of a Clustered Index Scan (Table Scan).
    - To measure logical reads and execution time before and after indexing.
    - To prove how a Non-Clustered Index resolves read-heavy bottlenecks.
===============================================================================
*/

USE StackOverflow2010;
GO

-- Turn on performance metrics
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- ============================================================================
-- SCENARIO A: The Unoptimized Query (The Table Scan)
-- ============================================================================
-- The database engine has to read every single row in the Users table to find 'London'.

SELECT 
    Id, 
    DisplayName, 
    Location, 
    Reputation
FROM dbo.Users
WHERE Location = 'London';

-- ============================================================================
-- THE FIX: Creating a Non-Clustered Index
-- ============================================================================
-- We are building a "lookup directory" specifically for the Location column.

-- Uncomment the line below and run it to create the index:
-- CREATE NONCLUSTERED INDEX IX_Users_Location ON dbo.Users(Location);

-- ============================================================================
-- SCENARIO B: The Optimized Query (The Index Seek)
-- ============================================================================
-- Run the exact same query again. The engine will now use the new index.

/*
SELECT 
    Id, 
    DisplayName, 
    Location, 
    Reputation
FROM dbo.Users
WHERE Location = 'London';
*/