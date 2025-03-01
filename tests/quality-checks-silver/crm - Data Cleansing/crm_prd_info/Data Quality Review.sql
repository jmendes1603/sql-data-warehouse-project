/*
=================================================================================
Checking For Potential Issues in bronze.crm_prd_info
=================================================================================
*/
-- Check for Null or Duplicates in Primary Key --
-- Expectation: No Result --
SELECT 
prd_id,
COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL
GO
---------------------------------------------------------------------------------
-- Normalizing and Comparing Category ID with ID in the ERP Category table --
SELECT 
REPLACE(SUBSTRING (prd_key, 1, 5), '-','_') AS cat_id 
FROM bronze.crm_prd_info
WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-','_') NOT IN (SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2)
GO
---------------------------------------------------------------------------------
-- Normalizing and Comparing Product Key with Product Key in the CRM sales table --
SELECT 
SUBSTRING (prd_key, 7, LEN(prd_key)) AS prd_key
FROM bronze.crm_prd_info
WHERE SUBSTRING (prd_key, 7, LEN(prd_key)) IN (SELECT DISTINCT sls_prd_key FROM bronze.crm_sales_details)
GO
---------------------------------------------------------------------------------
-- Check for Spacing Error in Product Name --
-- Expectation: No Result --
SELECT
*
FROM bronze.crm_prd_info
WHERE TRIM(prd_nm) != prd_nm
GO
---------------------------------------------------------------------------------
-- Check Product Cost for Negative & Null Values --
-- Expectation: No Result --
SELECT
*
FROM bronze.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0
--2 NULL VALUES ARE RETURNED.--
-- THIS SHOULD BE NOTED AND INVESTIGATED FURTHER TO PREVENT FUTURE ISSUES AND FIX DATA. DATA WILL NOT BE CHANGED. --
GO
---------------------------------------------------------------------------------
-- Check Consistency in prd_line --
-- Expectation: Only a few. --
SELECT
DISTINCT prd_line,
COUNT(*) AS num_entries
FROM bronze.crm_prd_info
GROUP BY prd_line
GO
---------------------------------------------------------------------------------
-- Identifying full name of Abbreviations -- 
SELECT
prd_nm,
prd_line
FROM bronze.crm_prd_info
WHERE prd_line = 'M' -- Contains Mountain --
GO
SELECT
prd_nm,
prd_line
FROM bronze.crm_prd_info
WHERE prd_line = 'R' -- Contains Road --
GO
SELECT
prd_nm,
prd_line
FROM bronze.crm_prd_info
WHERE prd_line = 'S' -- Other Sales --
GO 
SELECT
prd_nm,
prd_line
FROM bronze.crm_prd_info
WHERE prd_line = 'T' -- Touring -- 
GO
SELECT
prd_nm,
prd_line
FROM bronze.crm_prd_info
WHERE prd_line IS NULL
GO
---------------------------------------------------------------------------------
-- Comparing Start and End Dates --
-- Expectation: Only a few. --
SELECT
prd_start_dt,
prd_end_dt,
COUNT(*) AS frequency
FROM bronze.crm_prd_info
GROUP BY prd_start_dt, prd_end_dt
-- Issue 1. Start Dates are After End Dates --
-- Issue 2. 2 Null Value Dates Seem as though they should be Start Dates.
SELECT
CASE WHEN prd_end_dt  IS NULL THEN CAST('2008-12-28' AS DATE)
	ELSE prd_end_dt
END AS prd_start_dt,
CASE WHEN prd_start_dt = '2003-07-01' THEN DATEADD(YEAR, 10, prd_start_dt)
	ELSE prd_start_dt
END AS prd_end_dt ,
COUNT(*) AS frequency
FROM bronze.crm_prd_info
GROUP BY prd_start_dt, prd_end_dt

GO

/*
=================================================================================
Reviewing Silver Layer
=================================================================================
*/
SELECT * FROM silver.crm_prd_info
-- Check for Null or Duplicates in Primary Key --
-- Expectation: No Result --
SELECT 
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL
GO
---------------------------------------------------------------------------------
-- Check for Spacing Error in Product Name --
-- Expectation: No Result --
SELECT
*
FROM bronze.crm_prd_info
WHERE TRIM(prd_nm) != prd_nm
GO
---------------------------------------------------------------------------------
-- Check Product Cost for Negative & Null Values --
-- Expectation: No Result --
SELECT
*
FROM silver.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0
-- 2 NULL VALUES!! --
GO
---------------------------------------------------------------------------------
-- Check Consistency in Product Line --
-- Expectation: 5 Results --
SELECT
DISTINCT prd_line
FROM silver.crm_prd_info
GO
---------------------------------------------------------------------------------
-- Invalid Dates --
-- Expectation: 0 Results --
SELECT
*
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt