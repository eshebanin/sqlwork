SELECT 
  mod_id, mod_name,
  mpg_date_from,
  mpg_date_to,
  con_id, con_range_1_min, con_range_1_max, con_rate_1, conditions_cnt
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
WHERE conditions_cnt >= 2



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




10300, 10301, 10302, 10303, 10304, 100305, 10306


SELECT
  t.task_id AS pay_task_id,
  t.task_para_date_02 AS pay_task_date,
  t.task_description AS pay_task_description,
  m.mod_id,
  m.mod_name,  
  (SELECT cur_name FROM currency WHERE cur_id = m.cur_id) AS model_currency,
  TRUNC(r.retro_date, 'mon') AS first_day_month,
  MAX(r.rate_det_volume) AS rdv_on_model,
  SUM(r.rate_calc_volume) AS total_calc_volume_model,
  SUM(r.retro_mod_cur_amount) AS total_retro_amount_model,  
  (SELECT COUNT(DISTINCT con_id) FROM condition WHERE mpg_id IN (SELECT mpg_id FROM model_productgroup WHERE mod_id = m.mod_id) AND t.task_para_date_02 BETWEEN con_date_from AND con_date_to) AS conditions_cnt
FROM  
  task t,
  retro r,
  model m
WHERE
  t.tasktype_id = 530 
  AND t.task_para_date_02 BETWEEN TO_DATE('01012016', 'ddmmyyyy') AND TO_DATE('31122025', 'ddmmyyyy')
  AND t.task_id IN (10300, 10301, 10302, 10303, 10304, 100305, 10306)  
  AND r.payment_task_id = t.task_id
  AND r.category_id = 60104
  AND r.status_id <> 23
  AND r.retro_corrected = 'N'
  AND m.mod_id = r.mod_id
GROUP BY 
  t.task_id, t.task_para_date_02, t.task_description, m.mod_id, m.mod_name, m.cur_id, TRUNC(r.retro_date, 'mon')
ORDER BY t.task_id, m.mod_id, TRUNC(r.retro_date, 'mon')



SELECT * FROM version_history
ORDER BY



SELECT DISTINCT use_pi_in_pt_creation_flag FROM partner
