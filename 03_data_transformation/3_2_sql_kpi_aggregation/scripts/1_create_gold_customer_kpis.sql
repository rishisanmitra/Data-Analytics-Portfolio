USE LegacyCRM
GO

CREATE OR ALTER VIEW vw_Gold_Customer_KPIs AS
WITH CustomerBase AS (
    -- Step 1: Aggregate Transactional Data to the Customer Level
    SELECT 
        c.ClientID,
        c.ClientName,
        c.State,
        COUNT(o.OrderID) AS Total_Orders,
        SUM(o.OrderTotal_Clean) AS Total_Spend,
        MAX(o.OrderDate_Clean) AS Last_Order_Date
    FROM 
        vw_Silver_Clients c
    LEFT JOIN 
        vw_Silver_Orders o ON c.ClientID = o.ClientID
    GROUP BY 
        c.ClientID, 
        c.ClientName, 
        c.State
),
RFM_Calculation AS (
    -- Step 2: Calculate RFM scores using NTILE Window Function
    -- NTILE(4) divides customers into quartiles (1 = Lowest, 4 = Highest)
    SELECT 
        ClientID,
        ClientName,
        State,
        Total_Orders,
        Total_Spend,
        Last_Order_Date,
        
        -- Recency: Ordering by date ASC means older dates get 1, newest dates get 4
        NTILE(4) OVER (ORDER BY Last_Order_Date ASC) AS RecencyScore,
        
        -- Frequency: Higher order count gets a 4
        NTILE(4) OVER (ORDER BY Total_Orders ASC) AS FrequencyScore,
        
        -- Monetary: Higher spend gets a 4
        NTILE(4) OVER (ORDER BY Total_Spend ASC) AS MonetaryScore
    FROM 
        CustomerBase
    WHERE 
        Total_Orders > 0 -- Exclude leads who have never made a purchase
)

-- Step 3: Final Output with Concatenated Score and Segmentation Logic
SELECT 
    ClientID,
    ClientName,
    State,
    Total_Orders,
    Total_Spend,
    Last_Order_Date,
    RecencyScore,
    FrequencyScore,
    MonetaryScore,
    
    -- Create a unified 3-digit score (e.g., '444' is the best customer)
    CAST(RecencyScore AS VARCHAR(1)) + 
    CAST(FrequencyScore AS VARCHAR(1)) + 
    CAST(MonetaryScore AS VARCHAR(1)) AS RFM_Score,
    
    -- Apply Business Logic to create strategic Marketing Tiers
    CASE 
        WHEN RecencyScore = 4 AND FrequencyScore = 4 AND MonetaryScore = 4 THEN '1. VIP / Champion'
        WHEN RecencyScore >= 3 AND FrequencyScore >= 3 THEN '2. Loyal Customer'
        WHEN RecencyScore <= 2 AND FrequencyScore >= 3 AND MonetaryScore >= 3 THEN '3. At Risk (High Value)'
        WHEN RecencyScore <= 2 AND FrequencyScore <= 2 THEN '4. Churned / Inactive'
        ELSE '5. Standard Customer'
    END AS Customer_Segment
FROM 
    RFM_Calculation;
GO