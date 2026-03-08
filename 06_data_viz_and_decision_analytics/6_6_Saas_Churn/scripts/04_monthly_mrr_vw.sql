SELECT
    tenure AS month_on_platform,
    COUNT(customerID) AS customers_at_tenure,
    ROUND(SUM(MonthlyCharges), 2) AS mrr_at_tenure,
    ROUND(SUM(CASE WHEN Churn = true THEN MonthlyCharges ELSE 0 END), 2) AS mrr_churned_at_tenure,
    ROUND(SAFE_DIVIDE(
        SUM(CASE WHEN Churn = true THEN MonthlyCharges ELSE 0 END),
        SUM(MonthlyCharges)
    ), 4) AS mrr_churn_rate
FROM `f3be9159-0442-4451-8ca.SaaS_Analytics.telco_churn`
GROUP BY tenure
ORDER BY tenure;