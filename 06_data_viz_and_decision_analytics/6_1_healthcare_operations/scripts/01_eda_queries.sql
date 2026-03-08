-- QUERY 1: Calculate 30-day readmission rates by demographic groups

USE HealthcareDB;

WITH encounter_ordered AS (
    SELECT
        PATIENT,
        Id AS encounter_id,
        TRY_CAST([START] AS DATETIME2) AS encounter_start,
        ENCOUNTERCLASS,
        TRY_CAST(TOTAL_CLAIM_COST AS FLOAT) AS TOTAL_CLAIM_COST,
        REASONDESCRIPTION,
        LAG(TRY_CAST([START] AS DATETIME2)) OVER (
            PARTITION BY PATIENT
            ORDER BY TRY_CAST([START] AS DATETIME2)
        ) AS prev_encounter_start
    FROM dbo.encounters
),
readmission_flagged AS (
    SELECT
        *,
        DATEDIFF(DAY, prev_encounter_start, encounter_start) AS days_since_last_visit,
        CASE
            WHEN DATEDIFF(DAY, prev_encounter_start, encounter_start) <= 30
            THEN 1 ELSE 0
        END AS is_30day_readmission
    FROM encounter_ordered
    WHERE prev_encounter_start IS NOT NULL
)
SELECT
    ENCOUNTERCLASS,
    COUNT(*) AS total_encounters,
    SUM(is_30day_readmission) AS readmissions,
    ROUND(CAST(SUM(is_30day_readmission) AS FLOAT) / COUNT(*), 4) AS readmission_rate,
    ROUND(AVG(TOTAL_CLAIM_COST), 2) AS avg_claim_cost,
    ROUND(SUM(CASE WHEN is_30day_readmission = 1 THEN TOTAL_CLAIM_COST ELSE 0 END), 2) AS readmission_financial_liability
FROM readmission_flagged
GROUP BY ENCOUNTERCLASS
ORDER BY readmission_financial_liability DESC;

-- QUERY 2: Analyze 30-day readmission rates and associated costs by patient demographics

USE HealthcareDB;

WITH encounter_ordered AS (
    SELECT
        PATIENT,
        Id AS encounter_id,
        TRY_CAST([START] AS DATETIME2) AS encounter_start,
        ENCOUNTERCLASS,
        TRY_CAST(TOTAL_CLAIM_COST AS FLOAT) AS TOTAL_CLAIM_COST,
        LAG(TRY_CAST([START] AS DATETIME2)) OVER (
            PARTITION BY PATIENT
            ORDER BY TRY_CAST([START] AS DATETIME2)
        ) AS prev_encounter_start
    FROM dbo.encounters
),
readmission_flagged AS (
    SELECT
        *,
        CASE
            WHEN DATEDIFF(DAY, prev_encounter_start, encounter_start) <= 30
            THEN 1 ELSE 0
        END AS is_30day_readmission
    FROM encounter_ordered
    WHERE prev_encounter_start IS NOT NULL
)
SELECT
    p.GENDER,
    p.RACE,
    CASE 
        WHEN DATEDIFF(YEAR, TRY_CAST(p.BIRTHDATE AS DATE), GETDATE()) < 18 THEN '0-17'
        WHEN DATEDIFF(YEAR, TRY_CAST(p.BIRTHDATE AS DATE), GETDATE()) BETWEEN 18 AND 35 THEN '18-35'
        WHEN DATEDIFF(YEAR, TRY_CAST(p.BIRTHDATE AS DATE), GETDATE()) BETWEEN 36 AND 55 THEN '36-55'
        WHEN DATEDIFF(YEAR, TRY_CAST(p.BIRTHDATE AS DATE), GETDATE()) BETWEEN 56 AND 75 THEN '56-75'
        ELSE '75+' 
    END AS age_band,
    COUNT(DISTINCT e.PATIENT) AS unique_patients,
    SUM(rf.is_30day_readmission) AS total_readmissions,
    ROUND(SUM(CASE WHEN rf.is_30day_readmission = 1 THEN e.TOTAL_CLAIM_COST ELSE 0 END), 2) AS readmission_liability
FROM readmission_flagged rf
JOIN dbo.encounters e ON rf.encounter_id = e.Id
JOIN dbo.patients p ON e.PATIENT = p.Id
GROUP BY
    p.GENDER,
    p.RACE,
    CASE 
        WHEN DATEDIFF(YEAR, TRY_CAST(p.BIRTHDATE AS DATE), GETDATE()) < 18 THEN '0-17'
        WHEN DATEDIFF(YEAR, TRY_CAST(p.BIRTHDATE AS DATE), GETDATE()) BETWEEN 18 AND 35 THEN '18-35'
        WHEN DATEDIFF(YEAR, TRY_CAST(p.BIRTHDATE AS DATE), GETDATE()) BETWEEN 36 AND 55 THEN '36-55'
        WHEN DATEDIFF(YEAR, TRY_CAST(p.BIRTHDATE AS DATE), GETDATE()) BETWEEN 56 AND 75 THEN '56-75'
        ELSE '75+' 
    END
ORDER BY readmission_liability DESC;

-- QUERY 3: Identify the top 5 primary diagnoses leading to 30-day readmissions

USE HealthcareDB;

WITH encounter_ordered AS (
    SELECT
        e.PATIENT,
        e.Id AS encounter_id,
        TRY_CAST(e.[START] AS DATETIME2) AS encounter_start,
        e.ENCOUNTERCLASS,
        TRY_CAST(e.TOTAL_CLAIM_COST AS FLOAT) AS TOTAL_CLAIM_COST,
        e.REASONDESCRIPTION,
        LAG(TRY_CAST(e.[START] AS DATETIME2)) OVER (
            PARTITION BY e.PATIENT
            ORDER BY TRY_CAST(e.[START] AS DATETIME2)
        ) AS prev_encounter_start
    FROM dbo.encounters e
),
readmission_flagged AS (
    SELECT
        rf.*,
        p.GENDER,
        p.RACE,
        CASE 
            WHEN DATEDIFF(YEAR, TRY_CAST(p.BIRTHDATE AS DATE), GETDATE()) < 18 THEN '0-17'
            WHEN DATEDIFF(YEAR, TRY_CAST(p.BIRTHDATE AS DATE), GETDATE()) BETWEEN 18 AND 35 THEN '18-35'
            WHEN DATEDIFF(YEAR, TRY_CAST(p.BIRTHDATE AS DATE), GETDATE()) BETWEEN 36 AND 55 THEN '36-55'
            WHEN DATEDIFF(YEAR, TRY_CAST(p.BIRTHDATE AS DATE), GETDATE()) BETWEEN 56 AND 75 THEN '56-75'
            ELSE '75+' 
        END AS age_band,
        CASE
            WHEN DATEDIFF(DAY, prev_encounter_start, encounter_start) <= 30
            THEN 1 ELSE 0
        END AS is_30day_readmission
    FROM encounter_ordered rf
    JOIN dbo.patients p ON rf.PATIENT = p.Id
    WHERE rf.prev_encounter_start IS NOT NULL
)
SELECT
    REASONDESCRIPTION AS primary_diagnosis,
    COUNT(*) AS readmission_count,
    ROUND(AVG(TOTAL_CLAIM_COST), 2) AS avg_cost,
    ROUND(SUM(TOTAL_CLAIM_COST), 2) AS total_financial_exposure
FROM readmission_flagged
WHERE is_30day_readmission = 1 
  AND REASONDESCRIPTION IS NOT NULL
  AND GENDER = 'F'
  AND age_band IN ('18-35', '36-55')
GROUP BY REASONDESCRIPTION
ORDER BY total_financial_exposure DESC;