-- Import records of the gicen file
SELECT 
  dr.*
FROM
  dsa_file dsf,
  dsa_record dr
WHERE
  dsf.dsf_filename = 'C:\Import\FilesInProcess\ETL_1151_Q2_UBS Tareno_Vario_CS_POS.csv'
  AND dr.file_id = dsf.file_id  


-- Transactions from import records
SELECT 
  tr.*
FROM
  dsa_file dsf,
  dsa_record dr,
  trx tr
WHERE
  dsf.dsf_filename = 'C:\Import\FilesInProcess\ETL_1151_Q2_UBS Tareno_Vario_CS_POS.csv'
  AND dr.file_id = dsf.file_id
  AND tr.rec_id = dr.rec_id
ORDER BY dr.file_id, dr.rec_id, tr.trx_id

-- Accounts and funds and transactions from import records
SELECT 
  d.detail_id,
  d.det_isin_nr,
  acc.acc_id, 
  acc.acc_number, 
  acc.acc_retro_entitled,
  tr.*
FROM
  dsa_file dsf,
  dsa_record dr,
  trx tr,
  detail d,
  account acc
WHERE
  dsf.dsf_filename = 'C:\Import\FilesInProcess\ETL_1151_Q2_UBS Tareno_Vario_CS_POS.csv'
  AND dr.file_id = dsf.file_id
  AND tr.rec_id = dr.rec_id
  AND d.detail_id = tr.detail_id
  AND acc.acc_id = tr.acc_id
ORDER BY dr.file_id, dr.rec_id, tr.trx_id
  
-- Distribution partners and their accounts and Cooperation partners and their funds and transactions from import records
SELECT 
  dsf.file_id,
  pr.par_id AS cp_id,
  pr.par_number AS cp_number,
  pr.par_company_name AS cp_name,
  d.detail_id,
  d.det_isin_nr,
  acc.acc_id, 
  acc.acc_number, 
  acc.acc_retro_entitled,
  tr.*
FROM
  dsa_file dsf,
  dsa_record dr,
  trx tr,
  detail d,
  product_partner pp,
  partner pr,
  account acc,
  partner_customer pc,
  partner pd
WHERE
  --dsf.dsf_filename = :FILENAME
  dsf.file_id BETWEEN 10170 AND 10180
  AND dr.file_id = dsf.file_id
  AND tr.rec_id = dr.rec_id
  AND d.detail_id = tr.detail_id
  AND pp.product_id = d.product_id
  AND tr.trx_date BETWEEN pp.prop_date_from AND pp.prop_date_to
  AND pr.par_id = pp.par_id
  AND acc.acc_id = tr.acc_id
  AND acc.cust_id = pc.cust_id
  AND tr.trx_date BETWEEN pc.pc_date_from AND pc.pc_date_to
  AND pd.par_id = pc.par_id  
ORDER BY dr.file_id, dr.rec_id, tr.trx_id

-- *265 - Position reallocation* holding files which will be tsed in testng
SELECT
  file_id, dsf_timestamp, dsf_filename
FROM dsa_file
WHERE file_id BETWEEN 10173 AND 10179
-- FILE_ID;DSF_TIMESTAMP;DSF_FILENAME
-- 10173;3/20/2019 6:58:07 AM;C:\Import\FilesInProcess\ETL_24_Q2_BNP Paribas_DAB_Bestandsmeldung_POS.csv
-- 10174;3/20/2019 6:58:13 AM;C:\Import\FilesInProcess\ETL_5_Q2_Exclusions NET Acolin Fund Services AG_POS.csv
-- 10175;3/20/2019 6:58:16 AM;C:\Import\FilesInProcess\ETL_7000_Q2_04_Excluded EAM_5432_POS.csv
-- 10176;3/20/2019 6:58:18 AM;C:\Import\FilesInProcess\ETL_7000_Q2_05_Excluded EAM_5432_POS.csv
-- 10177;3/20/2019 6:58:21 AM;C:\Import\FilesInProcess\ETL_7000_Q2_06_Excluded EAM_5432_POS.csv
-- 10178;3/20/2019 6:58:23 AM;C:\Import\FilesInProcess\ETL_7018_Q2_Vario_PR_Gross_POS.csv
-- 10179;3/20/2019 6:58:50 AM;C:\Import\FilesInProcess\ETL_10053_Clearstream_Lux_Bestandsmeldung_072017_POS.csv

-- Find all calculation tasks affected by import file of *265 - Position reallocation*
SELECT
  dsf.file_id,
  pr.par_id AS cp_id,
  pr.par_number AS cp_number,
  pr.par_company_name AS cp_name,
  t.task_id AS cp_calc_id,
  t.task_para_date_01 AS cp_calc_starts,
  t.task_para_date_02 AS cp_calc_ends,
  t.task_description AS cp_calc_description,
  d.detail_id,
  d.det_isin_nr,
  acc.acc_id, 
  acc.acc_number, 
  acc.acc_retro_entitled,
  tr.*
FROM
  dsa_file dsf,
  dsa_record dr,
  trx tr,
  detail d,
  product_partner pp,
  partner pr,
  account acc,
  partner_customer pc,
  partner pd,
  quantity q,
  retro r,
  task t
WHERE
  --dsf.dsf_filename = :FILENAME
  dsf.file_id BETWEEN 10000 AND 20180
  AND dr.file_id = dsf.file_id
  AND tr.rec_id = dr.rec_id
  AND d.detail_id = tr.detail_id
  AND pp.product_id = d.product_id
  AND tr.trx_date BETWEEN pp.prop_date_from AND pp.prop_date_to
  AND pr.par_id = pp.par_id
  AND acc.acc_id = tr.acc_id
  AND acc.cust_id = pc.cust_id
  AND tr.trx_date BETWEEN pc.pc_date_from AND pc.pc_date_to
  AND pd.par_id = pc.par_id  
  AND q.detail_id = tr.detail_id
  AND q.acc_id = tr.acc_id 
  AND q.qty_date = tr.trx_date
  AND r.qty_id = q.qty_id
  AND r.category_id = 60101
  AND t.task_id = r.calc_task_id 
ORDER BY dr.file_id, dr.rec_id, tr.trx_id

SELECT * FROM retro WHERE calc_task_id = 10216

  
SELECT * FROM trx WHERE rec_id = 61172
  

SELECT * FROM account WHERE acc_id IN (10081, 10090)


SELECT * FROM dsa_source WHERE src_id = 265

SELECT * FROM quantity
WHERE detail_id = 12640


SELECT * FROM customer 
WHERE cust_id IN (SELECT cust_id FROM Account WHERE acc_id IN (10081, 10090))


SELECT * FROM dsa_source ORDER BY 1


-- CPs, DPs, funds, customer groups to be used in the importing of CP models with help of "201 PROD-Model-Condition" import interface
SELECT DISTINCT
  pr.par_id AS cp_id,
  pr.par_number AS cp_number,
  pr.par_company_name AS cp_name,
  d.detail_id,
  d.det_isin_nr,
  pd.par_id AS dp_id,
  pd.par_number AS dp_number,
  pd.par_company_name AS dp_name,
  cg.cg_id AS dp_cg_id,
  cg.cg_description AS dp_cg_description
FROM
  dsa_file dsf,
  dsa_record dr,
  trx tr,
  detail d,
  product_partner pp,
  partner pr,
  account acc,
  partner_customer pc,
  partner pd,
  customer_customergroup ccg,
  customergroup cg
WHERE
  --dsf.dsf_filename = :FILENAME
  dsf.file_id BETWEEN 10000 AND 20180
  AND dr.file_id = dsf.file_id
  AND tr.rec_id = dr.rec_id
  AND d.detail_id = tr.detail_id
  AND pp.product_id = d.product_id
  AND tr.trx_date BETWEEN pp.prop_date_from AND pp.prop_date_to
  AND pr.par_id = pp.par_id
  AND acc.acc_id = tr.acc_id
  AND acc.cust_id = pc.cust_id
  AND acc.acc_retro_entitled = 'Y'
  AND tr.trx_date BETWEEN pc.pc_date_from AND pc.pc_date_to
  AND pd.par_id = pc.par_id  
  AND ccg.cust_id = pc.cust_id
  AND tr.trx_date BETWEEN ccg.ccg_date_from AND ccg.ccg_date_to
  AND cg.cg_id = ccg.cg_id


SELECT * FROM dsa_record
WHERE src_id = 201
ORDER BY 1 DESC

SELECT * FROM dsa_file
WHERE src_id = 201
ORDER BY 1 DESC

SELECT * FROM seq

INSERT INTO dsa_file (file_id, dsf_filename, dsf_timestamp, src_id, dsf_no_lines, dsf_no_recs)
SELECT
  seq_dsa_file.nextval, 'ALL CPs ' || TO_CHAR(SYSDATE, 'dd.mm.yyyy hh24:mi:ss') AS dsf_filename,
  SYSDATE AS dsf_timestamp, src_id, 1 AS dsf_no_lines, 0 AS dsf_no_recs
FROM dsa_file
WHERE file_id = (SELECT MAX(file_id) FROM dsa_file WHERE src_id = 201

SELECT MAX(file_id) FROM dsa_file WHERE src_id = 201
-- 10300

INSERT INTO dsa_record ( file_id, src_id, dsr_verify, dsr_data_01,  dsr_data_02,  dsr_data_03,  dsr_data_04,  dsr_data_05,  dsr_data_06,  dsr_data_07,  dsr_data_08,  dsr_data_09,  dsr_data_10,
                         dsr_data_11,  dsr_data_12,  dsr_data_13,  dsr_data_14,  dsr_data_15,  dsr_data_16,  dsr_data_17,
                         dsr_data_20,  dsr_data_21,  dsr_data_23,  dsr_data_33,  dsr_data_34,  dsr_data_39,  dsr_data_40,
                         dsr_data_54,  dsr_data_60,  dsr_data_61,  dsr_data_62,  dsr_ignore )
                         
SELECT
  10300 AS file_id, 201 AS src_id, dsr_verify, dsr_data_01,  dsr_data_02,  dsr_data_03,  dsr_data_04,  dsr_data_05, dsr_data_06,  dsr_data_07,  dsr_data_08,  dsr_data_09,  dsr_data_10,
  dsr_data_11,  dsr_data_12,  dsr_data_13,  dsr_data_14,  dsr_data_15,  dsr_data_16,  dsr_data_17,
  dsr_data_20,  dsr_data_21,  dsr_data_23,  dsr_data_33,  dsr_data_34,  dsr_data_39,  dsr_data_40,
  dsr_data_54,  dsr_data_60,  dsr_data_61,  dsr_data_62,  dsr_ignore 
FROM (
SELECT DISTINCT
'N' AS dsr_verify,
pr.par_number || '_' || pd.par_number || '_' || '112' || '_' || '122' || '_' || '51' || '_' || 'Q' || '_' || 'CHF' AS dsr_data_01, -- Model name
pr.par_company_name || '_' || pd.par_number || '_' || '112' || '_' || '122' || '_' || '51' || '_' || 'Q' || '_' || 'CHF' AS dsr_data_02, -- Model description
'CHF' AS dsr_data_03, -- Model currency
'112' AS dsr_data_04, -- Rate Determination Algorith : 111	- Fund Group / 112 - Model
'60101' AS dsr_data_05, -- 60101 - Final Cooperation Trailer Fee
'100.0' AS dsr_data_06, -- Beneficiary Percentage
'122' AS dsr_data_07, -- Usance (Calc Type) : 121	A/A, 122 30/360, 123 A/360
d.det_isin_nr AS dsr_data_08, -- Productgroup name
'01.01.2000' AS dsr_data_09, -- Productgroup Start
'31.12.9999' AS dsr_data_10, -- Productgroup End
'94' AS dsr_data_11, -- Productgroup Usance (Calc Type) : 92 Class, 93 Level, 94	CAL	Class (on Fee)
'01.01.2000' AS dsr_data_12, -- Condition Start
'31.12.9999' AS dsr_data_13, -- Condition End
TO_CHAR(con.con_range_1_min) AS dsr_data_14, -- Condition Range 1 Min
TO_CHAR(con.con_range_1_max) AS dsr_data_15, -- Condition Range 1 Max
'0' || TO_CHAR(con.con_rate_1) AS dsr_data_16, -- Condition Rate 1
'241' AS dsr_data_17, -- Fee type : 241 - Management Fee
pr.par_number AS dsr_data_20, -- Origin Partner Number
pr.par_number AS dsr_data_21, -- Partner Number
'51' AS dsr_data_23, -- Exchange Rate Calculation Kind : 51 End of Month, 52 Daily Average per Month, 53	Daily Average per Period
'01.01.2000' AS dsr_data_33, -- Partner Start Date
'51' AS dsr_data_34, -- Quantity Calculation Kind : 51 End of Month	
'51' AS dsr_data_35, -- Price Calculation Kind : 51 End of Month
pd.par_number AS dsr_data_39, -- Customer Group Name 
'Quarterly' AS dsr_data_40, -- Periodicity
'Quarterly' AS dsr_data_54, -- Payment periodicity
'N' AS dsr_data_60, -- TER flag
'Y' AS dsr_data_61, -- Reconciliation Entitled Flag
'Y' AS dsr_data_62, -- Export Entitled Flag
'N' AS dsr_ignore
FROM
  dsa_file dsf,
  dsa_record dr,
  trx tr,
  detail d,
  product_partner pp,
  partner pr,
  account acc,
  partner_customer pc,
  partner pd,
  customer_customergroup ccg,
  customergroup cg,
  ( SELECT 0 AS con_range_1_min, 1000000 AS con_range_1_max, 0.1 AS con_rate_1 FROM DUAL
    UNION ALL 
    SELECT 1000000 AS con_range_1_min, 10000000 AS con_range_1_max, 0.05 AS con_rate_1 FROM DUAL
    UNION ALL 
    SELECT 10000000 AS con_range_1_min, 9999999999 AS con_range_1_max, 0.03 AS con_rate_1 FROM DUAL ) con
WHERE
  --dsf.dsf_filename = :FILENAME
  dsf.file_id BETWEEN 10000 AND 20180
  AND dr.file_id = dsf.file_id
  AND tr.rec_id = dr.rec_id
  AND d.detail_id = tr.detail_id
  AND pp.product_id = d.product_id
  AND tr.trx_date BETWEEN pp.prop_date_from AND pp.prop_date_to
  AND pr.par_id = pp.par_id
  AND acc.acc_id = tr.acc_id
  AND acc.cust_id = pc.cust_id
  AND acc.acc_retro_entitled = 'Y'
  AND tr.trx_date BETWEEN pc.pc_date_from AND pc.pc_date_to
  AND pd.par_id = pc.par_id  
  AND ccg.cust_id = pc.cust_id
  AND tr.trx_date BETWEEN ccg.ccg_date_from AND ccg.ccg_date_to
  AND cg.cg_id = ccg.cg_id )
ORDER BY dsr_data_20, dsr_data_39, dsr_data_08, TO_NUMBER(dsr_data_14)


UPDATE dsa_file dsf
  SET dsf_no_lines = (SELECT dsf.dsf_no_lines + COUNT(1) FROM dsa_record WHERE file_id = dsf.file_id),
      dsf_no_recs = (SELECT dsf.dsf_no_recs + COUNT(1) FROM dsa_record WHERE file_id = dsf.file_id)
WHERE file_id = 10300      
  


-- Funds which do not have their prices
SELECT DISTINCT
  pr.par_id AS cp_id,
  pr.par_number AS cp_number,
  pr.par_company_name AS cp_name,
  d.detail_id,
  d.det_isin_nr,
  pd.par_id AS dp_id,
  pd.par_number AS dp_number,
  pd.par_company_name AS dp_name,
  cg.cg_id AS dp_cg_id,
  cg.cg_description AS dp_cg_description
  -- p.cur_id,
  -- p.pri_date,
  -- p.pri_avg_price
FROM
  dsa_file dsf,
  dsa_record dr,
  trx tr,
  detail d,
  product_partner pp,
  partner pr,
  account acc,
  partner_customer pc,
  partner pd,
  customer_customergroup ccg,
  customergroup cg,
  prices p
WHERE
  --dsf.dsf_filename = :FILENAME
  dsf.file_id BETWEEN 10000 AND 20180
  AND dr.file_id = dsf.file_id
  AND tr.rec_id = dr.rec_id
  AND d.detail_id = tr.detail_id
  AND pp.product_id = d.product_id
  AND tr.trx_date BETWEEN pp.prop_date_from AND pp.prop_date_to
  AND pr.par_id = pp.par_id
  AND acc.acc_id = tr.acc_id
  AND acc.cust_id = pc.cust_id
  AND acc.acc_retro_entitled = 'Y'
  AND tr.trx_date BETWEEN pc.pc_date_from AND pc.pc_date_to
  AND pd.par_id = pc.par_id  
  AND ccg.cust_id = pc.cust_id
  AND tr.trx_date BETWEEN ccg.ccg_date_from AND ccg.ccg_date_to
  AND cg.cg_id = ccg.cg_id
  AND NOT EXISTS (SELECT 1 FROM prices WHERE detail_id = d.detail_id)
ORDER BY pr.par_number, d.det_isin_nr


INSERT INTO dsa_file (file_id, dsf_filename, dsf_timestamp, src_id, dsf_no_lines, dsf_no_recs)
SELECT
  seq_dsa_file.nextval, 'ALL CPs prices ' || TO_CHAR(SYSDATE, 'dd.mm.yyyy hh24:mi:ss') AS dsf_filename,
  SYSDATE AS dsf_timestamp, src_id, 1 AS dsf_no_lines, 0 AS dsf_no_recs
FROM dsa_file
WHERE file_id = (SELECT MAX(file_id) FROM dsa_file WHERE src_id = 261)

SELECT MAX(file_id) FROM dsa_file WHERE src_id = 261
-- 10302

INSERT INTO dsa_record ( file_id, src_id, dsr_verify, dsr_data_01,  dsr_data_02,  dsr_data_03,  dsr_data_04)
SELECT
  10302 AS file_id, 261 AS src_id, 'N' AS dsr_verify, dsr_data_01,  dsr_data_02,  dsr_data_03,  dsr_data_04
FROM (
SELECT DISTINCT
  dd.date_ AS dsr_data_01,  -- Date
  d.det_isin_nr AS dsr_data_02, -- Fund
  '1.5' AS dsr_data_03, -- Price
  'CHF' AS dsr_data_04 -- Currency
FROM
  dsa_file dsf,
  dsa_record dr,
  trx tr,
  detail d,
  product_partner pp,
  partner pr,
  account acc,
  partner_customer pc,
  partner pd,
  customer_customergroup ccg,
  customergroup cg,
  (
    SELECT '31.01.2017' AS date_ FROM DUAL UNION ALL
    SELECT '28.02.2017' AS date_ FROM DUAL UNION ALL
    SELECT '31.03.2017' AS date_ FROM DUAL UNION ALL
    SELECT '30.04.2017' AS date_ FROM DUAL UNION ALL
    SELECT '31.05.2017' AS date_ FROM DUAL UNION ALL
    SELECT '30.06.2017' AS date_ FROM DUAL UNION ALL
    SELECT '31.07.2017' AS date_ FROM DUAL UNION ALL
    SELECT '31.08.2017' AS date_ FROM DUAL UNION ALL
    SELECT '30.09.2017' AS date_ FROM DUAL UNION ALL
    SELECT '31.10.2017' AS date_ FROM DUAL UNION ALL
    SELECT '30.11.2017' AS date_ FROM DUAL UNION ALL
    SELECT '31.12.2017' AS date_ FROM DUAL
  ) dd
WHERE
  --dsf.dsf_filename = :FILENAME
  dsf.file_id BETWEEN 10000 AND 20180
  AND dr.file_id = dsf.file_id
  AND tr.rec_id = dr.rec_id
  AND d.detail_id = tr.detail_id
  AND pp.product_id = d.product_id
  AND tr.trx_date BETWEEN pp.prop_date_from AND pp.prop_date_to
  AND pr.par_id = pp.par_id
  AND acc.acc_id = tr.acc_id
  AND acc.cust_id = pc.cust_id
  AND acc.acc_retro_entitled = 'Y'
  AND tr.trx_date BETWEEN pc.pc_date_from AND pc.pc_date_to
  AND pd.par_id = pc.par_id  
  AND ccg.cust_id = pc.cust_id
  AND tr.trx_date BETWEEN ccg.ccg_date_from AND ccg.ccg_date_to
  AND cg.cg_id = ccg.cg_id
  AND NOT EXISTS (SELECT 1 FROM prices WHERE detail_id = d.detail_id)
)



UPDATE dsa_file dsf
  SET dsf_no_lines = (SELECT dsf.dsf_no_lines + COUNT(1) FROM dsa_record WHERE file_id = dsf.file_id),
      dsf_no_recs = (SELECT dsf.dsf_no_recs + COUNT(1) FROM dsa_record WHERE file_id = dsf.file_id)
WHERE file_id = 10302     
  

UPDATE model_partner mp
  SET pri_calculation_kind = 51
WHERE
  EXISTS (SELECT 1 FROM model WHERE mod_id = mp.mod_id AND category_id = 60101)
  AND pri_calculation_kind IS NULL
     
  
  
SELECT pri_calculation_kind FROM model_partner
  

-- Funds which do not have fund fees
SELECT DISTINCT
  pr.par_id AS cp_id,
  pr.par_number AS cp_number,
  pr.par_company_name AS cp_name,
  d.detail_id,
  d.det_isin_nr,
  pd.par_id AS dp_id,
  pd.par_number AS dp_number,
  pd.par_company_name AS dp_name,
  cg.cg_id AS dp_cg_id,
  cg.cg_description AS dp_cg_description,
  dtf.*
  -- p.cur_id,
  -- p.pri_date,
  -- p.pri_avg_price
FROM
  dsa_file dsf,
  dsa_record dr,
  trx tr,
  detail d,
  product_partner pp,
  partner pr,
  account acc,
  partner_customer pc,
  partner pd,
  customer_customergroup ccg,
  customergroup cg,
  detail_totalfee dtf
WHERE
  --dsf.dsf_filename = :FILENAME
  dsf.file_id BETWEEN 10000 AND 20180
  AND dr.file_id = dsf.file_id
  AND tr.rec_id = dr.rec_id
  AND d.detail_id = tr.detail_id
  AND pp.product_id = d.product_id
  AND tr.trx_date BETWEEN pp.prop_date_from AND pp.prop_date_to
  AND pr.par_id = pp.par_id
  AND acc.acc_id = tr.acc_id
  AND acc.cust_id = pc.cust_id
  AND acc.acc_retro_entitled = 'Y'
  AND tr.trx_date BETWEEN pc.pc_date_from AND pc.pc_date_to
  AND pd.par_id = pc.par_id  
  AND ccg.cust_id = pc.cust_id
  AND tr.trx_date BETWEEN ccg.ccg_date_from AND ccg.ccg_date_to
  AND cg.cg_id = ccg.cg_id
  AND dtf.detail_id = d.detail_id
ORDER BY pr.par_number, d.det_isin_nr


UPDATE detail_totalfee dtf
  SET dtf_date_from = TO_DATE('01012000', 'ddmmyyyy')
WHERE NOT EXISTS (SELECT 1 FROM detail_totalfee WHERE detail_id = dtf.detail_id AND feetype_id = 241 AND dtf_date_from < dtf.dtf_date_from)
  AND feetype_id = 241  

UPDATE partner
  SET use_pi_in_pt_creation_flag = 'N'
WHERE category_id IN (101, 103)


