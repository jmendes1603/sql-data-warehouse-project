-- Check for Unwanted Spacing --
SELECT id
FROM bronze.erp_px_cat_g1v2
WHERE id != TRIM(id)
GO
SELECT cat
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
GO
SELECT subcat
FROM bronze.erp_px_cat_g1v2
WHERE subcat != TRIM(subcat)
GO
SELECT maintenance
FROM bronze.erp_px_cat_g1v2
WHERE maintenance != TRIM(maintenance)
GO
--------------------------------------------------------------------------------- 

-- Check for Normalizing Data --
SELECT 
cat,
COUNT(*) AS count
FROM bronze.erp_px_cat_g1v2
GROUP BY cat
SELECT 
subcat,
COUNT(*) AS count
FROM bronze.erp_px_cat_g1v2
GROUP BY subcat
SELECT 
maintenance,
COUNT(*) AS count
FROM bronze.erp_px_cat_g1v2
GROUP BY maintenance
/*
=================================================================================
Reviewing Silver Layer
=================================================================================
*/
SELECT * FROM silver.erp_px_cat_g1v2
-- Check for Unwanted Spacing --
SELECT id
FROM silver.erp_px_cat_g1v2
WHERE id != TRIM(id)
GO
SELECT cat
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
GO
SELECT subcat
FROM silver.erp_px_cat_g1v2
WHERE subcat != TRIM(subcat)
GO
SELECT maintenance
FROM silver.erp_px_cat_g1v2
WHERE maintenance != TRIM(maintenance)
GO
--------------------------------------------------------------------------------- 

-- Check for Normalizing Data --
SELECT 
cat,
COUNT(*) AS count
FROM silver.erp_px_cat_g1v2
GROUP BY cat
SELECT 
subcat,
COUNT(*) AS count
FROM silver.erp_px_cat_g1v2
GROUP BY subcat
SELECT 
maintenance,
COUNT(*) AS count
FROM silver.erp_px_cat_g1v2
GROUP BY maintenance