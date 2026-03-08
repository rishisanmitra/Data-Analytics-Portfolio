/*
===============================================================================
02_sargability.sql
===============================================================================
Purpose:
    - To demonstrate how using functions on columns destroys index usage.
    - To rewrite a non-SARGable query into a SARGable query.
===============================================================================
*/

USE StackOverflow2010;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- 1. Create the Index
-- We are building an index on the CreationDate column so our queries SHOULD be fast.
CREATE NONCLUSTERED INDEX IX_Users_CreationDate ON dbo.Users(CreationDate);
GO

-- ============================================================================
-- SCENARIO A: The Non-SARGable Query (The Bad Way)
-- ============================================================================
-- By wrapping CreationDate in the YEAR() function, we blind the optimizer.
-- It is forced to evaluate the function on every single row before filtering.

SELECT 
    Id, 
    DisplayName, 
    CreationDate
FROM dbo.Users
WHERE YEAR(CreationDate) = 2009;

-- ============================================================================
-- SCENARIO B: The SARGable Query (The Good Way)
-- ============================================================================
-- We leave the column completely alone and manipulate the parameters instead.
-- This allows the engine to do a highly efficient "Index Seek".

SELECT 
    Id, 
    DisplayName, 
    CreationDate
FROM dbo.Users
WHERE CreationDate >= '2009-01-01' AND CreationDate < '2010-01-01';