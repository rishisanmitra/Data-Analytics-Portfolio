WITH tenure_buckets AS (
    SELECT
        customerID,
        Churn,
        tenure,
        MonthlyCharges,
        TotalCharges,
        Contract,
        CASE
            WHEN tenure BETWEEN 0  AND 12  THEN '0-12 Months'
            WHEN tenure BETWEEN 13 AND 24  THEN '13-24 Months'
            WHEN tenure BETWEEN 25 AND 48  THEN '25-48 Months'
            ELSE '48+ Months'
        END AS tenure_cohort
    FROM `f3be9159-0442-4451-8ca.SaaS_Analytics.telco_churn`
)
SELECT
    tenure_cohort,
    COUNT(customerID) AS total_customers,
    COUNTIF(Churn = true) AS churned,
    ROUND(COUNTIF(Churn = true) / COUNT(customerID), 4) AS churn_rate,
    ROUND(AVG(MonthlyCharges), 2) AS avg_mrr,
    ROUND(SUM(CASE WHEN Churn = true THEN MonthlyCharges ELSE 0 END), 2) AS mrr_at_risk
FROM tenure_buckets
GROUP BY tenure_cohort;