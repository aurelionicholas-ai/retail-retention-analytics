-- 1. Calculate order count and spend per customer
WITH customer_orders AS (
  SELECT 
    CustomerID,
    COUNT(DISTINCT Invoice) AS order_count,
    ROUND(SUM(LineTotal), 2) AS total_spend
  FROM `retention_case_study.clean_retail_transactions`
  GROUP BY CustomerID
),

-- 2. Classify customer order frequency buckets
customer_buckets AS (
  SELECT 
    CustomerID,
    order_count,
    total_spend,
    CASE 
      WHEN order_count = 1 THEN '1 Order (One-Time)'
      WHEN order_count = 2 THEN '2 Orders'
      WHEN order_count BETWEEN 3 AND 5 THEN '3-5 Orders'
      WHEN order_count BETWEEN 6 AND 10 THEN '6-10 Orders'
      ELSE '11+ Orders (Power Buyers)'
    END AS order_frequency_bucket,
    CASE 
      WHEN order_count = 1 THEN 1
      WHEN order_count = 2 THEN 2
      WHEN order_count BETWEEN 3 AND 5 THEN 3
      WHEN order_count BETWEEN 6 AND 10 THEN 4
      ELSE 5
    END AS sort_order
  FROM customer_orders
)

-- 3. Aggregate customer counts, revenue, and percentages
SELECT 
  order_frequency_bucket,
  COUNT(CustomerID) AS total_customers,
  ROUND(COUNT(CustomerID) * 100.0 / SUM(COUNT(CustomerID)) OVER (), 2) AS pct_customers,
  ROUND(SUM(total_spend), 2) AS total_revenue,
  ROUND(SUM(total_spend) * 100.0 / SUM(SUM(total_spend)) OVER (), 2) AS pct_revenue,
  ROUND(AVG(total_spend), 2) AS avg_revenue_per_customer
FROM customer_buckets
GROUP BY order_frequency_bucket, sort_order
ORDER BY sort_order;