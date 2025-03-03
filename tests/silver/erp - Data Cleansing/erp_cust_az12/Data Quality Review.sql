/*
=================================================================================
Checking For Potential Issues in bronze.erp_cust_az12
=================================================================================
*/
-- Check for Unwanted Spaces in Primary Key --
-- Expectation: No Result --
SELECT
cid
FROM bronze.erp_cust_az12
WHERE cid != TRIM(cid)
-- Normalize cid to cst_key in crm customer info table --
SELECT
CASE WHEN SUBSTRING(cid,1,3) != 'AW0' THEN SUBSTRING(cid,4,LEN(cid))
	ELSE cid
END AS cid,
CASE WHEN SUBSTRING(cid,1,3) != 'AW0' THEN SUBSTRING(cid,1,3)
	ELSE 'n/a'
END AS pre_cid
FROM bronze.erp_cust_az12
GO
---------------------------------------------------------------------------------
-- Checking for issues in birthdate --
-- Expectation: No Result --
SELECT
bdate
FROM bronze.erp_cust_az12
WHERE bdate > CAST('2010-01-01' AS DATE)
ORDER BY bdate
-- Attempt to clean values. Where not obvious, leave as NULL --
GO
---------------------------------------------------------------------------------
-- Normalizing gender column --
SELECT
DISTINCT gen,
COUNT(*) AS 'count'
FROM bronze.erp_cust_az12
GROUP BY gen
GO
-- Compare to gender table --
SELECT
DISTINCT cst_gndr,
COUNT(*) AS 'count'
FROM silver.crm_cust_info
GROUP BY cst_gndr
GO

SELECT
DISTINCT(CASE WHEN TRIM(gen) = 'F' OR TRIM(gen) = 'Female' THEN 'Female'
	WHEN TRIM(gen) = 'M' OR TRIM(gen) = 'Male' THEN 'Male'
	ELSE 'n/a'
END) AS gen,
COUNT(*) AS count
FROM bronze.erp_cust_az12
GROUP BY gen
GO

/*
=================================================================================
Reviewing Silver Layer
=================================================================================
*/
-- Check for Unwanted Spaces in Primary Key --
-- Expectation: No Result --
SELECT
cid
FROM silver.erp_cust_az12
WHERE cid != TRIM(cid)
---------------------------------------------------------------------------------
-- Checking for issues in birthdate --
-- Expectation: No Result --
SELECT
bdate
FROM silver.erp_cust_az12
WHERE bdate > CAST('2010-01-01' AS DATE)
ORDER BY bdate
-- Attempt to clean values. Where not obvious, leave as NULL --
GO
---------------------------------------------------------------------------------
-- Review gender column --
-- Expectation: 3 Results --
SELECT
DISTINCT gen,
COUNT(*) AS 'count'
FROM silver.erp_cust_az12
GROUP BY gen
GO