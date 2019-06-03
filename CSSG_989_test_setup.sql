SELECT
  pg.pg_id,
  pg.pg_description,
  md.metadata_id,
  md.met_tablename,
  md.met_category,
  md.met_description,
  md.met_type,
  pgd.pgda_date_from,
  pgd.pgda_date_to, 
  pgd.value
FROM 
  productgroup pg,
  productgroupdata pgd,
  metadata md
WHERE
  pg.pg_id BETWEEN 11 AND 29
  AND pgd.pg_id(+) = pg.pg_id
  AND md.metadata_id(+) = pgd.metadata_id  
ORDER BY pg.pg_id, pgd.pgda_id  




SELECT 
  for_id, for_keyname, for_expression, for_desc, client_id, for_method 
FROM formula
ORDER BY 1 


SELECT 
  p.par_id,
  p.par_number,
  p.par_company_name,
  p.wf_status_id,
  (SELECT status_designation FROM status WHERE status_id = p.wf_status_id) AS wf_status,
  p.periodicity_id, 
  (SELECT status_designation FROM status WHERE status_id = p.periodicity_id) AS periodicity,
  p.par_pay_periodicity_id,
  (SELECT status_designation FROM status WHERE status_id = p.par_pay_periodicity_id) AS pay_periodicity  
FROM partner p
WHERE p.objecttype = 101
ORDER BY par_id



SELECT * FROM partner


SELECT * FROM user_tab_columns
WHERE  
  table_name = 'MODEL' 
  AND column_name LIKE '%PERIOD%'

SELECT 
  p.par_id,
  p.par_number,
  p.par_company_name,
  m.mod_id,
  m.mod_name,
  m.wf_status_id,
  (SELECT status_designation FROM status WHERE status_id = m.wf_status_id) AS mod_wf_status,
  m.periodicity_id, 
  (SELECT status_designation FROM status WHERE status_id = m.periodicity_id) AS mod_periodicity,
  m.mod_pay_periodicity_id,
  (SELECT status_designation FROM status WHERE status_id = m.mod_pay_periodicity_id) AS mod_pay_periodicity  
FROM 
 partner p,
 model_partner mp,
 model m
WHERE 
  p.objecttype = 101
  AND mp.par_id = p.par_id
  AND m.mod_id = mp.mod_id
ORDER BY p.par_id, m.mod_id


SELECT * FROM version_history




SELECT
  'Existing Rateset' AS qualify,
  p.par_id,
  p.par_number,
  p.par_company_name,
  m.mod_id,
  m.mod_name,
  m.wf_status_id,
  (SELECT status_designation FROM status WHERE status_id = m.wf_status_id) AS mod_wf_status,
  m.periodicity_id, 
  (SELECT status_designation FROM status WHERE status_id = m.periodicity_id) AS mod_periodicity,
  m.mod_pay_periodicity_id,
  (SELECT status_designation FROM status WHERE status_id = m.mod_pay_periodicity_id) AS mod_pay_periodicity  
FROM 
 partner p,
 model_partner mp,
 model m
WHERE 
  p.par_number = 'AUQ18'
  AND p.wf_status_id = 422
  AND mp.par_id = p.par_id
  AND m.mod_id = mp.mod_id
UNION ALL
SELECT
  'New Rateset' AS qualify,
  p.par_id,
  p.par_number,
  p.par_company_name,
  m.mod_id,
  m.mod_name,
  m.wf_status_id,
  (SELECT status_designation FROM status WHERE status_id = m.wf_status_id) AS mod_wf_status,
  m.periodicity_id, 
  (SELECT status_designation FROM status WHERE status_id = m.periodicity_id) AS mod_periodicity,
  m.mod_pay_periodicity_id,
  (SELECT status_designation FROM status WHERE status_id = m.mod_pay_periodicity_id) AS mod_pay_periodicity  
FROM 
 partner p,
 model_partner mp,
 model m
WHERE 
  p.par_number = 'AUQ18'
  AND p.wf_status_id = 426
  AND mp.par_id = p.par_id
  AND m.mod_id = mp.mod_id
ORDER BY 1, 2, 5



SELECT
  'Existing Rateset' AS qualify,
  p.par_id,
  p.par_number,
  p.par_company_name,
  m.mod_id,
  m.mod_name,
  m.wf_status_id,
  (SELECT status_designation FROM status WHERE status_id = m.wf_status_id) AS mod_wf_status,
  m.periodicity_id, 
  (SELECT status_designation FROM status WHERE status_id = m.periodicity_id) AS mod_periodicity,
  m.mod_pay_periodicity_id,
  (SELECT status_designation FROM status WHERE status_id = m.mod_pay_periodicity_id) AS mod_pay_periodicity,
  mpg.mpg_id,
  mpg.pg_id,
  (SELECT pg_description FROM productgroup WHERE pg_id = mpg.pg_id) AS pg_description,
  mpg.for_id,
  (SELECT for_keyname FROM formula WHERE for_id = mpg.for_id) AS for_keyname, 
  mpg.rate_det_vol_id,
  (SELECT status_designation FROM status WHERE status_id = mpg.rate_det_vol_id) AS rate_det_vol_name  
FROM 
 partner p,
 model_partner mp,
 model m,
 model_productgroup mpg
WHERE 
  p.par_number = 'AUQ18'
  AND p.wf_status_id = 422
  AND mp.par_id = p.par_id
  AND m.mod_id = mp.mod_id
  AND mpg.mod_id = m.mod_id
UNION ALL
SELECT
  'New Rateset' AS qualify,
  p.par_id,
  p.par_number,
  p.par_company_name,
  m.mod_id,
  m.mod_name,
  m.wf_status_id,
  (SELECT status_designation FROM status WHERE status_id = m.wf_status_id) AS mod_wf_status,
  m.periodicity_id, 
  (SELECT status_designation FROM status WHERE status_id = m.periodicity_id) AS mod_periodicity,
  m.mod_pay_periodicity_id,
  (SELECT status_designation FROM status WHERE status_id = m.mod_pay_periodicity_id) AS mod_pay_periodicity,
  mpg.mpg_id,
  mpg.pg_id,
  (SELECT pg_description FROM productgroup WHERE pg_id = mpg.pg_id) AS pg_description,  
  mpg.for_id,
  (SELECT for_keyname FROM formula WHERE for_id = mpg.for_id) AS for_keyname,
  mpg.rate_det_vol_id,
  (SELECT status_designation FROM status WHERE status_id = mpg.rate_det_vol_id) AS rate_det_vol_name  
FROM 
 partner p,
 model_partner mp,
 model m,
 model_productgroup mpg 
WHERE 
  p.par_number = 'AUQ18'
  AND p.wf_status_id = 426
  AND mp.par_id = p.par_id
  AND m.mod_id = mp.mod_id
  AND mpg.mod_id = m.mod_id  
ORDER BY 1, 2, 5, 14





SELECT * FROM dsa_source


WITH 
  staging AS ( SELECT
                 fl.file_id, fl.src_id, fl.dsf_filename, fl.dsf_timestamp,
                 dr.rec_id
               FROM 
                 dsa_file fl,
                 dsa_record dr  
               WHERE
                 fl.src_id IN (11, 51)
                 AND fl.dsf_timestamp >= TRUNC(SYSDATE)-10
                 AND dr.file_id = fl.file_id ),
  transactions AS ( SELECT
                      t.*
                    FROM
                      staging st,
                      trx t
                    WHERE
                      t.rec_id = st.rec_id ),
  cif AS ( SELECT
             c.cust_id, c.cust_number, t.trx_id, t.trx_date
           FROM 
             transactions t,
             account acc,
             customer c
           WHERE
              acc.acc_id = t.acc_id
              AND c.cust_id = acc.cust_id ),
  rateset AS ( SELECT
                 p.par_id, p.par_number, c.cust_id, c.cust_number, c.trx_id, c.trx_date
               FROM                 
                 cif c,
                 partner_customer pc,
                 partner p
               WHERE
                  c.cust_id = pc.cust_id
                  AND pc.par_id = p.par_id
                  AND c.trx_date BETWEEN pc.pc_date_from AND pc.pc_date_to )                                        
SELECT
  tcalc.task_id,
  tcalc.task_para_date_01,
  tcalc.task_para_date_02,
  tcalc.task_description,
  tcalc.wf_status_id,
  (SELECT status_designation FROM status WHERE status_id = tcalc.wf_status_id) AS wf_status_name
FROM      
  rateset r,
  selection_detail sd,   
  task tcalc
WHERE
  sd.object_id = r.par_id AND
  sd.seldet_type = 'PAR_ID' AND
  tcalc.sel_id = sd.sel_id AND
  tcalc.tasktype_id = 531                                       
                 
                 
SELECT * FROM dsa_file
                  
				  
				  INSERT INTO dsa_record (src_id, status_id, file_id, dsr_date, dsr_user, dsr_verify,
                        dsr_data_01, dsr_data_02, dsr_data_03, dsr_data_04, dsr_data_05,
                        dsr_data_06, dsr_data_07, dsr_data_08, dsr_data_09, dsr_data_10,
                        dsr_data_11, dsr_data_12, dsr_data_13, dsr_data_14, dsr_data_15,
                        dsr_data_16, dsr_data_17, dsr_data_18, dsr_data_19, dsr_data_20 )
SELECT
  src_id, 204 AS status_id, 10101 AS file_id, SYSDATE AS dsr_date, dsr_user, dsr_verify,
  SUBSTR(dsr_data_01, 1, 3) || '2' || SUBSTR(dsr_data_01, 4) AS dsr_data_01, dsr_data_02, dsr_data_03, dsr_data_04, dsr_data_05,
  dsr_data_06, dsr_data_07, TO_CHAR(ADD_MONTHS(TO_DATE(dsr_data_08, 'yyyymmdd'), 24), 'yyyymmdd') AS dsr_data_08, dsr_data_09, DECODE(dsr_data_01, 'AUQ18', 'ZZZ', dsr_data_10) AS dsr_data_10,
  dsr_data_11, dsr_data_12, dsr_data_13, dsr_data_14, dsr_data_15,
  DECODE(dsr_data_01, 'AUQ19', '9999999', dsr_data_16) AS dsr_data_16, dsr_data_17, dsr_data_18, TO_CHAR(ADD_MONTHS(TO_DATE(dsr_data_19, 'yyyymmdd'), 24), 'yyyymmdd') AS dsr_data_19, dsr_data_20   
FROM dsa_record
WHERE src_id = 106
  AND dsr_data_01 IN ('AUQ18', 'AUQ19', 'AUQ20')
  AND file_id = 10004
 
INSERT INTO dsa_file(dsf_filename, dsf_timestamp, src_id, client_id)
SELECT
  dsf_filename || '_LOOKUP' AS dsf_filename,
  SYSDATE AS dsf_timestamp,
  src_id,
  client_id
FROM dsa_file
WHERE file_id = 10004  

SELECT MAX(file_id) FROM dsa_file WHERE src_id = 106


UPDATE dsa_file f
  SET (dsf_no_lines, dsf_no_recs) = (SELECT COUNT(1) + 1, COUNT(1) FROM dsa_record WHERE file_id = f.file_id)                            
WHERE file_id = 10101




SELECT
  tpay.task_id,
  p.par_id,
  CALC_UTL.PERIOD_TO_CHAR (tpay.task_para_date_01, tpay.task_para_date_02) AS period,
  tpay.task_para_date_01 AS date_from,
  tpay.task_para_date_02 AS date_to,  
  pi.pi_accountnumber AS accountnumber,
  rp.cur_id,
  r.par_cur_id,
  SUM(r.retro_par_cur_amount) AS total_retro_amount,
  rp.rp_amount_total AS payment_amount
FROM 
  task tpay,
  retro_payment rp,
  payinstr pi,
  retro r,
  partner p
WHERE
  tpay.task_id = :PAYMENT_ID 
  AND rp.payment_task_id(+) = tpay.task_id
  AND pi.pi_id(+) = rp.pi_id
  AND r.payment_task_id(+) = tpay.task_id  
  AND r.status_id(+) <> 23
  AND r.retro_corrected(+) = 'N'
  AND p.par_id(+) = r.par_id
GROUP BY tpay.task_id, p.par_id, tpay.task_para_date_01, tpay.task_para_date_02,  
         rp.cur_id, rp.rp_amount_total, pi.pi_accountnumber, r.par_cur_id 
		 
		 
SELECT MIN(file_id) FROM dsa_file WHERE src_id = 106

SELECT
  src_id, status_id, file_id, dsr_date, dsr_user, dsr_verify,
  dsr_data_01, dsr_data_02, dsr_data_03, dsr_data_04, dsr_data_05,
  dsr_data_06, dsr_data_07, dsr_data_08, dsr_data_09, dsr_data_10,
  dsr_data_11, dsr_data_12, dsr_data_13, dsr_data_14, dsr_data_15,
  dsr_data_16, dsr_data_17, dsr_data_18, dsr_data_19, dsr_data_20   
FROM dsa_record
WHERE src_id = 106
  AND dsr_data_01 IN ('AUQ18', 'AUQ19', 'AUQ20')
  AND file_id = 10004
  
  
  
UPDATE dsa_file f
  SET (dsf_no_lines, dsf_no_recs) = (SELECT COUNT(1) + 1, COUNT(1) FROM dsa_record WHERE file_id = f.file_id)                            
WHERE file_id = 10100  		 


SELECT * FROM dsa_source WHERE src_id = 106
-- 20 attributes

SELECT
  src_id, 204 AS status_id, file_id, SYSDATE AS dsr_date, dsr_user, dsr_verify,
  dsr_data_01, dsr_data_02, dsr_data_03, dsr_data_04, dsr_data_05,
  dsr_data_06, dsr_data_07, dsr_data_08, dsr_data_09, dsr_data_10,
  dsr_data_11, dsr_data_12, dsr_data_13, dsr_data_14, dsr_data_15,
  dsr_data_16, dsr_data_17, dsr_data_18, dsr_data_19, dsr_data_20   
FROM dsa_record
WHERE src_id = 106
  AND dsr_data_01 = 'AUQ20'
  AND file_id = 
  
SELECT
  src_id, 204 AS status_id, file_id, SYSDATE AS dsr_date, dsr_user, dsr_verify,
  dsr_data_01, dsr_data_02, dsr_data_03, dsr_data_04, dsr_data_05,
  dsr_data_06, dsr_data_07, TO_CHAR(ADD_MONTHS(TO_DATE(dsr_data_08, 'yyyymmdd'), 24), 'yyyymmdd') AS dsr_data_08, dsr_data_09, 'USD' AS dsr_data_10,
  dsr_data_11, dsr_data_12, dsr_data_13, dsr_data_14, dsr_data_15,
  dsr_data_16, dsr_data_17, dsr_data_18, TO_CHAR(ADD_MONTHS(TO_DATE(dsr_data_19, 'yyyymmdd'), 24), 'yyyymmdd') AS dsr_data_19, dsr_data_20   
FROM dsa_record
WHERE src_id = 106
  AND dsr_data_01 = 'AUQ20'
  AND file_id = 10004
 
SELECT * FROM dsa_file WHERE file_id = 10004
-- dsf_no_lines, dsf_no_recs

SELECT * FROM dsa_record WHERE file_id = 10100
  
INSERT INTO dsa_file(dsf_filename, dsf_timestamp, src_id, client_id)
SELECT
  dsf_filename || '_EXTENSION' AS dsf_filename,
  SYSDATE AS dsf_timestamp,
  src_id,
  client_id
FROM dsa_file
WHERE file_id = 10004  


SELECT MAX(file_id) FROM dsa_file WHERE src_id = 106
-- 10100

INSERT INTO dsa_record (src_id, status_id, file_id, dsr_date, dsr_user, dsr_verify,
                        dsr_data_01, dsr_data_02, dsr_data_03, dsr_data_04, dsr_data_05,
                        dsr_data_06, dsr_data_07, dsr_data_08, dsr_data_09, dsr_data_10,
                        dsr_data_11, dsr_data_12, dsr_data_13, dsr_data_14, dsr_data_15,
                        dsr_data_16, dsr_data_17, dsr_data_18, dsr_data_19, dsr_data_20 )
SELECT
  src_id, 204 AS status_id, 10100 AS file_id, SYSDATE AS dsr_date, dsr_user, dsr_verify,
  dsr_data_01, dsr_data_02, dsr_data_03, dsr_data_04, dsr_data_05,
  dsr_data_06, dsr_data_07, TO_CHAR(ADD_MONTHS(TO_DATE(dsr_data_08, 'yyyymmdd'), 24), 'yyyymmdd') AS dsr_data_08, dsr_data_09, 'USD' AS dsr_data_10,
  dsr_data_11, dsr_data_12, dsr_data_13, dsr_data_14, dsr_data_15,
  dsr_data_16, dsr_data_17, dsr_data_18, TO_CHAR(ADD_MONTHS(TO_DATE(dsr_data_19, 'yyyymmdd'), 24), 'yyyymmdd') AS dsr_data_19, dsr_data_20   
FROM dsa_record
WHERE src_id = 106
  AND dsr_data_01 = 'AUQ20'
  AND file_id = 10004

UPDATE dsa_file f
  SET (dsf_no_lines, dsf_no_recs) = (SELECT COUNT(1) + 1, COUNT(1) FROM dsa_record WHERE file_id = f.file_id)                            
WHERE file_id = 10100

select * FROM status WHERE status_id BETWEEN 201 AND 204

SELECT
  *
FROM dsa_record
WHERE src_id = 106


-- Rateset = 'AUQ18'
1. Collect info on existing PI and PIRs
SELECT
  p.par_id, p.objecttype, p.par_number, p.par_company_name,
  pir.pir_id, pir.pir_prio, pir.pir_date_from, pir.pir_date_to, pir.i_detail_id,
  pi.pi_id, pi.pi_nr, pi.pi_name, pi.cur_id, pi.pi_accountholder, pi.pi_accountnumber
FROM
  partner p,
  payinstr_rule pir,
  payinstr pi
WHERE
  p.par_number = 'AUQ18'
  AND pir.i_par_id = p.par_id
  AND pi.pi_id = pir.o_pi_id

2. Delete PIRs 
DELETE FROM payinstr_rule WHERE i_par_id IN (SELECT par_id FROM partner WHERE par_number = 'AUQ18' AND wf_status_id = 422)

3. Delete PIs
DELETE FROM payinstr pi WHERE NOT EXISTS (SELECT 1 FROM payinstr_rule WHERE o_pi_id = pi.pi_id)

-- Rateset 'AUQ19'
1. Collect info on existing PI and PIRs
SELECT
  p.par_id, p.objecttype, p.par_number, p.par_company_name,
  pir.pir_id, pir.pir_prio, pir.pir_date_from, pir.pir_date_to, pir.i_detail_id,
  pi.pi_id, pi.pi_nr, pi.pi_name, pi.cur_id, pi.pi_accountholder, pi.pi_accountnumber
FROM
  partner p,
  payinstr_rule pir,
  payinstr pi
WHERE
  p.par_number = 'AUQ19'
  AND pir.i_par_id = p.par_id
  AND pi.pi_id = pir.o_pi_id

2. Delete NNA-related PIR
DELETE FROM payinstr_rule WHERE i_par_id IN (SELECT par_id FROM partner WHERE par_number = 'AUQ19' AND wf_status_id = 422) AND i_detail_id IS NOT NULL

3. Delete PI associated with NNA PIR
DELETE FROM payinstr pi WHERE NOT EXISTS (SELECT 1 FROM payinstr_rule WHERE o_pi_id = pi.pi_id)

-- Rateset 'AUQ20'

1. Quick check of specification of *106 - EAM* import interface

2. Registration of new *106 - EAM* import file on the basis of initial one
INSERT INTO dsa_file(dsf_filename, dsf_timestamp, src_id, client_id)
SELECT
  dsf_filename || '_EXTENSION' AS dsf_filename,
  SYSDATE AS dsf_timestamp,
  src_id,
  client_id
FROM dsa_file
WHERE file_id = 10004  

-- ID of newly created import file
SELECT MAX(file_id) FROM dsa_file WHERE src_id = 106
-- 10100

3. Registration of import record (Rateset - 'AUQ20') with new payment currency USD on the basis of initial import record from initial import file
INSERT INTO dsa_record (src_id, status_id, file_id, dsr_date, dsr_user, dsr_verify,
                        dsr_data_01, dsr_data_02, dsr_data_03, dsr_data_04, dsr_data_05,
                        dsr_data_06, dsr_data_07, dsr_data_08, dsr_data_09, dsr_data_10,
                        dsr_data_11, dsr_data_12, dsr_data_13, dsr_data_14, dsr_data_15,
                        dsr_data_16, dsr_data_17, dsr_data_18, dsr_data_19, dsr_data_20 )
SELECT
  src_id, 204 AS status_id, 10100 AS file_id, SYSDATE AS dsr_date, dsr_user, dsr_verify,
  dsr_data_01, dsr_data_02, dsr_data_03, dsr_data_04, dsr_data_05,
  dsr_data_06, dsr_data_07, TO_CHAR(ADD_MONTHS(TO_DATE(dsr_data_08, 'yyyymmdd'), 24), 'yyyymmdd') AS dsr_data_08, dsr_data_09, 'USD' AS dsr_data_10,
  dsr_data_11, dsr_data_12, dsr_data_13, dsr_data_14, dsr_data_15,
  dsr_data_16, dsr_data_17, dsr_data_18, TO_CHAR(ADD_MONTHS(TO_DATE(dsr_data_19, 'yyyymmdd'), 24), 'yyyymmdd') AS dsr_data_19, dsr_data_20   
FROM dsa_record
WHERE src_id = 106
  AND dsr_data_01 = 'AUQ20'
  AND file_id = 10004

-- Rateset 'AU7000000'
1. Collect info on existing PI and PIRs
SELECT
  p.par_id, p.objecttype, p.par_number, p.par_company_name,
  pir.pir_id, pir.pir_prio, pir.pir_date_from, pir.pir_date_to, pir.i_detail_id,
  pi.pi_id, pi.pi_nr, pi.pi_name, pi.cur_id, pi.pi_accountholder, pi.pi_accountnumber
FROM
  partner p,
  payinstr_rule pir,
  payinstr pi
WHERE
  p.par_number = 'AU7000000'
  AND pir.i_par_id = p.par_id
  AND pi.pi_id = pir.o_pi_id




SELECT * FROM serverfunction
ORDER BY 1 DESC



SELECT proto_id, username, client_id, pro_message, pro_date, task_id, pro_run_nr FROM protocol



SELECT * FROM dsa_source WHERE src_id = 106
-- 20 attributes

SELECT
  src_id, 204 AS status_id, file_id, SYSDATE AS dsr_date, dsr_user, dsr_verify,
  dsr_data_01, dsr_data_02, dsr_data_03, dsr_data_04, dsr_data_05,
  dsr_data_06, dsr_data_07, dsr_data_08, dsr_data_09, dsr_data_10,
  dsr_data_11, dsr_data_12, dsr_data_13, dsr_data_14, dsr_data_15,
  dsr_data_16, dsr_data_17, dsr_data_18, dsr_data_19, dsr_data_20   
FROM dsa_record
WHERE src_id = 106
  AND dsr_data_01 = 'AUQ20'
  AND file_id = 
  
SELECT
  src_id, 204 AS status_id, file_id, SYSDATE AS dsr_date, dsr_user, dsr_verify,
  dsr_data_01, dsr_data_02, dsr_data_03, dsr_data_04, dsr_data_05,
  dsr_data_06, dsr_data_07, TO_CHAR(ADD_MONTHS(TO_DATE(dsr_data_08, 'yyyymmdd'), 24), 'yyyymmdd') AS dsr_data_08, dsr_data_09, 'USD' AS dsr_data_10,
  dsr_data_11, dsr_data_12, dsr_data_13, dsr_data_14, dsr_data_15,
  dsr_data_16, dsr_data_17, dsr_data_18, TO_CHAR(ADD_MONTHS(TO_DATE(dsr_data_19, 'yyyymmdd'), 24), 'yyyymmdd') AS dsr_data_19, dsr_data_20   
FROM dsa_record
WHERE src_id = 106
  AND dsr_data_01 = 'AUQ20'
  AND file_id = 10004
 
SELECT * FROM dsa_file WHERE file_id = 10004
-- dsf_no_lines, dsf_no_recs

SELECT * FROM dsa_record WHERE file_id = 10100
  
INSERT INTO dsa_file(dsf_filename, dsf_timestamp, src_id, client_id)
SELECT
  dsf_filename || '_EXTENSION' AS dsf_filename,
  SYSDATE AS dsf_timestamp,
  src_id,
  client_id
FROM dsa_file
WHERE file_id = 10004  


SELECT MAX(file_id) FROM dsa_file WHERE src_id = 106
-- 10100

INSERT INTO dsa_record (src_id, status_id, file_id, dsr_date, dsr_user, dsr_verify,
                        dsr_data_01, dsr_data_02, dsr_data_03, dsr_data_04, dsr_data_05,
                        dsr_data_06, dsr_data_07, dsr_data_08, dsr_data_09, dsr_data_10,
                        dsr_data_11, dsr_data_12, dsr_data_13, dsr_data_14, dsr_data_15,
                        dsr_data_16, dsr_data_17, dsr_data_18, dsr_data_19, dsr_data_20 )
SELECT
  src_id, 204 AS status_id, 10100 AS file_id, SYSDATE AS dsr_date, dsr_user, dsr_verify,
  dsr_data_01, dsr_data_02, dsr_data_03, dsr_data_04, dsr_data_05,
  dsr_data_06, dsr_data_07, TO_CHAR(ADD_MONTHS(TO_DATE(dsr_data_08, 'yyyymmdd'), 24), 'yyyymmdd') AS dsr_data_08, dsr_data_09, 'USD' AS dsr_data_10,
  dsr_data_11, dsr_data_12, dsr_data_13, dsr_data_14, dsr_data_15,
  dsr_data_16, dsr_data_17, dsr_data_18, TO_CHAR(ADD_MONTHS(TO_DATE(dsr_data_19, 'yyyymmdd'), 24), 'yyyymmdd') AS dsr_data_19, dsr_data_20   
FROM dsa_record
WHERE src_id = 106
  AND dsr_data_01 = 'AUQ20'
  AND file_id = 10004

UPDATE dsa_file f
  SET (dsf_no_lines, dsf_no_recs) = (SELECT COUNT(1) + 1, COUNT(1) FROM dsa_record WHERE file_id = f.file_id)                            
WHERE file_id = 10100

select * FROM status WHERE status_id BETWEEN 201 AND 204

SELECT
  *
FROM dsa_record
WHERE src_id = 106

