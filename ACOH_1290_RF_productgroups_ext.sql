WITH 
  quarter AS (SELECT :QUARTER_STARTS AS qrt_starts, :QUARTER_ENDS AS qrt_ends FROM DUAL),
  rfmodel AS ( SELECT
                 q.qrt_starts,
				 q.qrt_ends,
				 mp.par_id,
				 mp.mp_date_from,
				 mp.mp_date_to,
				 m.mod_id,
				 m.category_id,
				 m.mod_name,
				 mpg.mpg_id,
				 mpg.pg_id,
				 mpg.mpg_date_from,
				 mpg.mpg_date_to
			   FROM
			     quarter q,
				 model_partner mp,
				 model m,
				 model_productgroup mpg
			   WHERE
			      mp.mp_date_from <= q.qrt_ends AND
				  mp.mp_date_to >= q.qrt_starts AND
				  m.mod_id = mp.mod_id AND
				  m.category_id = 60104 AND
				  m.lifecycle_status_id = 950 AND
				  mpg.mod_id = m.mod_id AND
			      mpg.mpg_date_from <= q.qrt_ends AND
				  mpg.mpg_date_to >= q.qrt_starts),
	rfretro AS ( SELECT
                   rf.mpg_id, 
                   rf.payment_task_id,
                   TRUNC(rf.retro_date) AS retro_date,
                   MAX(rf.rate_det_volume) AS rate_det_volume,
                   SUM(rf.rate_calc_volume) AS rate_calc_volume
	             FROM 			  
				   rfmodel mr,
                   retro rf
                 WHERE
                   rf.category_id = mr.category_id AND
                   rf.mpg_id = mr.mpg_id AND
                   rf.retro_date BETWEEN mr.qrt_starts AND mr.qrt_ends AND
                   rf.status_id <> 23 AND
                   rf.retro_corrected = 'N'
                 GROUP BY rf.mpg_id, rf.payment_task_id, TRUNC(rf.retro_date) )
SELECT
  r.mpg_id, 
  r.payment_task_id,
  (SELECT task_para_date_02 FROM task WHERE task_id = r.payment_task_id) AS payment_task_date,
  (SELECT task_description FROM task WHERE task_id = r.payment_task_id) AS payment_task_description,  
  r.retro_date,
  r.rate_det_volume,
  r.rate_calc_volume
FROM rfretro r
ORDER BY mpg_id



SELECT * FROM parameter



DECLARE
  n_wf_status_id task.wf_status_id%TYPE := CONFIG.GET_PARAM_NUM('G_WF_AFTER_CALC');
  n_returncode NUMBER;
  v_error VARCHAR2(2000);
  n_task_id task.task_id%TYPE := 10063;
  n_objecttype xpobjecttype.oid%TYPE;
  n_wlft_id wfl_transition.wflt_id%TYPE;
BEGIN
  sec.open_session(1,1);
  CONTEXT.SET_USER('ESH_ACOH_1257_20_CURR_SESS', 'SuperUser');
  FOR cur IN ( SELECT
                 t.task_id AS object_id,
                 xp.oid AS objecttype,
                 wflt.wflt_id AS trans_id
               FROM
                 task t,
                 xpobjecttype xp,
                 wfl_transition wflt
               WHERE 
                 t.task_id = n_task_id
                 AND xp.typename = 'Quartal.Commission.Client.Module.Model.Calculation'
                 AND wflt.wflt_action = 'StartNewCalculation' )
  LOOP 
    ITEST_UTL.RUN_TASK_BY_ID( I_TASK_ID => cur.object_id);
 
     WFLOW2.SET_WF_STATUS(I_OBJ_ID       => cur.object_id,
                          I_OBJECTTYPE   => cur.objecttype,
                          I_WF_STATUS_ID => n_wf_status_id );
  
  END LOOP;
END;  



SELECT
  category_id, COUNT(1) AS cnt
FROM partner p
WHERE EXISTS (SELECT 1 FROM retro WHERE retro_date >= TO_DATE('01012018', 'ddmmyyyy') AND par_id = p.par_id AND status_id <> 23 AND ROWNUM<=1)
GROUP BY CATEGORY_ID


SELECT * FROM payinstr
ORDER BY 1 DESC



SELECT DISTINCT pi_id FROM retro WHERE category_id = 60102




SELECT
  t.task_id AS pay_task_id,
  t.task_para_date_02 AS pay_task_date,
  t.task_description AS pay_task_description,
  m.mod_id,
  m.mod_name,
  MAX(r.rate_det_volume) AS rdv_on_model,
  SUM(r.rate_calc_volume) AS total_calc_volume_model  
FROM  
  task tpay,
  retro r,
  model m
WHERE
  t.tasktype_id = 530 
  AND t.task_para_date_02 BETWEEN TO_DATE('01012016') AND TO_DATE('31122018')  
  AND r.payment_task_id = t.task_id
  AND r.category_id = 60101
  AND r.status_id <> 23
  AND r.retro_corrected = 'N'
  AND m.mod_id = r.mod_id
GROUP BY 
  t.task_id, t.task_para_date_02, t.task_description, m.mod_id, m.mod_name
ORDER BY t.task_id, m.mod_id
