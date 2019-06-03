DECLARE
  n_wf_status_id task.wf_status_id%TYPE := CONFIG.GET_PARAM_NUM('G_WF_AFTER_CALC');
  n_returncode NUMBER;
  v_error VARCHAR2(2000);
  v_user_context VARCHAR2(2000) := 'ESH_ACOH_1456_2_CURR_SESS';
  n_category_id model.category_id%TYPE := 60101;
  n_task_id task.task_id%TYPE := 10060;
  n_objecttype xpobjecttype.oid%TYPE;
  n_wlft_id wfl_transition.wflt_id%TYPE;
BEGIN
  sec.open_session(1,1);
  CONTEXT.SET_USER(v_user_context, 'SuperUser');
  
  FOR c_task IN ( SELECT
                    t.task_id AS calc_id, t.wf_status_id
				  FROM
				    selection_detail scat,
					task t
				  WHERE
                    scat.object_id = n_category_id
                    AND scat.seldet_type = 'CATEGORY_ID' 
                    AND t.sel_id = scat.sel_id
                    AND t.wf_status_id = 411 
                    AND t.tasktype_id = 531)
  LOOP 		
      
    n_task_id := c_task.calc_id;
	
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
  
    FOR cur IN ( SELECT
                   t.task_id,
		  		   t.tasktype_id,
                   xp.oid AS objecttype
                 FROM
                   task t,
                   xpobjecttype xp
                 WHERE 
                   t.origin_task_id = n_task_id
				   AND t.tasktype_id = 530
                   AND xp.typename = 'Quartal.Commission.Client.Module.Model.Payment' )
     LOOP 
      -- run payment tasks
      UPDATE TASK
        SET TASK_PARA_CHAR_01 = 'A'
      WHERE TASK_ID = cur.task_id
        AND OBJECTTYPE = cur.objecttype;

      CALC_PROD.VPS_EXECUTE_TASK( PAR_TASK_ID        => cur.task_id
                                  ,PAR_TASK_TYPE     => cur.tasktype_id
                                  ,PAR_RETURNCODE    => n_returncode
                                  ,PAR_ERROR         => v_error);                                  

    END LOOP;

  END LOOP;
END; 



SELECT * FROM task
WHERE tasktype_id = 530
ORDER BY 1 DESC