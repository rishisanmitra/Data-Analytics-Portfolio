/*
===============================================================================
04_wildcard_searches.sql
===============================================================================
Purpose:
    - To demonstrate how leading wildcards ('%text') destroy index usage.
    - To show how trailing wildcards ('text%') allow for efficient Index Seeks.
===============================================================================
*/

USE StackOverflow2010;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- 1. Create an index on the DisplayName column
CREATE NONCLUSTERED INDEX IX_Users_DisplayName ON dbo.Users(DisplayName);
GO

-- ============================================================================
-- SCENARIO A: The Leading Wildcard (The Bad Way)
-- ============================================================================
-- Because the string starts with a '%', the database engine cannot use the 
-- alphabetical sorting of the index. It is forced to scan everything.

SELECT 
    Id, 
    DisplayName
FROM dbo.Users
WHERE DisplayName LIKE '%Jon%';

-- ============================================================================
-- SCENARIO B: The Trailing Wildcard (The Good Way)
-- ============================================================================
-- Because we provide the starting characters, the engine can instantly jump 
-- to the 'J' section of the index and stop reading once it hits 'Joo'.

SELECT 
    Id, 
    DisplayName
FROM dbo.Users
WHERE DisplayName LIKE 'Jon%';