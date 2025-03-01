/*
=================================================================================
5. Loading Data & Creating Procedure
=================================================================================
Script Purpose:
	This script creates a procedure called 'silver.load_silver'
	This procedure loads the data from the bronze tables into the tables created in the silver layer.
	The script also provides the Load Duration for each table as well as the Load Duration of the entire procedure.
	Running the procedure will also say the number of rows affected.

WARNING:
	Running this script will replace any procedure with the same name
*/
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
---------------------------------------------------------------------------------
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '==========================================================================='
		PRINT 'Loading Silver Layer'
		PRINT '==========================================================================='
		PRINT '---------------------------------------------------------------------------'
		PRINT 'Loading CRM Tables'
		PRINT '---------------------------------------------------------------------------'
		PRINT ''
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info
		PRINT '>> Insterting Data Into: silver.crm_cust_info'
		INSERT INTO silver.crm_cust_info (
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date)

			SELECT 
			cst_id,
			cst_key,
			TRIM(cst_firstname) as cst_firstname,
			TRIM(cst_lastname) as cst_lastname,
			CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				ELSE 'n/a'
			END cst_marital_status, 
			CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				ELSE 'n/a'
			END cst_gndr,
			cst_create_date
			FROM(

				SELECT
				*,
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
				FROM bronze.crm_cust_info
				WHERE cst_id IS NOT NULL
			)x

			WHERE flag_last = 1
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
---------------------------------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT ''
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
			REPLACE(SUBSTRING (prd_key, 1, 5), '-','_') AS cat_id,
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
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
---------------------------------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT ''
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
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
---------------------------------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT ''
		PRINT '---------------------------------------------------------------------------'
		PRINT 'Loading ERP Tables'
		PRINT '---------------------------------------------------------------------------'
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
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
---------------------------------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT ''
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
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
---------------------------------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT ''
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
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
---------------------------------------------------------------------------------
	SET @batch_end_time = GETDATE();
	PRINT '==========================================================================='
	PRINT '>> Bronze Batch Load Duration:' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds'
	PRINT '==========================================================================='
	END TRY
	BEGIN CATCH
		PRINT '==========================================================================='
		PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '==========================================================================='
	END CATCH
END
