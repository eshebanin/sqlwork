INSERT INTO retrodata_static(rds_id, mds_id, retro_id, VALUE_1, VALUE_2, VALUE_3, VALUE_4, VALUE_5, VALUE_6, VALUE_7, VALUE_8, VALUE_9, 
                                               VALUE_10, VALUE_11, VALUE_12, VALUE_13, VALUE_14, VALUE_15, VALUE_16, VALUE_17, VALUE_18, VALUE_19, 
                                               VALUE_20, VALUE_21, VALUE_22, VALUE_23, VALUE_24, VALUE_25, VALUE_26, VALUE_27, VALUE_28, VALUE_29) 
WITH 
  quarter AS (SELECT :QUARTER_STARTS AS qrt_starts, :QUARTER_ENDS AS qrt_ends FROM DUAL),
  -- quarter AS (SELECT 
  -- 				TRUNC(CONTEXT.GET_DATE_TO (CONTEXT.GET_C_CALCULATION_SUMMARY), 'q') AS qrt_starts,                 
  -- 				ADD_MONTHS(TRUNC(CONTEXT.GET_DATE_TO (CONTEXT.GET_C_CALCULATION_SUMMARY), 'q'),3) - 1 AS qrt_ends
  --              FROM DUAL
  --             WHERE ROWNUM > 0 -- LEAVE IT HERE!!! It will prevent Oracle to perform QUERY RE-WRITE, necessary for performance reasons
  --             )  
  seq AS (SELECT MAX(rds_id) AS val FROM retrodata_static),  
  parrec AS (SELECT par_id AS producer_id, par_number AS producer_number, par_company_name AS producer_name FROM partner WHERE category_id = 101),
  modelrec AS ( SELECT
                  p.producer_id,
				  p.producer_number,
				  p.producer_name,
                  m.mod_id,
                  m.mod_name,
                  m.wf_status_id AS model_wf_status_id,
                  (SELECT status_designation FROM status WHERE status_id = m.wf_status_id)  AS model_wf_status,	 
				  mp.mp_date_from AS model_from,
				  mp.mp_date_to AS model_to,
				  mpg.mpg_id,
				  mpg.pg_id,
				  mpg.cg_id,
				  mpg.mpg_date_from,
				  mpg.mpg_date_to				  ,
				  con.con_id,
				  con.con_range_1_min,
				  con.con_range_1_max,
				  con.con_rate_1,
				  con.rec_id
				FROM  
				  quarter q,
				  parrec p,
				  model_partner mp,
				  model m,
				  model_productgroup mpg,
				  condition con
				WHERE 
                  mp.par_id = p.producer_id 
                  AND mp.mp_date_from <= q.qrt_ends
                  AND mp.mp_date_to >= q.qrt_starts
                  AND m.mod_id = mp.mod_id
				  AND m.category_id = 60101
				  AND m.lifecycle_status_id = 950
                  AND mpg.mpg_id = m.mod_id				  
                  AND mpg.mpg_date_from <= q.qrt_ends
                  AND mpg.mpg_date_to >= q.qrt_starts
                  AND con.mpg_id = mpg.mpg_id 
                  AND con.con_date_from <= q.qrt_ends
                  AND con.con_date_to >= q.qrt_starts
				  ),
  calcrec AS ( SELECT
                 p.producer_id,
				 p.producer_number,
				 p.producer_name,
				 tcalc.task_id AS parrec_calc_id,
				 tcalc.task_para_date_01 AS parrec_calc_starts,
				 tcalc.task_para_date_02 AS parrec_calc_ends,
				 tcalc.task_start_timestamp AS parrec_calc_ts_start,
				 tcalc.task_start_timestamp AS parrec_calc_ts_end,
				 tcalc.wf_status_id AS parrec_wf_status_id,
				 tcalc.task_description AS parrec_calc_desc
			  FROM
                quarter q,
                parrec p,
                selection_detail spar,
                selection_detail sc,
                task tcalc
              WHERE
                spar.object_id = p.producer_id
                AND spar.seldet_type = 'PAR_ID'
                AND sc.sel_id = spar.sel_id
                AND sc.seldet_type = 'CATEGORY_ID'
				AND sc.object_id = 60101
				AND tcalc.sel_id = sc.sel_id
				AND tcalc.tasktype_id = 531
				AND tcalc.task_para_date_01 BETWEEN q.qrt_starts AND q.qrt_ends 
				AND tcalc.task_para_date_02 BETWEEN q.qrt_starts AND q.qrt_ends ),
  payrec AS (  SELECT
  calc.producer_id,
				 calc.producer_number,
				 calc.producer_name,
				 calc.parrec_calc_id,
				 calc.parrec_calc_starts,
				 calc.parrec_calc_ends,
				 calc.parrec_calc_ts_start,
				 calc.parrec_calc_ts_end,
				 calc.parrec_wf_status_id,
				 calc.parrec_calc_desc,
				 tpay.task_id AS parrec_pay_id,
				 tpay.task_para_date_02 AS parrec_pay_date,
				 tpay.task_start_timestamp AS parrec_pay_ts,
				 tpay.wf_status_id AS parrec_pay_wf_status_id				 
			  FROM
                quarter q,
                calcrec calc,
				task tpay
              WHERE
                tpay.origin_task_id = calc.parrec_calc_id
				AND tpay.tasktype_id = 530
				AND tpay.task_para_date_02 BETWEEN q.qrt_starts AND q.qrt_ends )
SELECT
  sq.val+ROW_NUMBER() OVER(ORDER BY pr.producer_id, mr.mod_id, pd.par_id, pr.parrec_calc_id, pr.parrec_pay_id, dsf.file_id) AS rds_id, 
  9000 AS mds_id,
  (SELECT MIN(retro_id) FROM retro WHERE status_id <> 23 AND retro_corrected = 'N') AS retro_id,
  TO_CHAR(q.qrt_ends, 'dd/mm/yyyy') AS "Reference date",
  TO_CHAR(pr.producer_id) AS "CP ID",
  pr.producer_number AS "CP Number",
  pr.producer_name AS "CP Name",
  TO_CHAR(pd.par_id) AS "DP ID",
  pd.par_number AS "DP number",
  pd.par_company_name AS "DP name",
  TO_CHAR(mr.mod_id) AS "CP model ID",
  mr.mod_name AS "CP model name",
  TO_CHAR(mr.model_wf_status_id) AS "CP model workflow ID",
  mr.model_wf_status AS "CP model workflow",	 
  TO_CHAR(mr.model_from, 'dd/mm/yyyy') AS "CP model from",
  TO_CHAR(mr.model_to, 'dd/mm/yyyy') AS "CP model to",   
  TO_CHAR(pr.parrec_calc_id) AS "CP calculation ID",
  TO_CHAR(pr.parrec_calc_starts, 'dd/mm/yyyy') AS "CP calculation period from",
  TO_CHAR(pr.parrec_calc_ends, 'dd/mm/yyyy') AS "CP calculation period to",
  TO_CHAR(MAX(pr.parrec_calc_ts_start), 'dd/mm/yyyy hh24:mi:ss') AS "CP calculation started",
  TO_CHAR(MAX(pr.parrec_calc_ts_end), 'dd/mm/yyyy hh24:mi:ss') AS "CP calculation finished",
  TO_CHAR(pr.parrec_wf_status_id) AS "CP calculation workflow ID",
  (SELECT status_designation FROM status WHERE status_id = pr.parrec_wf_status_id) AS "CP calculation workflow",
  pr.parrec_calc_desc AS "CP calculation desc",
  TO_CHAR(pr.parrec_pay_id) AS "CP payment ID",
  TO_CHAR(pr.parrec_pay_date, 'dd/mm/yyyy') AS "CP payment date",
  TO_CHAR(MAX(pr.parrec_pay_ts), 'dd/mm/yyyy hh24:mi:ss') AS "CP payment generated",
  TO_CHAR(pr.parrec_pay_wf_status_id) AS "CP payment workflow ID",
  (SELECT status_designation FROM status WHERE status_id = pr.parrec_pay_wf_status_id)  AS "CP payment workflow",
  TO_CHAR(dsf.file_id) AS "ACT import file ID",
  SUBSTR(dsf.dsf_filename,1,99) AS "ACT import file name",
  TO_CHAR(MAX(dsf.dsf_timestamp), 'dd/mm/yyyy hh24:mi:ss') AS "ACT import file processed"
FROM
  quarter q,
  seq sq,
  payrec pr,
  modelrec mr,
  customer_customergroup ccg,
  partner_customer pc,
  partner pd,
  dsa_record dr,
  dsa_file dsf
WHERE
  pr.producer_id = mr.producer_id 
  AND ccg.cg_id = mr.cg_id
  AND ccg.ccg_date_from <= q.qrt_ends
  AND ccg.ccg_date_to >= q.qrt_starts 
  AND pc.cust_id = ccg.cust_id
  AND pc.pc_date_from <= q.qrt_ends
  AND pc.pc_date_to >= q.qrt_starts 
  AND pd.par_id = pc.par_id
  AND dr.rec_id = mr.rec_id
  AND dsf.file_id = dr.file_id  
GROUP BY sq.val, q.qrt_ends, pr.producer_id, pr.producer_number, pr.producer_name, pd.par_id, pd.par_number, pd.par_company_name,
  mr.mod_id, mr.mod_name, mr.model_wf_status_id, mr.model_wf_status, mr.model_from, mr.model_to,   
  pr.parrec_calc_id, pr.parrec_calc_starts, pr.parrec_calc_ends, pr.parrec_wf_status_id, pr.parrec_calc_desc,
  pr.parrec_pay_id, pr.parrec_pay_date, pr.parrec_pay_wf_status_id,
  dsf.file_id, dsf.dsf_filename
ORDER BY pr.producer_id, mr.mod_id, pd.par_id, pr.parrec_calc_id, pr.parrec_pay_id, dsf.file_id	

