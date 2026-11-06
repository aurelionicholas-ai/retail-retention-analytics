-- Goal: Verify clean data volume, customer count, revenue total, and ensure anomalies are fully removed.
SELECT 
    -- 1. Check clean dataset volume and unique business entities
    COUNT(*) AS total_clean_rows,
    COUNT(DISTINCT CustomerID) AS total_clean_customers,
    COUNT(DISTINCT Invoice) AS total_clean_invoices,
    -- 2. Confirm analysis date boundaries
    MIN(InvoiceDate) AS min_date,
    MAX(InvoiceDate) AS max_date,
    -- 3. Calculate baseline analytical revenue
    ROUND(SUM(LineTotal), 2) AS total_clean_revenue,
    -- 4. Verify boundary integrity (confirm negative and zero values are eliminated)
    MIN(Quantity) AS min_quantity,
    MIN(Price) AS min_price
FROM `retention_case_study.clean_retail_transactions`;