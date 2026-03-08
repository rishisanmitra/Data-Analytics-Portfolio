USE LegacyCRM;
GO

-- 1. Profile Clients: Identify State Variations and Typos
SELECT 
    State, 
    COUNT(*) AS State_Count
FROM dbo.Clients
GROUP BY State
ORDER BY State_Count DESC;

-- 2. Profile Clients: Identify Phone Formatting and Fake Nulls
SELECT 
    Phone, 
    COUNT(*) AS Phone_Count
FROM dbo.Clients
GROUP BY Phone;

-- 3. Profile Orders: Find Orphaned Records (Referential Integrity Check)
-- This counts orders assigned to ClientIDs that do not exist in the Clients table.
SELECT 
    COUNT(*) AS Orphaned_Orders
FROM dbo.Orders o
LEFT JOIN dbo.Clients c ON o.ClientID = c.ClientID
WHERE c.ClientID IS NULL;

-- 4. Profile Orders: Identify Invalid Dates
-- TRY_CAST returns NULL if the string cannot be converted to a valid date.
SELECT 
    OrderDate, 
    COUNT(*) as Occurrence_Count
FROM dbo.Orders
WHERE TRY_CAST(OrderDate AS DATE) IS NULL
GROUP BY OrderDate;

-- 5. Profile Orders: Count Missing Totals
SELECT 
    COUNT(*) AS Missing_Totals
FROM dbo.Orders
WHERE OrderTotal IS NULL;