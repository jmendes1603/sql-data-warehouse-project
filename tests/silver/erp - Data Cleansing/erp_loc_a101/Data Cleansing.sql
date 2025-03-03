/*
=================================================================================
5.5 Data Cleansing (ERP: Location Information)
=================================================================================
Script Purpose:

*/
PRINT '>> Truncating Table: silver.erp_loc_a101';
TRUNCATE TABLE silver.erp_loc_a101
PRINT '>> Insterting Data Into: silver.erp_loc_a101'
INSERT INTO silver.erp_loc_a101(
cid,
cntry)
	SELECT 
	REPLACE(cid,'-','') AS cid, 
	CASE WHEN cntry =  'DE' THEN 'Germany'
		WHEN cntry = 'US' OR cntry = 'USA' THEN 'United States'
		WHEN cntry = '' THEN NULL
		ELSE cntry
	END AS cntry
	FROM bronze.erp_loc_a101
GO