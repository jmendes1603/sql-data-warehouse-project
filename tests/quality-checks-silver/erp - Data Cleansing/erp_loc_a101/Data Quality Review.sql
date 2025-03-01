/*
=================================================================================
Checking For Potential Issues in bronze.erp_cust_az12
=================================================================================
*/
-- Normalizing cid to match format in other tables --
-- Expectation: No Results -- 
SELECT
cid
FROM bronze.erp_loc_a101
WHERE cid NOT IN (SELECT cst_key FROM bronze.crm_cust_info)
GO

SELECT * FROM bronze.crm_cust_info
---------------------------------------------------------------------------------
-- Normalize cnty column --
SELECT
DISTINCT cntry,
COUNT (*) AS count
FROM bronze.erp_loc_a101
GROUP BY cntry
GO
/*
=================================================================================
Reviewing Silver Layer
=================================================================================
*/
-- Normalizing cid to match format in other tables --
-- Expectation: No Results -- 
SELECT
cid
FROM silver.erp_loc_a101
WHERE cid NOT IN (SELECT cst_key FROM bronze.crm_cust_info)
GO
---------------------------------------------------------------------------------
-- Normalize cnty column --
-- Expectation: 7 Results --
SELECT
DISTINCT cntry,
COUNT (*) AS count
FROM silver.erp_loc_a101
GROUP BY cntry
GO