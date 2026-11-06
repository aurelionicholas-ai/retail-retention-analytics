--Build the clean analytics table by standardizing dates, calculating row revenue, and removing commercial noise.

-- 1. Create or overwrite the clean production table for retention and cohort analysis
CREATE OR REPLACE TABLE `retention_case_study.clean_retail_transactions` AS
SELECT 
    Invoice,
    StockCode,
    -- Trim whitespace
    TRIM(Description) AS Description,
    Quantity,
    -- Change timestamp and date types
    PARSE_TIMESTAMP('%d/%m/%Y %H.%M', InvoiceDate) AS InvoiceTimestamp,
    DATE(PARSE_TIMESTAMP('%d/%m/%Y %H.%M', InvoiceDate)) AS InvoiceDate,
    Price,
    -- Compute monetary value to 2 decimal places
    ROUND(Quantity * Price, 2) AS LineTotal,
    -- Trim customer ID to eliminate invisible leading/trailing whitespaces
    TRIM(CustomerID) AS CustomerID,
    Country
FROM `retention_case_study.raw_retail_all`
WHERE 
    -- 1. Keep only identified customers
    CustomerID IS NOT NULL 
    AND TRIM(CustomerID) != ''
    
    -- 2. Keep only positive sales
    AND Quantity > 0
    AND Price > 0
    
    -- 3. Exclude formal order cancellations
    AND NOT STARTS_WITH(UPPER(Invoice), 'C')
    
    -- 4. Exclude non-product operational fees
    AND UPPER(TRIM(StockCode)) NOT IN ('POST', 'D', 'M', 'BANK CHARGES', 'PADS', 'CRUK', 'DOT');