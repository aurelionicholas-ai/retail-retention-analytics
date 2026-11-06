-- 1. Calculate total spend for each customer
WITH customer_spend AS (
  SELECT 
    CustomerID,
    ROUND(SUM(LineTotal), 2) AS total_spend
  FROM `retention_case_study.clean_retail_transactions`
  GROUP BY CustomerID
),

-- 2. Split customers into 10 equal groups (Decile 1 = highest spenders, Decile 10 = lowest)
customer_deciles AS (
  SELECT 
    CustomerID,
    total_spend,
    NTILE(10) OVER (ORDER BY total_spend DESC) AS decile
  FROM customer_spend
)

-- 3. Show revenue and cumulative percentage for each group
SELECT 
  decile,
  COUNT(CustomerID) AS total_customers,
  ROUND(SUM(total_spend), 2) AS group_revenue,
  
  -- Percentage of total revenue from this group
  ROUND(SUM(total_spend) * 100.0 / SUM(SUM(total_spend)) OVER (), 2) AS pct_revenue,
  
  -- Running total percentage (to see if top 20% makes 80% of revenue)
  ROUND(
    SUM(SUM(total_spend)) OVER (ORDER BY decile) * 100.0 / SUM(SUM(total_spend)) OVER (),
    2
  ) AS cumulative_pct_revenue

FROM customer_deciles
GROUP BY decile
ORDER BY decile;