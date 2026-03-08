SELECT
    InternetService,
    PhoneService,
    OnlineSecurity,
    TechSupport,
    COUNT(customerID) AS total_customers,
    COUNTIF(Churn = true) AS churned,
    ROUND(COUNTIF(Churn = true) / COUNT(customerID), 4) AS churn_rate,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charge,
    ROUND(AVG(SAFE_CAST(TotalCharges AS FLOAT64)), 2) AS avg_ltv
FROM `f3be9159-0442-4451-8ca.SaaS_Analytics.telco_churn`
GROUP BY InternetService, PhoneService, OnlineSecurity, TechSupport
ORDER BY churn_rate DESC;