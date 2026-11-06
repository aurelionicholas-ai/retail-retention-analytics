-- 1. Get recency, orders, and spend per customer
WITH customer_summary AS (
  SELECT 
    CustomerID,
    DATE_DIFF(DATE '2011-12-09', MAX(InvoiceDate), DAY) AS days_since_last_order,
    COUNT(DISTINCT Invoice) AS total_orders,
    ROUND(SUM(LineTotal), 2) AS total_spend
  FROM `retention_case_study.clean_retail_transactions`
  GROUP BY CustomerID
),

-- 2. Categorize every customer into a clear business segment
classified_customers AS (
  SELECT 
    CustomerID,
    total_spend,
    CASE 
      WHEN days_since_last_order <= 90 AND total_spend >= 2000 THEN '1. VIP / High Value'
      WHEN days_since_last_order <= 90 AND total_spend < 2000 THEN '2. Active Regular'
      WHEN days_since_last_order BETWEEN 91 AND 180 THEN '3. At Risk (Slipping)'
      ELSE '4. Churned / Inactive'
    END AS customer_segment
  FROM customer_summary
)

-- 3. Aggregate totals and percentages per segment
SELECT 
  customer_segment,
  COUNT(CustomerID) AS total_customers,
  ROUND(COUNT(CustomerID) * 100.0 / SUM(COUNT(CustomerID)) OVER (), 2) AS pct_customers,
  ROUND(SUM(total_spend), 2) AS total_revenue,
  ROUND(SUM(total_spend) * 100.0 / SUM(SUM(total_spend)) OVER (), 2) AS pct_revenue,
  ROUND(AVG(total_spend), 2) AS avg_spend_per_customer
FROM classified_customers
GROUP BY customer_segment
ORDER BY customer_segment ASC;