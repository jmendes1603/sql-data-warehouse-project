/*
=================================================================================
5.4 Data Cleansing (ERP: Customer Information)
=================================================================================
Script Purpose:	
*/
PRINT '>> Truncating Table: silver.erp_cust_az12';
TRUNCATE TABLE silver.erp_cust_az12
PRINT '>> Insterting Data Into: silver.erp_cust_az12'
INSERT INTO silver.erp_cust_az12(
cid,
bdate,
gen)
	SELECT
	CASE WHEN SUBSTRING(cid,1,3) != 'AW0' THEN SUBSTRING(cid,4,LEN(cid)) 
		ELSE cid
	END AS cid,
	CASE WHEN bdate >= CAST('1900-01-01' AS DATE) AND bdate < CAST('2010-01-01' AS DATE) THEN bdate
		WHEN bdate >= CAST('2010-01-01' AS DATE) AND bdate < CAST('2100-01-01' AS DATE) THEN DATEADD(YEAR,-100,bdate)
		WHEN bdate >= CAST('2900-01-01' AS DATE) AND bdate < CAST('3000-01-01' AS DATE) THEN DATEADD(YEAR,-1000,bdate)
		ELSE NULL
	END AS bdate,

	CASE WHEN TRIM(gen) = 'F' OR TRIM(gen) = 'Female' THEN 'Female'
		WHEN TRIM(gen) = 'M' OR TRIM(gen) = 'Male' THEN 'Male'
		ELSE 'n/a'
	END AS gen

	FROM bronze.erp_cust_az12
GO
