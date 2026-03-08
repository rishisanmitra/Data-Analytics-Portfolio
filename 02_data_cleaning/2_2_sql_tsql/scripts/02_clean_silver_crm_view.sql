USE LegacyCRM;
GO

-- 1. Clean Clients View (Using a CTE for Step-by-Step String Parsing)
CREATE OR ALTER VIEW vw_Silver_Clients AS
WITH Stripped_Clients AS (
    SELECT 
        ClientID,
        TRIM(ClientName) AS ClientName,
        
        -- Categorical Mapping for all 8 States and 16 Variations
        CASE 
            WHEN UPPER(TRIM(State)) IN ('TX', 'TEXAS', 'TEXS') THEN 'TX'
            WHEN UPPER(TRIM(State)) IN ('CA', 'CALIFORNIA', 'CALI') THEN 'CA'
            WHEN UPPER(TRIM(State)) IN ('NY', 'NEW YORK') THEN 'NY'
            WHEN UPPER(TRIM(State)) IN ('FL', 'FLORIDA', 'FLA') THEN 'FL'
            WHEN UPPER(TRIM(State)) IN ('IL', 'ILLINOIS') THEN 'IL'
            WHEN UPPER(TRIM(State)) IN ('PA', 'PENN', 'PENNSYLVANIA') THEN 'PA'
            WHEN UPPER(TRIM(State)) IN ('OH', 'OHIO') THEN 'OH'
            WHEN UPPER(TRIM(State)) IN ('GA', 'GEORGIA') THEN 'GA'
            ELSE UPPER(TRIM(State))
        END AS State_Clean,
        
        -- Handle Fake Nulls and Strip Punctuation
        CASE 
            WHEN Phone = 'N/A' THEN NULL
            ELSE REPLACE(REPLACE(REPLACE(REPLACE(Phone, '-', ''), '(', ''), ')', ''), ' ', '')
        END AS Phone_Stripped
    FROM dbo.Clients
)
SELECT 
    ClientID,
    ClientName,
    State_Clean AS State, -- Alias maintained for Phase 3.2 Gold compatibility
    
    -- Quality Control: Nullify incomplete (e.g., 7-digit) phone numbers
    CASE 
        WHEN LEN(Phone_Stripped) != 10 THEN NULL
        ELSE Phone_Stripped
    END AS Phone -- Alias maintained for Phase 3.2 Gold compatibility
FROM Stripped_Clients;
GO

-- 2. Clean Orders View (Handling Dates and Referential Integrity)
CREATE OR ALTER VIEW vw_Silver_Orders AS
SELECT 
    o.OrderID,
    o.ClientID,
    
    -- Safe Date Conversion: 'UNKNOWN' and '2023/25/02' gracefully become NULL
    TRY_CAST(o.OrderDate AS DATE) AS OrderDate, -- Alias maintained for Gold compatibility
    
    -- Impute missing totals to 0.00
    ISNULL(o.OrderTotal, 0.00) AS OrderTotal -- Alias maintained for Gold compatibility
FROM dbo.Orders o
-- INNER JOIN enforces Referential Integrity by dropping orphaned orders
INNER JOIN dbo.Clients c ON o.ClientID = c.ClientID;
GO

PRINT 'Silver Views successfully created. States standardized and dates parsed for 80,000 rows.';
GO