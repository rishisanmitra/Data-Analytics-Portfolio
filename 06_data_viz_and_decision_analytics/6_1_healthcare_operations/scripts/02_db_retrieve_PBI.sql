USE HealthcareDB;
GO

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
        *,
        DATEDIFF(DAY, prev_encounter_start, encounter_start) AS days_since_last_visit,
        CASE 
            WHEN DATEDIFF(DAY, prev_encounter_start, encounter_start) <= 30 
            THEN 1 ELSE 0 
        END AS is_30day_readmission
    FROM encounter_ordered
)
SELECT 
    rf.encounter_id,
    rf.encounter_start,
    rf.ENCOUNTERCLASS,
    rf.TOTAL_CLAIM_COST,
    rf.REASONDESCRIPTION,
    rf.is_30day_readmission,
    rf.days_since_last_visit,
    p.GENDER,
    p.RACE,
    DATEDIFF(YEAR, TRY_CAST(p.BIRTHDATE AS DATE), GETDATE()) AS Patient_Age
FROM readmission_flagged rf
JOIN dbo.patients p ON rf.PATIENT = p.Id
WHERE rf.REASONDESCRIPTION IS NOT NULL;