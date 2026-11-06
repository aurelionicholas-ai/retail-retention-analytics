WITH first_order AS (
  SELECT 
    CustomerID,
    DATE_TRUNC(MIN(InvoiceDate), MONTH) AS cohort_month
  FROM `retention_case_study.clean_retail_transactions`
  GROUP BY CustomerID
),

orders_with_cohort AS (
  SELECT 
    t.CustomerID,
    f.cohort_month,
    DATE_DIFF(DATE_TRUNC(t.InvoiceDate, MONTH), f.cohort_month, MONTH) AS month_number
  FROM `retention_case_study.clean_retail_transactions` t
  JOIN first_order f ON t.CustomerID = f.CustomerID
)

SELECT 
  cohort_month,
  month_number,
  COUNT(DISTINCT CustomerID) AS active_customers,

  MAX(COUNT(DISTINCT CustomerID)) OVER (PARTITION BY cohort_month) AS cohort_size,
  
  ROUND(
    COUNT(DISTINCT CustomerID) * 100.0 / 
    MAX(COUNT(DISTINCT CustomerID)) OVER (PARTITION BY cohort_month), 
    2
  ) AS retention_rate

FROM orders_with_cohort
GROUP BY cohort_month, month_number
ORDER BY cohort_month, month_number;