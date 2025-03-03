/*
=================================================================================
5.6 Data Cleansing (ERP: Product Categories)
=================================================================================
Script Purpose:
	Complete silver table for product categories. No Changes where required.
*/
PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
TRUNCATE TABLE silver.erp_px_cat_g1v2
PRINT '>> Insterting Data Into: silver.erp_px_cat_g1v2'
INSERT INTO silver.erp_px_cat_g1v2(
id,
cat,
subcat,
maintenance)
	SELECT
	id,
	cat,
	subcat,
	maintenance
	FROM bronze.erp_px_cat_g1v2
GO