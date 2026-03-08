USE master;
GO
IF DB_ID('LegacyCRM') IS NOT NULL
BEGIN
    ALTER DATABASE LegacyCRM SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE LegacyCRM;
END
GO

CREATE DATABASE LegacyCRM;
GO
USE LegacyCRM;
GO

-- Create Tables
CREATE TABLE Clients (
    ClientID INT PRIMARY KEY,
    ClientName VARCHAR(100),
    State VARCHAR(50),
    Phone VARCHAR(50)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1), 
    ClientID INT,
    OrderDate VARCHAR(50), 
    OrderTotal DECIMAL(10,2)
);

-- Insert Base Clients
INSERT INTO Clients (ClientID, ClientName, State, Phone) VALUES
(101, 'Acme Corp', 'TX', '555-1234'),
(102, 'Globex', 'Texas', '(555) 567-8901'),
(103, 'Initech', 'Texs', '5559992222'),
(104, 'Umbrella Corp', 'cali', NULL),
(105, 'Stark Ind', 'California', 'N/A');

-- Generate 95 Additional Clients across 8 states with messy variations
DECLARE @c INT = 106;
DECLARE @RandState INT;
DECLARE @StateStr VARCHAR(50);

WHILE @c <= 200
BEGIN
    SET @RandState = FLOOR(RAND() * 16); -- 16 variations for 8 states
    
    SET @StateStr = CASE @RandState
        WHEN 0 THEN 'TX' WHEN 1 THEN 'Texas' 
        WHEN 2 THEN 'CA' WHEN 3 THEN 'Cali' 
        WHEN 4 THEN 'NY' WHEN 5 THEN 'New York' WHEN 6 THEN 'ny'
        WHEN 7 THEN 'FL' WHEN 8 THEN 'Florida' WHEN 9 THEN 'Fla'
        WHEN 10 THEN 'IL' WHEN 11 THEN 'Illinois'
        WHEN 12 THEN 'PA' WHEN 13 THEN 'Penn'
        WHEN 14 THEN 'OH' WHEN 15 THEN 'GA'
        ELSE 'Unknown'
    END;

    INSERT INTO Clients (ClientID, ClientName, State, Phone)
    VALUES (@c, 'Client_Corp_' + CAST(@c AS VARCHAR), @StateStr, '555-01' + RIGHT('00' + CAST(@c AS VARCHAR), 2));
    
    SET @c = @c + 1;
END;

-- Generate 80,000 Orders
DECLARE @i INT = 1;
DECLARE @RandomClient INT;
DECLARE @RandomTotal DECIMAL(10,2);
DECLARE @RandomDate VARCHAR(50);
DECLARE @MessyFlag INT;
DECLARE @RandMonth INT;
DECLARE @RandDay INT;

WHILE @i <= 80000
BEGIN
    -- Clients 100-210 (201-210 will be orphans)
    SET @RandomClient = FLOOR(RAND() * 111) + 100;
    SET @RandomTotal = ROUND(RAND() * 5000, 2);
    SET @MessyFlag = FLOOR(RAND() * 100); 
    
    IF @MessyFlag < 2 SET @RandomDate = NULL;                    
    ELSE IF @MessyFlag < 4 SET @RandomDate = 'UNKNOWN';          
    ELSE IF @MessyFlag < 6 SET @RandomDate = '2023/25/02';       
    ELSE 
    BEGIN
        SET @RandMonth = FLOOR(RAND() * 12) + 1;
        SET @RandDay = FLOOR(RAND() * 28) + 1;
        SET @RandomDate = '2023-' + RIGHT('0' + CAST(@RandMonth AS VARCHAR), 2) + '-' + RIGHT('0' + CAST(@RandDay AS VARCHAR), 2); 
    END
    
    IF FLOOR(RAND() * 20) = 0 SET @RandomTotal = NULL;

    INSERT INTO Orders (ClientID, OrderDate, OrderTotal)
    VALUES (@RandomClient, @RandomDate, @RandomTotal);
    
    SET @i = @i + 1;
END;
GO