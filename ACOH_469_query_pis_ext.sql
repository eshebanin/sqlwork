SELECT 
  ID1, ID2
FROM TABLE(PAY.GET_PAYINSTR_ATR( 
                                 PAR_DATE                => R.RETRO_PAYMENT_DATE
                                 ,PAR_PAR_ID              => R.PAR_ID
                                 ,PAR_CUST_ID             => R.CUST_ID
                                 ,PAR_CUR_ID              => R.PAR_CUR_ID
                                 ,PAR_ACCOUNT_TYPE        => NULL
                                                            ,PAR_MOD_ID              => R.MOD_ID
                                                            ,PAR_AMOUNT              => 0      -- We don't know the amount yet. This will be handled while archiving
                                                            ,PAR_DETAIL_ID           => R.DETAIL_ID
                                                            ,PAR_DET_CUR_ID          => R.DET_CUR_ID
                                                            ,PAR_IGNORE_AMOUNT_FLAG  => DEF.CON_Y-- we do not need to check for the amount at this point
                                                            ,PAR_ORGUNIT_ID          => (SELECT P.ORGUNIT_ID FROM PARTNER P WHERE P.PAR_ID = R.PAR_ID)
                                                            ,PAR_RULE_CONTEXT_ID     => CALC_PROD.CON_PI_RULE_TYPE_PAYMENT
                                                            ,PAR_CATEGORY_ID         => R.CATEGORY_ID )
                                                   )
                                                   
                                                   
                                                   
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
  AND t.task_para_date_02 BETWEEN TO_DATE('01012016', 'ddmmyyyy') AND TO_DATE('31122025', 'ddmmyyyy')  
  AND r.payment_task_id = t.task_id
  AND r.category_id = 60101
  AND r.status_id <> 23
  AND r.retro_corrected = 'N'
  AND m.mod_id = r.mod_id
GROUP BY 
  t.task_id, t.task_para_date_02, t.task_description, m.mod_id, m.mod_name
ORDER BY t.task_id, m.mod_id                  



SELECT
  t.task_id AS pay_task_id,
  t.task_para_date_02 AS pay_task_date,
  t.task_description AS pay_task_description,
  p.par_id,
  p.par_number,  
  m.mod_id,
  m.mod_name,
  pg.pg_id,
  pg.pg_description,
  con.con_id,
  con.con_range_1_min,
  con.con_range_1_max,
  con.con_rate_1
FROM  
  task t,
  retro r,
  model m,
  partner p,
  model_productgroup mpg,
  productgroup pg,
  condition con
WHERE
  t.tasktype_id = 530 
  AND t.task_para_date_02 BETWEEN TO_DATE('01012016', 'ddmmyyyy') AND TO_DATE('31122025', 'ddmmyyyy')  
  AND p.par_id = t.task_para_number_01
  AND r.payment_task_id = t.task_id
  AND r.category_id = 60101
  AND r.status_id <> 23
  AND r.retro_corrected = 'N'
  AND m.mod_id = r.mod_id
  AND mpg.mpg_id = r.mpg_id
  AND mpg.mod_id = m.mod_id
  AND pg.pg_id = mpg.pg_id
  AND con.mpg_id = mpg.mpg_id
  AND r.retro_payment_date BETWEEN con.con_date_from AND con.con_date_to
GROUP BY t.task_id, t.task_para_date_02, t.task_description, 
         p.par_id, p.par_number, m.mod_id, m.mod_name,
         pg.pg_id, pg.pg_description, con.con_id,
         con.con_range_1_min, con.con_range_1_max, con.con_rate_1  
ORDER BY p.par_id, t.task_id, m.mod_id, pg.pg_id, con.con_range_1_min




SELECT * FROM payinstr_rule
ORDER BY 1 DESC 


SELECT * FROM retro_payment
