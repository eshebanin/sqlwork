WITH period AS (SELECT :PERIOD_STARTS AS period_starts, :PERIOD_ENDS AS period_ends FROM DUAL),
     cps AS (SELECT par_id, par_number FROM partner WHERE par_number LIKE 'TC%' AND category_id =101 )
SELECT
  cp.par_id,
  cp.par_number,
  tpay.task_id,
  tpay.task_para_date_02,
  tpay.task_description,
  rp.cur_id,
  (SELECT cur_name FROM currency WHERE cur_id = rp.cur_id) AS cur_name,
  rp.pi_id,
  (SELECT pi_name FROM payinstr WHERE pi_id = rp.pi_id) AS pi_name
FROM
  period pr,
  cps cp,
  task tpay,
  retro_payment rp
WHERE
  tpay.tasktype_id = 530 AND
  tpay.task_para_date_02 BETWEEN pr.period_starts AND pr.period_ends AND
  tpay.task_para_number_03 = 60101 AND
  tpay.task_para_number_01 = cp.par_id AND
  -- tpay.status_id <> 952 AND
  rp.payment_task_id = tpay.task_id
GROUP BY cp.par_id, cp.par_number, tpay.task_id, tpay.task_para_date_02, tpay.task_description, rp.cur_id, rp.pi_id  
ORDER BY cp.par_id, tpay.task_id


select * from PAYINSTR
ORDER BY 1 DESC


SELECT * FROM payinstr_rule
-- WHERE o_pi_id BETWEEN 10200 AND 10211
ORDER BY 1 DESC

UPDATE payinstr_rule
  SET i_par_id = i_par2_id
WHERE o_pi_id BETWEEN 10200 AND 10211

UPDATE payinstr_rule
  SET i_par_id = NULL,
      i_par2_id = NULL
WHERE o_pi_id BETWEEN 10200 AND 10211


UPDATE payinstr_rule
  SET i_det_cur_id = i_cur_id
WHERE o_pi_id BETWEEN 10200 AND 10211


UPDATE task t
  SET wf_status_id = 1560
WHERE wf_status_id = 413
  AND tasktype_id = 531  
  AND exists (SELECT 1 FROM xxx_task WHERE task_id = t.task_id AND wf_status_id = 413)
  

SELECT * FROM parameter
ORDER BY par_key DESC


SELECT * FROM partner WHERE par_id = 10617



select * from SELECTION_DETAIL
order by 1 desc


SELECT * FROM servertask
ORDER BY 1 DESC



SELECT * FROM retro
WHERE par_id = 10601
   AND status_id <> 23
ORDER BY 1 DESC



SELECT * FROM partner
ORDER BY 1 DESC



SELECT p.*, p.rowid FROM payinstr_RULE p
ORDER BY 1 DESC



SELECT
  r.retro_id, r.cust_id, r.pi_id, pi.pi_id
FROM 
  retro r,
  payinstr pi
WHERE 
r.par_id = 10601
AND r.status_id <> 23
AND pi.pi_id IN   
( SELECT ID1 
  FROM TABLE(PAY.GET_PAYINSTR_ATR( PAR_DATE                => R.RETRO_PAYMENT_DATE
                                   ,PAR_PAR_ID              => R.PAR_ID
                                   ,PAR_CUST_ID             => R.CUST_ID
                                   ,PAR_CUR_ID              => R.PAR_CUR_ID
                                   ,PAR_ACCOUNT_TYPE        => NULL
                                   ,PAR_MOD_ID              => R.MOD_ID
                                   ,PAR_AMOUNT              => 0      -- We don't know the amount yet. This will be handled while archiving
                                   ,PAR_DETAIL_ID           => R.DETAIL_ID
                                   ,PAR_DET_CUR_ID          => R.DET_CUR_ID
                                   ,PAR_IGNORE_AMOUNT_FLAG  => 'Y'-- we do not need to check for the amount at this point
                                   ,PAR_ORGUNIT_ID          => (SELECT P.ORGUNIT_ID FROM PARTNER P WHERE P.PAR_ID = R.PAR_ID)
                                   ,PAR_RULE_CONTEXT_ID     => 2200
                                   ,PAR_CATEGORY_ID         => R.CATEGORY_ID )
                                 )
)