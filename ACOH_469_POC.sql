SET DEFINE ON

PROMPT >>> BEGIN MODIFY G_USE_PI_IN_PT_CREATION to 2

BEGIN

  UPDATE parameter
    SET par_value = 2
  WHERE par_key = 'G_USE_PI_IN_PT_CREATION';	
	   
  COMMIT;

END;
/

PROMPT <<< END MODIFY G_USE_PI_IN_PT_CREATION to 2



SET DEFINE ON

PROMPT >>> BEGIN SET use_pi_in_pt_creation_flag at PARTNER


DECLARE
  -- VARIABLES
  v_cp_partner_1 partner.par_number%TYPE := 'TC1-Coop_Partner_1';
  v_cp_partner_2 partner.par_number%TYPE := 'TC5-Coop_Partner_1';
  v_cp_partner_3 partner.par_number%TYPE := 'TC5-Coop_Partner_2';
BEGIN

  UPDATE partner
    SET use_pi_in_pt_creation_flag = 'N';
	
  COMMIT;
  
  UPDATE partner
    SET use_pi_in_pt_creation_flag = 'Y'
  WHERE par_number IN (v_cp_partner_1, v_cp_partner_2, v_cp_partner_3);
	   
  COMMIT;

END;
/

PROMPT <<< END SET use_pi_in_pt_creation_flag at PARTNER


SET DEFINE ON

PROMPT >>> BEGIN create dedicated payment instructions for TC1-Coop_Partner_1

DECLARE
  -- VARIABLES
  v_cp_partner_1 partner.par_number%TYPE := 'TC1-Coop_Partner_1';
  v_pay_curr VARCHAR2(255);
  r_payinstr payinstr%ROWTYPE;
  n_process_status NUMBER;
  v_error_message VARCHAR2(2000);
BEGIN
  -- Payment currencies of Receivable partner
  SELECT
    LISTAGG(c.cur_name, ',') WITHIN GROUP (ORDER BY c.cur_name) AS payment_currencies
  INTO v_pay_curr	
  FROM
    partner p,
    selection_detail sp,
    selection_detail scat,
    task tcalc,
    task tpay,
    retro_payment rp,
    currency c
  WHERE
    p.par_number = v_cp_partner_1
    AND sp.object_id = p.par_id
    AND sp.seldet_type = 'PAR_ID'
    AND scat.sel_id = sp.sel_id
    AND scat.seldet_type = 'CATEGORY_ID'
    AND scat.object_id = 60101
    AND tcalc.sel_id = scat.sel_id
    AND tcalc.tasktype_id = 531
    AND tpay.origin_task_id = tcalc.task_id
    AND tpay.tasktype_id = 530
    AND rp.payment_task_id = tpay.task_id
    AND c.cur_id = rp.cur_id
  GROUP BY p.par_id, p.par_number;

  -- Splitting payment currencies string
  FOR cur IN ( SELECT 
                 REGEXP_SUBSTR(v_pay_curr, '[^,]+', 1, level) AS curr_code
			   FROM DUAL	
               CONNECT BY REGEXP_SUBSTR(v_pay_curr, '[^,]+', 1, level) IS NOT NULL )
  LOOP
    -- Collecting info from generic payment instruction of current payment currency
    SELECT
      pi.*
	INTO r_payinstr   
    FROM 
      payinstr pi,
      currency cc
    WHERE
      cc.cur_name = cur.curr_code
      AND pi.pi_name LIKE 'PI for ACOH Trailer Fee (' || cur.curr_code || ')';
	-- Adding CP-specific name and re-formulating PI record for CP-specific instruction
  	r_payinstr.pi_keyname := 'PI for ' || v_cp_partner_1 || ' (' || cur.curr_code || ')';  
  	r_payinstr.pi_name := 'PI for ' || v_cp_partner_1 || ' (' || cur.curr_code || ')';  
	-- Registering new payment instruction for current CP-specific
    DSA_UTL.INSERT_PAYINSTR( PAR_INPUT_ROW => r_payinstr,
                             PAR_STATUS_ID => n_process_status,
                             PAR_DSR_ERROR => v_error_message);
	    
  END LOOP;
  COMMIT;  
END;
/

PROMPT <<< END create dedicated payment instructions for TC1-Coop_Partner_1
  

SET DEFINE ON

PROMPT >>> BEGIN create dedicated payment instructions for TC5-Coop_Partner_1

DECLARE
  -- VARIABLES
  v_cp_partner_1 partner.par_number%TYPE := 'TC5-Coop_Partner_1';
  v_pay_curr VARCHAR2(255);
  r_payinstr payinstr%ROWTYPE;
  n_process_status NUMBER;
  v_error_message VARCHAR2(2000);
BEGIN
  -- Payment currencies of Receivable partner
  SELECT
    LISTAGG(c.cur_name, ',') WITHIN GROUP (ORDER BY c.cur_name) AS payment_currencies
  INTO v_pay_curr	
  FROM
    partner p,
    selection_detail sp,
    selection_detail scat,
    task tcalc,
    task tpay,
    retro_payment rp,
    currency c
  WHERE
    p.par_number = v_cp_partner_1
    AND sp.object_id = p.par_id
    AND sp.seldet_type = 'PAR_ID'
    AND scat.sel_id = sp.sel_id
    AND scat.seldet_type = 'CATEGORY_ID'
    AND scat.object_id = 60101
    AND tcalc.sel_id = scat.sel_id
    AND tcalc.tasktype_id = 531
    AND tpay.origin_task_id = tcalc.task_id
    AND tpay.tasktype_id = 530
    AND rp.payment_task_id = tpay.task_id
    AND c.cur_id = rp.cur_id
  GROUP BY p.par_id, p.par_number;

  -- Splitting payment currencies string
  FOR cur IN ( SELECT 
                 REGEXP_SUBSTR(v_pay_curr, '[^,]+', 1, level) AS curr_code
			   FROM DUAL	
               CONNECT BY REGEXP_SUBSTR(v_pay_curr, '[^,]+', 1, level) IS NOT NULL )
  LOOP
    -- Collecting info from generic payment instruction of current payment currency
    SELECT
      pi.*
	INTO r_payinstr   
    FROM 
      payinstr pi,
      currency cc
    WHERE
      cc.cur_name = cur.curr_code
      AND pi.pi_name LIKE 'PI for ACOH Trailer Fee (' || cur.curr_code || ')';

	-- Adding CP-specific name and re-formulating PI record for CP-specific instruction
  	r_payinstr.pi_keyname := 'PI for ' || v_cp_partner_1 || ' (' || cur.curr_code || ')';  
  	r_payinstr.pi_name := 'PI for ' || v_cp_partner_1 || ' (' || cur.curr_code || ')';  
	-- Registering new payment instruction for current CP-specific
    DSA_UTL.INSERT_PAYINSTR( PAR_INPUT_ROW => r_payinstr,
                             PAR_STATUS_ID => n_process_status,
                             PAR_DSR_ERROR => v_error_message);
	    
  END LOOP;
  COMMIT;  
END;
/

PROMPT <<< END create dedicated payment instructions for TC5-Coop_Partner_1



SET DEFINE ON

PROMPT >>> BEGIN create dedicated payment instructions for TC5-Coop_Partner_2

DECLARE
  -- VARIABLES
  v_cp_partner_1 partner.par_number%TYPE := 'TC5-Coop_Partner_2';
  v_pay_curr VARCHAR2(255);
  r_payinstr payinstr%ROWTYPE;
  n_process_status NUMBER;
  v_error_message VARCHAR2(2000);
BEGIN
  -- Payment currencies of Receivable partner
  SELECT
    LISTAGG(c.cur_name, ',') WITHIN GROUP (ORDER BY c.cur_name) AS payment_currencies
  INTO v_pay_curr	
  FROM
    partner p,
    selection_detail sp,
    selection_detail scat,
    task tcalc,
    task tpay,
    retro_payment rp,
    currency c
  WHERE
    p.par_number = v_cp_partner_1
    AND sp.object_id = p.par_id
    AND sp.seldet_type = 'PAR_ID'
    AND scat.sel_id = sp.sel_id
    AND scat.seldet_type = 'CATEGORY_ID'
    AND scat.object_id = 60101
    AND tcalc.sel_id = scat.sel_id
    AND tcalc.tasktype_id = 531
    AND tpay.origin_task_id = tcalc.task_id
    AND tpay.tasktype_id = 530
    AND rp.payment_task_id = tpay.task_id
    AND c.cur_id = rp.cur_id
  GROUP BY p.par_id, p.par_number;

  -- Splitting payment currencies string
  FOR cur IN ( SELECT 
                 REGEXP_SUBSTR(v_pay_curr, '[^,]+', 1, level) AS curr_code
			   FROM DUAL	
               CONNECT BY REGEXP_SUBSTR(v_pay_curr, '[^,]+', 1, level) IS NOT NULL )
  LOOP
    -- Collecting info from generic payment instruction of current payment currency
    SELECT
      pi.*
	INTO r_payinstr   
    FROM 
      payinstr pi,
      currency cc
    WHERE
      cc.cur_name = cur.curr_code
      AND pi.pi_name LIKE 'PI for ACOH Trailer Fee (' || cur.curr_code || ')';

	-- Adding CP-specific name and re-formulating PI record for CP-specific instruction
  	r_payinstr.pi_keyname := 'PI for ' || v_cp_partner_1 || ' (' || cur.curr_code || ')';  
  	r_payinstr.pi_name := 'PI for ' || v_cp_partner_1 || ' (' || cur.curr_code || ')';  
	-- Registering new payment instruction for current CP-specific
    DSA_UTL.INSERT_PAYINSTR( PAR_INPUT_ROW => r_payinstr,
                             PAR_STATUS_ID => n_process_status,
                             PAR_DSR_ERROR => v_error_message);
	    
  END LOOP;
  COMMIT;  
END;
/

PROMPT <<< END create dedicated payment instructions for TC5-Coop_Partner_2


SET DEFINE ON

PROMPT >>> BEGIN create dedicated payment instructions rules for TC1-Coop_Partner_1

DECLARE
  -- VARIABLES
  v_cp_partner_1 partner.par_number%TYPE := 'TC1-Coop_Partner_1';
  v_dp_partner_1 partner.par_number%TYPE := 'TC1-Distr_Partner_A';
  v_dp_partner_2 partner.par_number%TYPE := 'TC1-Distr_Partner_B';  
  n_pi_id payinstr.pi_id%TYPE;
  n_cust_id customer.cust_id%TYPE;
  v_pay_curr VARCHAR2(255);
  r_pi_rule payinstr_rule%ROWTYPE;
  d_minus_infinity DATE := TO_DATE('01011900', 'ddmmyyyy');
  d_plus_infinity DATE := TO_DATE('31129999', 'ddmmyyyy');  
  n_priority NUMBER := 100;
  n_process_status NUMBER;
  v_error_message VARCHAR2(2000);
BEGIN
  -- Payment currencies of Receivable partner
  SELECT
    LISTAGG(c.cur_name, ',') WITHIN GROUP (ORDER BY c.cur_name) AS payment_currencies
  INTO v_pay_curr	
  FROM
    partner p,
    selection_detail sp,
    selection_detail scat,
    task tcalc,
    task tpay,
    retro_payment rp,
    currency c
  WHERE
    p.par_number = v_cp_partner_1
    AND sp.object_id = p.par_id
    AND sp.seldet_type = 'PAR_ID'
    AND scat.sel_id = sp.sel_id
    AND scat.seldet_type = 'CATEGORY_ID'
    AND scat.object_id = 60101
    AND tcalc.sel_id = scat.sel_id
    AND tcalc.tasktype_id = 531
    AND tpay.origin_task_id = tcalc.task_id
    AND tpay.tasktype_id = 530
    AND rp.payment_task_id = tpay.task_id
    AND c.cur_id = rp.cur_id
  GROUP BY p.par_id, p.par_number;

  
  -- Splitting payment currencies string
  FOR cur IN ( SELECT 
                 REGEXP_SUBSTR(v_pay_curr, '[^,]+', 1, level) AS curr_code
			   FROM DUAL	
               CONNECT BY REGEXP_SUBSTR(v_pay_curr, '[^,]+', 1, level) IS NOT NULL )
  LOOP
    -- Collecting info from CP-specific payment instruction of current payment currency
    SELECT
      MAX(pi.pi_id)
	INTO n_pi_id   
    FROM 
      payinstr pi,
      currency cc
    WHERE
      cc.cur_name = cur.curr_code
      AND pi.pi_name LIKE 'PI for ' || v_cp_partner_1 || ' (' || cur.curr_code || ')';
	-- Extracting ID of fee account associated with first DP
    SELECT
      MAX(c.cust_id)
	INTO n_cust_id  
    FROM 
      partner p,
      partner_customer pc,
      customer c
    WHERE
      p.par_number = v_dp_partner_1
      AND pc.par_id = p.par_id 
      AND pc.cust_id = c.cust_id  
      AND c.cust_number LIKE '%Fee%';
    -- Populating fields for payment instruction rule linking first CP and first DP
	-- Key name
	r_pi_rule.pir_keyname := 'PIR for ' || v_cp_partner_1 || ' and ' || v_dp_partner_1 || '(' || cur.curr_code || ')';
	-- Priority
    r_pi_rule.pir_prio := n_priority;
	-- Validities
    r_pi_rule.pir_date_from := d_minus_infinity;
    r_pi_rule.pir_date_to := d_plus_infinity;
    -- Default domain
    r_pi_rule.client_id := 1;
	-- Cooperation partner
	SELECT
	  MAX(par_id)
    INTO r_pi_rule.i_par2_id
	FROM partner
	WHERE par_number = v_cp_partner_1;
	-- Fee account
    r_pi_rule.i_cust_id := n_cust_id;
	-- Payment currency
	SELECT  
	  MAX(cur_id)
	INTO r_pi_rule.i_cur_id  
	FROM currency
	WHERE cur_name = cur.curr_code;
	-- Payment instruction
    r_pi_rule.o_pi_id := n_pi_id;
    DSA_UTL.INSERT_PAYINSTR_RULE( PAR_INPUT_ROW    => r_pi_rule,
                                  PAR_STATUS_ID    => n_process_status,
                                  PAR_DSR_ERROR    => v_error_message );
       
	-- Extracting ID of fee account associated with second DP
    SELECT
      MAX(c.cust_id)
	INTO n_cust_id  
    FROM 
      partner p,
      partner_customer pc,
      customer c
    WHERE
      p.par_number = v_dp_partner_2
      AND pc.par_id = p.par_id 
      AND pc.cust_id = c.cust_id  
      AND c.cust_number LIKE '%Fee%';
    -- Populating fields for payment instruction rule linking first CP and first DP
	-- Key name
	r_pi_rule.pir_keyname := 'PIR for ' || v_cp_partner_1 || ' and ' || v_dp_partner_2 || '(' || cur.curr_code || ')';
	-- Priority
    r_pi_rule.pir_prio := n_priority;
	-- Validities
    r_pi_rule.pir_date_from := d_minus_infinity;
    r_pi_rule.pir_date_to := d_plus_infinity;
    -- Default domain
    r_pi_rule.client_id := 1;
	-- Cooperation partner
	SELECT
	  MAX(par_id)
    INTO r_pi_rule.i_par2_id
	FROM partner
	WHERE par_number = v_cp_partner_1;
	-- Fee account
    r_pi_rule.i_cust_id := n_cust_id;
	-- Payment currency
	SELECT  
	  MAX(cur_id)
	INTO r_pi_rule.i_cur_id  
	FROM currency
	WHERE cur_name = cur.curr_code;
	-- Payment instruction
    r_pi_rule.o_pi_id := n_pi_id;
    DSA_UTL.INSERT_PAYINSTR_RULE( PAR_INPUT_ROW    => r_pi_rule,
                                  PAR_STATUS_ID    => n_process_status,
                                  PAR_DSR_ERROR    => v_error_message );

								  
  END LOOP;
  COMMIT;  
END;
/

PROMPT <<< END create dedicated payment instructions rules for TC1-Coop_Partner_1




SET DEFINE ON

PROMPT >>> BEGIN create dedicated payment instructions rules for TC5-Coop_Partner_1

DECLARE
  -- VARIABLES
  v_cp_partner_1 partner.par_number%TYPE := 'TC5-Coop_Partner_1';
  v_dp_partner_1 partner.par_number%TYPE := 'TC5-Distr_Partner_A';
  v_dp_partner_2 partner.par_number%TYPE := 'TC5-Distr_Partner_B';  
  n_pi_id payinstr.pi_id%TYPE;
  n_cust_id customer.cust_id%TYPE;
  v_pay_curr VARCHAR2(255);
  r_pi_rule payinstr_rule%ROWTYPE;
  d_minus_infinity DATE := TO_DATE('01011900', 'ddmmyyyy');
  d_plus_infinity DATE := TO_DATE('31129999', 'ddmmyyyy');  
  n_priority NUMBER := 100;
  n_process_status NUMBER;
  v_error_message VARCHAR2(2000);
BEGIN
  -- Payment currencies of Receivable partner
  SELECT
    LISTAGG(c.cur_name, ',') WITHIN GROUP (ORDER BY c.cur_name) AS payment_currencies
  INTO v_pay_curr	
  FROM
    partner p,
    selection_detail sp,
    selection_detail scat,
    task tcalc,
    task tpay,
    retro_payment rp,
    currency c
  WHERE
    p.par_number = v_cp_partner_1
    AND sp.object_id = p.par_id
    AND sp.seldet_type = 'PAR_ID'
    AND scat.sel_id = sp.sel_id
    AND scat.seldet_type = 'CATEGORY_ID'
    AND scat.object_id = 60101
    AND tcalc.sel_id = scat.sel_id
    AND tcalc.tasktype_id = 531
    AND tpay.origin_task_id = tcalc.task_id
    AND tpay.tasktype_id = 530
    AND rp.payment_task_id = tpay.task_id
    AND c.cur_id = rp.cur_id
  GROUP BY p.par_id, p.par_number;

  
  -- Splitting payment currencies string
  FOR cur IN ( SELECT 
                 REGEXP_SUBSTR(v_pay_curr, '[^,]+', 1, level) AS curr_code
			   FROM DUAL	
               CONNECT BY REGEXP_SUBSTR(v_pay_curr, '[^,]+', 1, level) IS NOT NULL )
  LOOP
    -- Collecting info from CP-specific payment instruction of current payment currency
    SELECT
      MAX(pi.pi_id)
	INTO n_pi_id   
    FROM 
      payinstr pi,
      currency cc
    WHERE
      cc.cur_name = cur.curr_code
      AND pi.pi_name LIKE 'PI for ' || v_cp_partner_1 || ' (' || cur.curr_code || ')';
	-- Extracting ID of fee account associated with first DP
    SELECT
      MAX(c.cust_id)
	INTO n_cust_id  
    FROM 
      partner p,
      partner_customer pc,
      customer c
    WHERE
      p.par_number = v_dp_partner_1
      AND pc.par_id = p.par_id 
      AND pc.cust_id = c.cust_id  
      AND c.cust_number LIKE '%Fee%';
    -- Populating fields for payment instruction rule linking first CP and first DP
	-- Key name
	r_pi_rule.pir_keyname := 'PIR for ' || v_cp_partner_1 || ' and ' || v_dp_partner_1 || '(' || cur.curr_code || ')';
	-- Priority
    r_pi_rule.pir_prio := n_priority;
	-- Validities
    r_pi_rule.pir_date_from := d_minus_infinity;
    r_pi_rule.pir_date_to := d_plus_infinity;
    -- Default domain
    r_pi_rule.client_id := 1;
	-- Cooperation partner
	SELECT
	  MAX(par_id)
    INTO r_pi_rule.i_par2_id
	FROM partner
	WHERE par_number = v_cp_partner_1;
	-- Fee account
    r_pi_rule.i_cust_id := n_cust_id;
	-- Payment currency
	SELECT  
	  MAX(cur_id)
	INTO r_pi_rule.i_cur_id  
	FROM currency
	WHERE cur_name = cur.curr_code;
	-- Payment instruction
    r_pi_rule.o_pi_id := n_pi_id;
    DSA_UTL.INSERT_PAYINSTR_RULE( PAR_INPUT_ROW    => r_pi_rule,
                                  PAR_STATUS_ID    => n_process_status,
                                  PAR_DSR_ERROR    => v_error_message );
       
	-- Extracting ID of fee account associated with second DP
    SELECT
      MAX(c.cust_id)
	INTO n_cust_id  
    FROM 
      partner p,
      partner_customer pc,
      customer c
    WHERE
      p.par_number = v_dp_partner_2
      AND pc.par_id = p.par_id 
      AND pc.cust_id = c.cust_id  
      AND c.cust_number LIKE '%Fee%';
    -- Populating fields for payment instruction rule linking first CP and first DP
	-- Key name
	r_pi_rule.pir_keyname := 'PIR for ' || v_cp_partner_1 || ' and ' || v_dp_partner_2 || '(' || cur.curr_code || ')';
	-- Priority
    r_pi_rule.pir_prio := n_priority;
	-- Validities
    r_pi_rule.pir_date_from := d_minus_infinity;
    r_pi_rule.pir_date_to := d_plus_infinity;
    -- Default domain
    r_pi_rule.client_id := 1;
	-- Cooperation partner
	SELECT
	  MAX(par_id)
    INTO r_pi_rule.i_par2_id
	FROM partner
	WHERE par_number = v_cp_partner_1;
	-- Fee account
    r_pi_rule.i_cust_id := n_cust_id;
	-- Payment currency
	SELECT  
	  MAX(cur_id)
	INTO r_pi_rule.i_cur_id  
	FROM currency
	WHERE cur_name = cur.curr_code;
	-- Payment instruction
    r_pi_rule.o_pi_id := n_pi_id;
    DSA_UTL.INSERT_PAYINSTR_RULE( PAR_INPUT_ROW    => r_pi_rule,
                                  PAR_STATUS_ID    => n_process_status,
                                  PAR_DSR_ERROR    => v_error_message );

								  
  END LOOP;
  COMMIT;  
END;
/

PROMPT <<< END create dedicated payment instructions rules for TC5-Coop_Partner_1
