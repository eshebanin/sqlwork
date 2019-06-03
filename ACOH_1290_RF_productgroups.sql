SELECT
  r.retro_id,
  r.retro_date,
  r.rate_calc_volume,
  r.rate_det_volume,
  r.retro_mod_cur_amount,
  m.mod_id,
  m.mod_name,
  m.wf_status_id,
  pg.pg_id,
  pg.pg_description,
  mpg.mpg_date_from,
  mpg.mpg_date_to,
  con.con_id,
  con.con_date_from,
  con.con_date_to,
  con.con_range_1_min,
  con.con_range_1_max,
  con.con_rate_1,
  DECODE(con.con_id, r.con_id, r.rate_det_volume - con.con_range_1_min, con.con_range_1_max - con.con_range_1_min) AS tiered_rdv,
  DECODE(con.con_id, r.con_id, r.rate_det_volume - con.con_range_1_min, con.con_range_1_max - con.con_range_1_min) * con.con_rate_1 * 0.01 AS tiered_fee,
  r.rate_calc_volume / r.rate_det_volume * SUM(DECODE(con.con_id, r.con_id, r.rate_det_volume - con.con_range_1_min, con.con_range_1_max - con.con_range_1_min) * con.con_rate_1 * 0.01) OVER (PARTITION BY r.retro_id) * 1/12 AS total_tiered_fee
FROM
  retro r,
  model m,
  model_productgroup mpg,
  productgroup pg,
  condition con
WHERE 
  r.payment_task_id = 10702
  AND r.retro_corrected = 'N'
  AND r.status_id <> 23
  AND m.mod_id = r.mod_id 
  AND mpg.mpg_id =  r.mpg_id  
  AND pg.pg_id = r.mpg_id
  AND con.mpg_id = mpg.mpg_id
ORDER BY r.retro_id, con.mpg_id, con.con_range_1_min  


SELECT
  mod_id, SUM(r.rate_calc_volume), MAX(r.rate_det_volume)
FROM retro r
WHERE payment_task_id = 10702
  AND r.retro_corrected = 'N'
  AND r.status_id <> 23  
GROUP BY mod_id  



SELECT
  t.task_id,
  r.mod_id, 
  TRUNC(r.retro_date, 'mon') AS retro_month,
  SUM(r.rate_calc_volume), MAX(r.rate_det_volume)
FROM 
  task t,
  retro r
WHERE 
  t.tasktype_id = 530
  AND t.task_para_number_03 = 60104
  AND r.payment_task_id = t.task_id
  AND r.retro_corrected = 'N'
  AND r.status_id <> 23  
GROUP BY t.task_id, r.mod_id, TRUNC(r.retro_date, 'mon')
ORDER BY t.task_id, r.mod_id, TRUNC(r.retro_date, 'mon')