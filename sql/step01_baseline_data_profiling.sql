--Goal:Profile raw data to check total volume, time range, missing values, and data outlier

SELECT 
    -- 1. High-level dataset volume and date boundary
    COUNT(*) AS total_rows,
    MIN(InvoiceDate) AS earliest_date,
    MAX(InvoiceDate) AS latest_date,
    -- 2. Make an Alias for business entities count
    COUNT(DISTINCT Invoice) AS distinct_invoices,
    COUNT(DISTINCT StockCode) AS distinct_products,
    COUNT(DISTINCT CustomerID) AS distinct_customers,
    COUNT(DISTINCT Country) AS distinct_countries,
    -- 3. Missing values check
    COUNTIF(CustomerID IS NULL) AS missing_customer_ids,
    ROUND(COUNTIF(CustomerID IS NULL) * 100.0 / COUNT(*), 2) AS pct_missing_customer_ids,
    COUNTIF(Description IS NULL) AS missing_descriptions,
   -- 4. Value boundaries check
    MIN(Quantity) AS min_quantity,
    MAX(Quantity) AS max_quantity,
    MIN(Price) AS min_price,
    MAX(Price) AS max_price,
   -- 5. Anomaly transaction count
    COUNTIF(STARTS_WITH(UPPER(Invoice), 'C')) AS cancellation_rows,
    COUNTIF(Quantity < 0 AND NOT STARTS_WITH(UPPER(Invoice), 'C')) AS negative_qty_non_cancellation,
    COUNTIF(Price <= 0) AS zero_or_negative_price
FROM `retention_case_study.raw_retail_all`;