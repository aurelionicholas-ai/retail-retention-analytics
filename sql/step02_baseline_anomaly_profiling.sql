-- Goal : Checking data anomalies including blank, negative values, and non-product stock codes.
SELECT 
   -- 1. Check missing customer and product identity
    COUNTIF(CustomerID IS NULL OR TRIM(CustomerID) = '') AS missing_customer_ids,
    ROUND(COUNTIF(CustomerID IS NULL OR TRIM(CustomerID) = '') * 100.0 / COUNT(*), 2) AS pct_missing_customer_ids,
    COUNTIF(Description IS NULL OR TRIM(Description) = '') AS missing_descriptions,
    
    -- 2. Detect numeric boundaries and extreme outliers
    MIN(Quantity) AS min_quantity,
    MAX(Quantity) AS max_quantity,
    MIN(Price) AS min_price,
    MAX(Price) AS max_price,
    
    -- 3. Detect order cancellations and non-sales transactions
    COUNTIF(STARTS_WITH(UPPER(Invoice), 'C')) AS cancellation_rows,
    COUNTIF(Quantity < 0 AND NOT STARTS_WITH(UPPER(Invoice), 'C')) AS negative_qty_non_cancellation,
    COUNTIF(Price <= 0) AS zero_or_negative_price,

    -- 4. Detect operational fees and non-merchandise stock codes
    COUNTIF(UPPER(TRIM(StockCode)) IN ('POST', 'D', 'M', 'BANK CHARGES', 'PADS', 'CRUK', 'DOT')) AS non_product_stock_codes
FROM `retention_case_study.raw_retail_all`;