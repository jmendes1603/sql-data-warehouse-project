/*
=================================================================================
Checking For Potential Issues in bronze.crm_sales_details
=================================================================================
*/
-- Check for Unwanted Spaces --
-- Expectation: No Result --
SELECT
*
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)
GO
-- Checking for duplications of Primary Keys--
-- Expectation: No Result --
SELECT 
sls_ord_num,
sls_prd_key,
COUNT(*) AS 'count'
FROM bronze.crm_sales_details
GROUP BY sls_ord_num, sls_prd_key
HAVING COUNT(*) > 1
GO
---------------------------------------------------------------------------------
-- Review Customer ID --
-- Expectation: No Result --
SELECT
sls_cust_id
FROM bronze.crm_sales_details
WHERE sls_cust_id  NOT IN (SELECT cst_id FROM bronze.crm_cust_info)
GO
---------------------------------------------------------------------------------
-- Check for Unwanted Spaces --
-- Expectation: No Result --
SELECT
*
FROM bronze.crm_sales_details
WHERE sls_prd_key != TRIM(sls_prd_key)
GO
-- Reviewing Product Key --
-- Comparing to Substring in bronze table / Not comparing to silver table for future proof incase of error in silver tables --
-- Expectation: No Result --
SELECT 
sls_prd_key
FROM bronze.crm_sales_details
WHERE sls_prd_key  NOT IN (SELECT SUBSTRING (prd_key, 7, LEN(prd_key)) FROM bronze.crm_prd_info)
GO
---------------------------------------------------------------------------------
-- Reviewing Dates --
-- Expectation: No Result --
SELECT
sls_order_dt -- Process is the same for shipping and due dates (They do not have any issues) --
FROM bronze.crm_sales_details
WHERE 
sls_order_dt <= 20071217 -- 20081217 is the earliest start date identified in the prd_info section --
OR sls_order_dt >= 21000101 -- 21000101 is a date far into the future to capture as much information as possible --
OR sls_order_dt IS NULL 
-- 18 Results: Replace these values with NULL & Change from INT data types to DATE data types --
GO
--Checking congruence between dates--
-- Expectation: No Results--
SELECT 
*
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_ship_dt > sls_due_dt
---------------------------------------------------------------------------------
-- Reviewing Sales, Quantity and Price Congruence --
-- Expectation: No Results --
SELECT
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_price * sls_quantity
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
-- The sales is the quantity * price --
-- The implausible values are only present for sales and price, use absolute values and calculations to fix error --
-- Consult with expert on how to fix the issues. --
-- In this case the following rules apply --
-- 1. If Sales is negative, zero or null, derive it using Quantity and Price
-- 2. If Price is zero or null, calculate it using Sales and Quantity
-- 3. If Price is negative, convert it to a positive value
GO

/*
=================================================================================
Reviewing Silver Layer
=================================================================================
*/
SELECT * FROM silver.crm_sales_details
-- Check for Unwanted Spaces --
-- Expectation: No Result --
SELECT
*
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num) OR sls_prd_key != TRIM(sls_prd_key)
GO
---------------------------------------------------------------------------------
-- Review Customer ID --
-- Expectation: No Result --
SELECT
sls_cust_id
FROM silver.crm_sales_details
WHERE sls_cust_id  NOT IN (SELECT cst_id FROM bronze.crm_cust_info)
GO
---------------------------------------------------------------------------------
-- Check for Unwanted Spaces --
-- Expectation: No Result --
SELECT
*
FROM silver.crm_sales_details
WHERE sls_prd_key != TRIM(sls_prd_key)
GO
-- Reviewing Product Key --
-- Comparing to Substring in bronze table / Not comparing to silver table for future proof incase of error in silver tables --
-- Expectation: No Result --
SELECT 
sls_prd_key
FROM silver.crm_sales_details
WHERE sls_prd_key  NOT IN (SELECT SUBSTRING (prd_key, 7, LEN(prd_key)) FROM bronze.crm_prd_info)
GO
---------------------------------------------------------------------------------
-- Reviewing Dates --
-- Expectation: No Result --
SELECT
sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt < CAST('2000-01-01' AS DATE)
GO
SELECT
sls_due_dt
FROM silver.crm_sales_details
WHERE sls_order_dt > CAST('2100-01-01' AS DATE)
GO
--Checking congruence between dates--
-- Expectation: No Results--
SELECT 
*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_ship_dt > sls_due_dt
GO
---------------------------------------------------------------------------------
-- Reviewing Sales, Quantity and Price Congruence --
-- Expectation: No Results --
SELECT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_price * sls_quantity
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
GO