-- Adjusting condition tiers of multi-tiered TF agreements
UPDATE condition
 SET con_range_1_min = con_range_1_min / 1000,
     con_range_1_max = con_range_1_max / 1000
WHERE con_id IN (     
SELECT 
  con_id
FROM   
( SELECT
  m.mod_id,
  m.mod_name,
  mpg.mpg_date_from,
  mpg.mpg_date_to,
  con.con_id,
  con.con_range_1_min,
  con.con_range_1_max,
  con.con_rate_1,
  COUNT(con.con_id) OVER (PARTITION BY mpg.mpg_id) AS conditions_cnt
FROM 
  model m,
  model_productgroup mpg,
  condition con
WHERE
  m.category_id = 60104
  AND mpg.mod_id = m.mod_id
  AND TRUNC(SYSDATE) BETWEEN mpg.mpg_date_from AND mpg.mpg_date_to
  AND con.mpg_id = mpg.mpg_id
  AND TRUNC(SYSDATE) BETWEEN con.con_date_from AND con.con_date_to  
ORDER BY m.mod_id, mpg.mpg_id, con.con_id )  
WHERE conditions_cnt >= 2)



SELECT
  t.task_id AS pay_task_id,
  t.task_para_date_02 AS pay_task_date,
  t.task_description AS pay_task_description,
  m.mod_id,
  m.mod_name,
  MAX(r.rate_det_volume) AS rdv_on_model,
  SUM(r.rate_calc_volume) AS total_calc_volume_model  
FROM  
  task t,
  retro r,
  model m
WHERE
  t.tasktype_id = 530 
  AND t.task_para_date_02 BETWEEN TO_DATE('01012016', 'ddmmyyyy') AND TO_DATE('31122020', 'ddmmyyyy')  
  AND r.payment_task_id = t.task_id
  AND r.category_id = 60104
  AND r.status_id <> 23
  AND r.retro_corrected = 'N'
  AND m.mod_id = r.mod_id
GROUP BY 
  t.task_id, t.task_para_date_02, t.task_description, m.mod_id, m.mod_name
ORDER BY t.task_id, m.mod_id 



SELECT
  rds.retro_id,
  rds.retro_con_range_1_min,
  rds.retro_con_range_1_max,
  rds.retro_con_rate_1_100,
  rds.retro_con_id,
  rds.retro_tier_con_id,
  ret.con_range_1_min,
  ret.con_range_1_max,
  ret.con_rate_1_100,
  ret.ret_con_id,
  ret.tier_con_id
FROM ( SELECT
         r.retro_id,
         TO_NUMBER(rds.value_2) AS retro_con_range_1_min,
         TO_NUMBER(rds.value_3) AS retro_con_range_1_max,
         TO_NUMBER(rds.value_4) AS retro_con_rate_1_100,
         TO_NUMBER(rds.value_12) AS retro_con_id,
         TO_NUMBER(rds.value_13) AS retro_tier_con_id
       FROM 
         task tpay,
         retro r, 
         retrodata_static rds
       WHERE
         tpay.task_id = :PAYMENT_ID 
         AND r.payment_task_id = tpay.task_id 
         AND r.status_id <> 23
         AND r.retro_corrected = 'N'
         AND rds.retro_id = r.retro_id
         AND rds.mds_id =  7000
       ORDER BY r.retro_id, TO_NUMBER(rds.value_2) ) rds,
	 ( SELECT
         r.retro_id,
         con.con_range_1_min AS con_range_1_min,
         con.con_range_1_max AS con_range_1_max,
         con.con_rate_1 * 100 AS con_rate_1_100,
         cret.con_id AS ret_con_id,
         con.con_id AS tier_con_id
       FROM  
         task tpay,
         retro r, 
         condition cret,
         condition con
       WHERE
         tpay.task_id = :PAYMENT_ID 
         AND r.payment_task_id = tpay.task_id 
         AND r.status_id <> 23
         AND r.retro_corrected = 'N'
         AND cret.con_id = r.con_id
         AND con.mpg_id = cret.mpg_id
         AND r.retro_date BETWEEN con.con_date_from AND con.con_date_to 
       ORDER BY r.retro_id, con.con_range_1_min) ret
WHERE
  ret.retro_id(+) = rds.retro_id
  AND ret.tier_con_id(+) = rds.retro_tier_con_id
ORDER BY rds.retro_id, rds.retro_con_range_1_min  




SELECT
  rds.retro_id,
  rds.mod_cur_id,
  rds.retro_mod_cur_amount * 12 AS retro_annual_fee,
  rds.retro_mod_cur_amount AS retro_monthly_fee,
  SUM(rds.retro_rds_annual_fee) AS retro_rds_annual_fee,
  SUM(rds.retro_rds_monthly_fee) AS retro_rds_monthly_fee,
  MAX(rds.retro_rds_currency_id) AS retro_rds_currency_id
FROM ( SELECT
         r.retro_id,
		 r.mod_cur_id,
		 r.retro_mod_cur_amount,
         TO_NUMBER(rds.value_5) AS retro_rds_annual_fee,
         TO_NUMBER(rds.value_6) AS retro_rds_monthly_fee,
         TO_NUMBER(rds.value_7) AS retro_rds_currency_id
       FROM 
         task tpay,
         retro r, 
         retrodata_static rds
       WHERE
         tpay.task_id = :PAYMENT_ID 
         AND r.payment_task_id = tpay.task_id 
         AND r.status_id <> 23
         AND r.retro_corrected = 'N'
         AND rds.retro_id = r.retro_id
         AND rds.mds_id =  7000
       ORDER BY r.retro_id, TO_NUMBER(rds.value_2) ) rds
       
       
       
SELECT
  rds.retro_id,
  rds.mod_cur_id,
  rds.retro_mod_cur_amount * 12 AS retro_annual_fee,
  rds.retro_mod_cur_amount AS retro_monthly_fee,
  SUM(rds.retro_rds_annual_fee) AS retro_rds_annual_fee,
  SUM(rds.retro_rds_monthly_fee) AS retro_rds_monthly_fee,
  MAX(rds.retro_rds_currency_name) AS retro_rds_currency_name
FROM ( SELECT
         r.retro_id,
		 r.mod_cur_id,
		 r.retro_mod_cur_amount,
         TO_NUMBER(rds.value_5) AS retro_rds_annual_fee,
         TO_NUMBER(rds.value_6) AS retro_rds_monthly_fee,
         rds.value_7 AS retro_rds_currency_name
       FROM 
         task tpay,
         retro r, 
         retrodata_static rds
       WHERE
         tpay.task_id = :PAYMENT_ID 
         AND r.payment_task_id = tpay.task_id 
         AND r.status_id <> 23
         AND r.retro_corrected = 'N'
         AND rds.retro_id = r.retro_id
         AND rds.mds_id =  7000
       ORDER BY r.retro_id, TO_NUMBER(rds.value_2) ) rds
GROUP BY rds.retro_id, rds.mod_cur_id, rds.retro_mod_cur_amount       



SELECT
  rds.retro_id,
  rds.rate_det_volume,
  rds.mod_id,
  rds.retro_mod_cur_amount,
  SUM(rds.retro_mod_cur_amount) OVER (PARTITION BY rds.mod_id) AS total_retro_amount_per_model,
  MAX(rds.retro_rds_rdv) AS retro_rds_rdv,
  MAX(rds.retro_rds_amount_per_model) AS retro_rds_amount_per_model
FROM ( SELECT
         r.retro_id,
		 r.mod_cur_id,
		 r.mod_id,
		 r.retro_mod_cur_amount,
		 r.rate_det_volume,
         TO_NUMBER(rds.value_14) AS retro_rds_rdv,
         TO_NUMBER(rds.value_15) AS retro_rds_amount_per_model
       FROM 
         task tpay,
         retro r, 
         retrodata_static rds
       WHERE
         tpay.task_id = :PAYMENT_ID 
         AND r.payment_task_id = tpay.task_id 
         AND r.status_id <> 23
         AND r.retro_corrected = 'N'
         AND rds.retro_id = r.retro_id
         AND rds.mds_id =  7000
       ORDER BY r.retro_id, TO_NUMBER(rds.value_2) ) rds
GROUP BY rds.retro_id, rds.rate_det_volume, rds.mod_id, rds.retro_mod_cur_amount       


UPDATE condition c
  SET con_range_1_min = c.con_range_1_min/1000,
      con_range_1_max = c.con_range_1_max/1000 
WHERE 2<= (SELECT COUNT(con_id) FROM condition WHERE mpg_id = c.mpg_id)
  AND mpg_id IN (SELECT mpg_id FROM model_productgroup WHERE mod_id IN (SELECT mod_id FROM model WHERE mod_name IN ('RF_1002_CHF', 'RF_ALL_LAZARDS_CHF')))
  
  
  