DECLARE
  -- Error handling variables and logging levels
  n_log_level NUMBER;
  n_status_id NUMBER;
  v_program_code VARCHAR2(255) := 'CSSG_1099_REMOVE_DUPLICATES';
  b_debug BOOLEAN;
BEGIN
  -- Setting logging levels
  
  -- Current logging level will be cached to internal variable
  n_log_level := CONFIG.GET_PARAM_NUM('LOG_LEVEL');
  
  -- About to set logging level to DEBUG
  LOGGER.SET_LOG_LEVEL(I_LOG_LEVEL => LOGGER.CON_DEBUG);
  
  LOGGER.INFO(PAR_MSG => 'UPDATE_KBP_FEETYPE: Procedure started, starting declaration section');
  
  LOGGER.INFO(PAR_MSG => v_program_code || 'de-duplication process started');
  
  FOR c_dup IN ( 
               WITH seqgen AS ( SELECT level AS step
                                FROM dual
                                CONNECT BY LEVEL <= 1000),
                    days AS ( SELECT 
                                TO_DATE('01012017', 'ddmmyyyy') + s.step - 1 AS day_value
                              FROM seqgen s), 				
                    qrt AS ( SELECT				 
                               ADD_MONTHS(TO_DATE('01012017', 'ddmmyyyy'), 3*(s.step-1))  AS qrt_starts,
                               ADD_MONTHS(ADD_MONTHS(TO_DATE('01012017', 'ddmmyyyy'), 3*(s.step-1)), 3) - 1 AS qrt_ends
			                 FROM seqgen s),			  
	                cust AS ( SELECT		  
	                            acc.acc_id, acc.acc_number, cst.cust_id, cst.cust_number
			                  FROM 
			                    account acc,
				                customer cst
			                  WHERE 
			                    acc.cust_id = cst.cust_id),
                    parcust AS (SELECT 
	                              p.par_id, p.par_number, p.par_company_name, pc.pc_id, pc.pc_date_from, pc.pc_date_to,
	                              cst.acc_id, cst.acc_number, cst.cust_id, cst.cust_number     
				                FROM
                                  cust cst,
                                  partner_customer pc,
                                  partner p
                                WHERE
                                  pc.cust_id = cst.cust_id
                                  AND pc.par_id = p.par_id )				   
               SELECT
                 p.par_id, p.par_number, p.cust_id, p.cust_number, 
				 MAX(pc.pc_id) AS max_pc_id, MIN(pc.pc_date_from) AS min_pc_date_from, MAX(pc.pc_date_to) AS max_pc_date_to,
				 MAX(p.day_value) AS day_value
               FROM ( SELECT
                        q.qrt_starts, q.qrt_ends, d.day_value, 
                        p.par_id, p.par_number, p.cust_id, p.cust_number, COUNT(DISTINCT p.pc_id) AS linkages_cnt
                      FROM 
                        qrt q,
                        days d,
                        parcust p
                      WHERE 
                        d.day_value BETWEEN q.qrt_starts AND q.qrt_ends AND
                        d.day_value BETWEEN p.pc_date_from AND p.pc_date_to AND
                        q.qrt_starts <= TO_DATE('01042019', 'ddmmyyyy')
                      GROUP BY q.qrt_starts, q.qrt_ends, d.day_value, p.par_id, p.par_number, p.cust_id, p.cust_number   
                      HAVING COUNT(DISTINCT p.pc_id) > 1 ) p,
	                 partner_customer pc
               WHERE pc.par_id = p.par_id AND p.cust_id = pc.cust_id	 
               GROUP BY p.par_id, p.par_number, p.cust_id, p.cust_number
               ORDER BY p.par_id, p.cust_id )
  LOOP
    LOGGER.INFO(PAR_MSG => v_program_code || ' duplicated linkages detected on Rateset (PARTNER.ID = ' || TO_CHAR(c_dup.par_id) || ', PARTNER.PAR_NUMBER = ' || c_dup.par_number || ') ' ||
	                                         ' and CIF (CUSTOMER.CUST_ID = ' || TO_CHAR(c_dup.cust_id) || ', CUSTOMER.CUST_NUMBER = ' || c_dup.cust_number  || ') ' ||
                                             ' on the check date ' || TO_CHAR(c_dup.day_value, 'dd.mm.yyyy'));
    -- The linkage with MAX(pc_id) will be extended to cover period MIN(pc_date_from) to MAX(pc_date_to)
    -- All other linkages on same CIF and EAM will be logically invalidated
    UPDATE partner_customer    
      SET pc_date_from = c_dup.min_pc_date_from - 1,
          pc_date_to = c_dup.min_pc_date_from - 2,
          pc_retro_entitled = 'N'
    WHERE par_id = c_dup.par_id
      AND cust_id = c_dup.cust_id
      AND pc_id <> c_dup.max_pc_id;	  
	  
    LOGGER.INFO(PAR_MSG => v_program_code || TO_CHAR(SQL%ROWCOUNT) || ' linkages removed on Rateset (PARTNER.ID = ' || TO_CHAR(c_dup.par_id) || ', PARTNER.PAR_NUMBER = ' || c_dup.par_number || ') ' ||
	                                         ' and CIF (CUSTOMER.CUST_ID = ' || TO_CHAR(c_dup.cust_id) || ', CUSTOMER.CUST_NUMBER = ' || c_dup.cust_number  || ') ' ||
                                             ' on the check date ' || TO_CHAR(c_dup.day_value, 'dd.mm.yyyy') || '.' ||
											 ' Linkage with PARTNER_CUSTOMER.PC_ID = ' || TO_CHAR(c_dup.max_pc_id) || ' preserved - the validity will be extended in the next processing step.');
	  
    -- The linkage with MAX(pc_id) will be extended to cover period MIN(pc_date_from) to MAX(pc_date_to)
	UPDATE partner_customer
	  SET pc_date_from = c_dup.min_pc_date_from,
	      pc_date_to = c_dup.max_pc_date_to
    WHERE pc_id = c_dup.max_pc_id;   
    
	LOGGER.INFO(PAR_MSG => v_program_code || ' linkage with PARTNER_CUSTOMER.PC_ID = ' || TO_CHAR(c_dup.max_pc_id) || ' had its validity extended to ' ||
                                             ' PARTNER_CUSTOMER.PC_DATE_FROM = ' || TO_CHAR(c_dup.min_pc_date_from, 'dd.mm.yyyy') || 
											 ' and PARTNER_CUSTOMER.PC_DATE_TO = ' || TO_CHAR(c_dup.max_pc_date_to, 'dd.mm.yyyy') );
 
  END LOOP;

  LOGGER.INFO(PAR_MSG => v_program_code || 'de-duplication process completed');
  
  -- Reverting to default log level
  LOGGER.SET_LOG_LEVEL(I_LOG_LEVEL => n_log_level);
  
  -- COMMIT; 
END;

-- Verification query
-- SELECT 
--   qlog_id, qlog_time, qlog_msg   
-- FROM qlog
-- WHERE qlog_msg LIKE 'CSSG_1099_REMOVE_DUPLICATES%'
--   AND qlog_time >= TRUNC(SYSDATE)
-- ORDER BY 1  