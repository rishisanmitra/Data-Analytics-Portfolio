SELECT
    Contract,
    PaymentMethod,
    COUNT(customerID) AS total_customers,
    COUNTIF(Churn = true) AS churned,
    ROUND(COUNTIF(Churn = true) / COUNT(customerID), 4) AS churn_rate,
    ROUND(SUM(CASE WHEN Churn = true THEN MonthlyCharges ELSE 0 END), 2) AS monthly_revenue_lost,
    ROUND(AVG(SAFE_CAST(TotalCharges AS FLOAT64)), 2) AS avg_customer_ltv
FROM `f3be9159-0442-4451-8ca.SaaS_Analytics.telco_churn`
GROUP BY Contract, PaymentMethod
ORDER BY churn_rate DESC;