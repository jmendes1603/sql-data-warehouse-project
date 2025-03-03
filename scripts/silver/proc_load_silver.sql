/*
=================================================================================
5.2 Data Cleansing (CRM: Product Info)
=================================================================================
Script Purpose:
	This script runs checks on every row to normalize values, handle missing data, data type casting, and data enrichment.
	This script also contains a derived column (cat_id), to help normalize the data with the erp Category table.
*/
PRINT '>> Truncating Table: silver.crm_prd_info';
TRUNCATE TABLE silver.crm_prd_info
PRINT '>> Insterting Data Into: silver.crm_prd_info'
INSERT INTO  silver.crm_prd_info (
prd_id,
cat_id, -- This column did not exist, meta data had to be adjusted --
prd_key,
prd_nm,
prd_cost,prd_line,
prd_start_dt,
prd_end_dt)

	SELECT 
	prd_id,
	CASE WHEN REPLACE(SUBSTRING (prd_key, 1, 5), '-','_') = 'CO_PE' THEN 'CO_PD'
		ELSE REPLACE(SUBSTRING (prd_key, 1, 5), '-','_')
		END AS cat_id,
	SUBSTRING (prd_key, 7, LEN(prd_key)) AS prd_key,
	prd_nm,
	prd_cost,
	CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a'
	END AS prd_line,
	CASE WHEN prd_end_dt  IS NULL THEN CAST('2008-12-28' AS DATE)
		ELSE prd_end_dt
	END AS prd_start_dt,
	CASE WHEN prd_start_dt = '2003-07-01' THEN DATEADD(YEAR, 10, prd_start_dt)
		ELSE prd_start_dt
	END AS prd_end_dt
	FROM bronze.crm_prd_info
GO
