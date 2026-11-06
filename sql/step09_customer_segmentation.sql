-- 1. Get recency, total orders, and total spend per customer
WITH customer_summary AS (
  SELECT 
    CustomerID,
    DATE_DIFF(DATE '2011-12-09', MAX(InvoiceDate), DAY) AS days_since_last_order,
    COUNT(DISTINCT Invoice) AS total_orders,
    ROUND(SUM(LineTotal), 2) AS total_spend
  FROM `retention_case_study.clean_retail_transactions`
  GROUP BY CustomerID
)

-- 2. Assign clear business labels using simple CASE WHEN rules
SELECT 
  CustomerID,
  days_since_last_order,
  total_orders,
  total_spend,
  CASE 
    -- Active customers who spent a lot
    WHEN days_since_last_order <= 90 AND total_spend >= 2000 THEN 'VIP / High Value'
    
    -- Active customers with regular spend
    WHEN days_since_last_order <= 90 AND total_spend < 2000 THEN 'Active Regular'
    
    -- Haven't ordered in 3 to 6 months
    WHEN days_since_last_order BETWEEN 91 AND 180 THEN 'At Risk (Slipping)'
    
    -- Haven't ordered in over 6 months
    ELSE 'Churned / Inactive'
  END AS customer_segment

FROM customer_summary
ORDER BY total_spend DESC
LIMIT 15;