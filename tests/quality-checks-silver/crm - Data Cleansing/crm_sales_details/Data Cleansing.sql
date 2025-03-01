/*
=================================================================================
5.3 Data Cleansing (CRM: Sales Details)
=================================================================================
Script Purpose:
	This script runs checks on every row to normalize values, change data types, and make corrective calculations where appropriate.
*/
PRINT '>> Truncating Table: silver.crm_sales_details';
TRUNCATE TABLE silver.crm_sales_details
PRINT '>> Insterting Data Into: silver.crm_sales_details'
INSERT INTO silver.crm_sales_details(
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price)
	SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN LEN(sls_order_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) -- In SQL, data types cannot be converted from INT to DATE, they must first be converted to VARCHAR --
	END AS sls_order_dt,
	CASE WHEN LEN(sls_ship_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) 
	END AS sls_ship_dt,
	CASE WHEN LEN(sls_due_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END AS sls_due_dt,
	CASE WHEN sls_sales != sls_price*sls_quantity OR sls_sales IS NULL THEN ABS(sls_quantity*sls_price)
		ELSE sls_sales
	END AS sls_sales,
	sls_quantity,
	CASE WHEN sls_price IS NULL THEN ABS(sls_sales)/sls_quantity
		WHEN sls_price < 0 THEN ABS(sls_price)
		ELSE sls_price
	END AS sls_price
	FROM bronze.crm_sales_details
	ORDER BY sls_sales
GO