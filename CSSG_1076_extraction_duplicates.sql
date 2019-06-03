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
  p.par_id, p.par_number, p.cust_id, p.cust_number, pc.pc_date_from, pc.pc_date_to
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
GROUP BY p.par_id, p.par_number, p.cust_id, p.cust_number, pc.pc_date_from, pc.pc_date_to
ORDER BY p.par_id, p.cust_id



SELECT * FROM partner_customer WHERE par_id = 492 AND cust_id = 17534

