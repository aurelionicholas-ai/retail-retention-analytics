--Goal : Combine two yearly raw datasets into one single table and fix customer ID format.

CREATE OR REPLACE TABLE `retention_case_study.raw_retail_all` AS
SELECT 
    Invoice,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    Price,
    CAST(`Customer ID` AS STRING) AS CustomerID,
    Country
FROM `retention_case_study.raw_data_2009_2010`

UNION ALL

SELECT 
    Invoice,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    Price,
    CAST(`Customer ID` AS STRING) AS CustomerID,
    Country
FROM `retention_case_study.raw_data_2010_2011`;