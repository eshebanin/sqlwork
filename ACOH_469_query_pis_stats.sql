WITH period AS (SELECT TO_DATE('01012021', 'ddmmyyyy') AS period_starts, TO_DATE('31032021', 'ddmmyyyy') AS period_ends FROM DUAL),
     cps AS (SELECT par_id, par_number FROM partner WHERE par_number IN ('TC1-Coop_Partner_1', 'TC5-Coop_Partner_1', 'TC5-Coop_Partner_2') )
SELECT 
  cp_par_id, cp_par_number, task_id, task_para_date_02, task_description, cur_id, cur_name, pi_id, pi_name, 
  LISTAGG(dp_par_number, ',') WITHIN GROUP (ORDER BY dp_par_id) AS dp_par_numbers
FROM 	 
( SELECT
    cp.par_id AS cp_par_id,
    cp.par_number AS cp_par_number,
    tpay.task_id,
    tpay.task_para_date_02,
    tpay.task_description,
    rp.cur_id,
    (SELECT cur_name FROM currency WHERE cur_id = rp.cur_id) AS cur_name,
    pi.pi_id,
    pi.pi_name,
    ppay.par_id AS dp_par_id,
    ppay.par_number AS dp_par_number
  FROM
    period pr,
    cps cp,
    task tpay,
    retro_payment rp,
    payinstr pi,
    retro r,
    partner_customer pc,
    partner ppay
  WHERE
    tpay.tasktype_id = 530 AND
    tpay.task_para_date_02 BETWEEN pr.period_starts AND pr.period_ends AND
    tpay.task_para_number_03 = 60101 AND
    tpay.task_para_number_01 = cp.par_id AND
    rp.payment_task_id = tpay.task_id AND
    pi.pi_id = rp.pi_id AND
    r.payment_task_id = tpay.task_id AND
    --r.rp_id = rp.rp_id AND
    r.pi_id = pi.pi_id AND
    pc.cust_id = r.cust_id AND
    r.retro_date BETWEEN pc.pc_date_from AND pc.pc_date_to AND
    ppay.par_id = pc.par_id  
  GROUP BY cp.par_id, cp.par_number, tpay.task_id, tpay.task_para_date_02, tpay.task_description, rp.cur_id, rp.pi_id, 
  pi.pi_id, pi.pi_name, ppay.par_id, ppay.par_number  )
GROUP BY cp_par_id, cp_par_number, task_id, task_para_date_02, task_description, cur_id, cur_name, pi_id, pi_name
ORDER BY cp_par_id, task_id, pi_id
