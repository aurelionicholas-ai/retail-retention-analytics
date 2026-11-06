-- Goal: Prove full reconciliation between raw and clean data by categorizing all rows and revenue impact.

-- 1. Classify every raw record into logical business and exclusion buckets
WITH classified_raw AS (
  SELECT 
    Invoice,
    Quantity,
    Price,
    -- Compute line item value for monetary reconciliation
    ROUND(Quantity * Price, 2) AS LineTotal,
    CustomerID,
    StockCode,
    CASE 
      --Valid transactions that match the clean dataset criteria
      WHEN (CustomerID IS NOT NULL AND TRIM(CustomerID) != '')
       AND Quantity > 0 
       AND Price > 0 
       AND NOT STARTS_WITH(UPPER(Invoice), 'C')
       AND UPPER(TRIM(StockCode)) NOT IN ('POST', 'D', 'M', 'BANK CHARGES', 'PADS', 'CRUK', 'DOT')
      THEN '1. Clean Analytical Transactions'
      
      -- Unidentified customers
      WHEN (CustomerID IS NULL OR TRIM(CustomerID) = '')
       AND Quantity > 0 
       AND Price > 0
       AND NOT STARTS_WITH(UPPER(Invoice), 'C')
      THEN '2. Excluded: Guest Purchases (No Customer ID)'
      
      -- Formal order cancellations and customer returns
      WHEN STARTS_WITH(UPPER(Invoice), 'C')
      THEN '3. Excluded: Cancellations and Returns'
      
      -- Warehouse adjustments and damaged stock write-offs
      WHEN Quantity < 0 AND NOT STARTS_WITH(UPPER(Invoice), 'C')
      THEN '4. Excluded: Inventory Adjustments / Damaged Goods'
      
      -- Operational service charges
      WHEN UPPER(TRIM(StockCode)) IN ('POST', 'D', 'M', 'BANK CHARGES', 'PADS', 'CRUK', 'DOT')
      THEN '5. Excluded: Non-Product / Operational Fees'
      
      -- Zero or negative price anomalies
      WHEN Price <= 0
      THEN '6. Excluded: Zero or Negative Price Adjustments'
      
      ELSE '7. Excluded: Other Edge Cases'
    END AS transaction_category
  FROM `retention_case_study.raw_retail_all`
)
-- 2. Aggregate row count, share percentage, and total monetary value (£) per category
SELECT 
    transaction_category,
    COUNT(*) AS row_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS row_percentage,
    ROUND(SUM(LineTotal), 2) AS total_monetary_value
FROM classified_raw
GROUP BY transaction_category
ORDER BY transaction_category;