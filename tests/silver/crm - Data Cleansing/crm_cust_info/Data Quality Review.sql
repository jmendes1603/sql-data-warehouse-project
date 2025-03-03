/*
=================================================================================
Checking for potential Issues in bronze.crm_cust_info
=================================================================================
*/
-- Check for Null or Duplicates in Primary Key --
-- Expectation: No Result --

SELECT 
cst_id,
COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL
GO
---------------------------------------------------------------------------------
--Check for Unwanted Spaced in --
-- Expectation: No Result --
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
GO
SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)
GO
---------------------------------------------------------------------------------
-- Check Consistency in cst_gndr & cst_marital_status --
-- Expectation: Only few --
SELECT DISTINCT 
cst_marital_status
FROM bronze.crm_cust_info
SELECT DISTINCT 
cst_gndr
FROM bronze.crm_cust_info
GO

/*
=================================================================================
Reviewing Silver Layer
=================================================================================
*/
SELECT * FROM silver.crm_cust_info
-- Check for Null or Duplicates in Primary Key --
-- Expectation: No Result --
SELECT 
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL
GO
---------------------------------------------------------------------------------
--Check for Unwanted Spaced in --
-- Expectation: No Result --
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
GO
SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)
GO
---------------------------------------------------------------------------------
-- Check Consistency in cst_gndr & cst_marital_status --
-- Expectation: 2-3 -- 
SELECT DISTINCT 
cst_marital_status
FROM silver.crm_cust_info -- Marital Status only has 2 because the null values were only present in the duplicate cst_id entries --
SELECT DISTINCT 
cst_gndr
FROM silver.crm_cust_info