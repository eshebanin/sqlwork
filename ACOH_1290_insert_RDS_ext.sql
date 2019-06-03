INSERT INTO retrodata_static(rds_id, mds_id, retro_id, VALUE_1, VALUE_2, VALUE_3, VALUE_4, VALUE_5, VALUE_6, VALUE_7, VALUE_8, VALUE_9, 
                                               VALUE_10, VALUE_11, VALUE_12, VALUE_13, VALUE_14, VALUE_15, VALUE_16, VALUE_17, VALUE_18, VALUE_19, 
                                               VALUE_20, VALUE_21, VALUE_22, VALUE_23)
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
  sq.val+ROW_NUMBER() OVER(ORDER BY pr.producer_id, pd.par_id, pr.parrec_calc_id, pr.parrec_pay_id, dsf.file_id) AS rds_id, 
  10000 AS mds_id,
  (SELECT MIN(retro_id) FROM retro WHERE status_id <> 23 AND retro_corrected = 'N') AS retro_id,
  TO_CHAR(q.qrt_ends, 'dd/mm/yyyy') AS "Reference date",  
  TO_CHAR(pr.producer_id) AS "CP ID",
  pr.producer_number AS "CP Number",
  pr.producer_name AS "CP Name",
  TO_CHAR(pd.par_id) AS "DP ID",
  pd.par_number AS "DP number",
  pd.par_company_name AS "DP name",
  TO_CHAR(pr.parrec_calc_id) AS "CP calculation ID",
  TO_CHAR(pr.parrec_calc_starts, 'dd/mm/yyyy') AS "CP calculation period from",
  TO_CHAR(pr.parrec_calc_ends, 'dd/mm/yyyy') AS "CP calculation period to",
  TO_CHAR(MAX(pr.parrec_calc_ts_start), 'dd/mm/yyyy hh24:mi:ss') AS "CP calculation started",
  TO_CHAR(MAX(pr.parrec_calc_ts_end), 'dd/mm/yyyy hh24:mi:ss') AS "CP calculation finished",
  pr.parrec_wf_status_id AS "CP calculation workflow ID",
  (SELECT status_designation FROM status WHERE status_id = pr.parrec_wf_status_id) AS "CP calculation workflow",
  pr.parrec_calc_desc AS "CP calculation desc",
  TO_CHAR(pr.parrec_pay_id) AS "CP payment ID",
  TO_CHAR(pr.parrec_pay_date, 'dd/mm/yyyy') AS "CP payment date",
  TO_CHAR(MAX(pr.parrec_pay_ts), 'dd/mm/yyyy hh24:mi:ss') AS "CP payment generated",
  pr.parrec_pay_wf_status_id AS "CP payment workflow ID",
  (SELECT status_designation FROM status WHERE status_id = pr.parrec_pay_wf_status_id) AS "CP payment workflow",
  TO_CHAR(dsf.file_id) AS "Position import file ID",
  dsf.dsf_filename AS "Position import file name",
  TO_CHAR(MAX(dsf.dsf_timestamp), 'dd/mm/yyyy hh24:mi:ss') AS "Position import file processed" 
FROM
  quarter q,
  seq sq,
  payrec pr,
  retro r,
  trx t,
  account acc,
  partner_customer pc,
  partner pd,
  dsa_record dr,
  dsa_file dsf
WHERE
  r.payment_task_id = pr.parrec_pay_id  
  AND r.status_id <> 23
  AND r.retro_corrected = 'N'
  AND t.detail_id = r.detail_id
  AND t.acc_id = r.acc_id
  AND t.trx_date BETWEEN q.qrt_starts AND q.qrt_ends
  AND acc.acc_id = t.acc_id
  AND pc.cust_id = acc.cust_id
  AND pc.pc_date_from <= q.qrt_ends
  AND pc.pc_date_to >= q.qrt_starts 
  AND pd.par_id = pc.par_id
  AND dr.rec_id = t.rec_id
  AND dsf.file_id = dr.file_id  
GROUP BY q.qrt_ends, sq.val, pr.producer_id, pr.producer_number, pr.producer_name, pd.par_id, pd.par_number, pd.par_company_name,
  pr.parrec_calc_id, pr.parrec_calc_starts, pr.parrec_calc_ends, pr.parrec_wf_status_id, pr.parrec_calc_desc,
  pr.parrec_pay_id, pr.parrec_pay_date, pr.parrec_pay_wf_status_id,
  dsf.file_id, dsf.dsf_filename
ORDER BY pr.producer_id, pd.par_id, pr.parrec_calc_id, pr.parrec_pay_id, dsf.file_id				
