-- CP "Oaktree"
SELECT par_id, par_number, par_company_name FROM partner WHERE par_company_name LIKE '%Oaktree%'

-- PAR_ID;PAR_NUMBER;PAR_COMPANY_NAME
-- 10282;1007;Oaktree Capital Management (UK) LLP


-- DP "JP Morgan"
SELECT par_id, par_number, par_company_name FROM partner WHERE par_company_name LIKE '%Morgan%' and category_id = 103
-- PAR_ID;PAR_NUMBER;PAR_COMPANY_NAME
-- 10216;10018;J.P. Morgan Bank Luxembourg S.A.
-- 10218;10020;J.P. Morgan Bank Luxembourg S.A.
-- 10383;604;J.P. Morgan Chase
-- 10439;1055;J.P. Morgan International Bank Limited Madrid
-- 10440;1056;J.P. Morgan (S.E.A.) Limited Singapore
-- 10441;1057;J.P. Morgan Securities (Asia Pacific) Limited Hong Kong
-- 10442;1058;J.P. Morgan Gestion Madrid
-- 10443;1059;J.P. Morgan Chase Bank N.A. London
-- 10444;1060;J.P. Morgan Chase Bank N.A. Hong Kong
-- 10445;1061;J.P. Morgan Chase Bank, N.A. Singapore
-- 10446;1062;J.P. Morgan Securities LLC New York
-- 10473;1155;J.P. Morgan Geneva
-- 10474;1159;J.P. Morgan International Bank Milan
-- 10531;3618;J.P. Morgan Paris
-- 10532;3620;J.P. Morgan IICS


-- CP agreements of Oaktree
SELECT DISTINCT
  p.par_id,
  p.par_number,
  p.par_company_name,
  m.mod_id,
  m.mod_name,
  m.wf_status_id,
  pg.pg_id,
  pg.pg_description,
  mpg.mpg_date_from,
  mpg.mpg_date_to
FROM
  partner p
  LEFT OUTER JOIN model_partner mp ON mp.par_id = p.par_id  
  LEFT OUTER JOIN model m ON m.mod_id = mp.mod_id
  LEFT OUTER JOIN model_productgroup mpg ON mpg.mod_id = m.mod_id
  LEFT OUTER JOIN productgroup pg ON pg.pg_id = mpg.mpg_id
  
  
  
SELECT DISTINCT
  p.par_id,
  p.par_number,
  p.par_company_name,
  m.mod_id,
  m.mod_name,
  m.wf_status_id,
  pg.pg_id,
  pg.pg_description,
  mpg.mpg_date_from,
  mpg.mpg_date_to,
  pd.par_id AS distr_id,
  pd.par_number AS distr_number,
  pd.par_company_name AS distr_name  
FROM
  partner p
  LEFT OUTER JOIN model_partner mp ON mp.par_id = p.par_id  
  LEFT OUTER JOIN model m ON m.mod_id = mp.mod_id
  LEFT OUTER JOIN model_productgroup mpg ON mpg.mod_id = m.mod_id
  LEFT OUTER JOIN productgroup pg ON pg.pg_id = mpg.pg_id
  LEFT OUTER JOIN customergroup cg ON cg.cg_id = mpg.cg_id
  LEFT OUTER JOIN customer_customergroup ccg ON ccg.cg_id = cg.cg_id
  LEFT OUTER JOIN customer c ON c.cust_id = ccg.cust_id
  LEFT OUTER JOIN partner_customer pc ON pc.cust_id = c.cust_id
  LEFT OUTER JOIN partner pd ON pd.par_id = pc.par_id  
WHERE
  p.par_number = '1007'
  AND TRUNC(SYSDATE) BETWEEN mp.mp_date_from AND mp.mp_date_to
  AND m.lifecycle_status_id = 950
  AND m.wf_status_id = 422
  AND m.category_id = 60101
  AND TRUNC(SYSDATE) BETWEEN mpg.mpg_date_from AND mpg.mpg_date_to
  AND TRUNC(SYSDATE) BETWEEN ccg.ccg_date_from AND ccg.ccg_date_to
  AND TRUNC(SYSDATE) BETWEEN pc.pc_date_from AND pc.pc_date_to  
  AND pd.par_company_name LIKE '%Morgan%'



WITH seq AS (SELECT level AS num FROM DUAL CONNECT BY level <= 20),
     qrt AS ( SELECT 
	               ADD_MONTHS(TO_DATE('01012017', 'ddmmyyyy'), 3*(s.num-1)) AS qrt_starts,
	               ADD_MONTHS(TO_DATE('01012017', 'ddmmyyyy'), 3*s.num)-1 AS qrt_ends
			  FROM seq s)
SELECT * FROM qrt



WITH seq AS (SELECT level FROM DUAL CONNECT BY level <= 20)
SELECT * FROM seq



WITH seq AS (SELECT level AS num FROM DUAL CONNECT BY level <= 20),
     qrt AS ( SELECT 
	               ADD_MONTHS(TO_DATE('01012017', 'ddmmyyyy'), 3*(s.num-1)) AS qrt_starts,
	               ADD_MONTHS(TO_DATE('01012017', 'ddmmyyyy'), 3*s.num)-1 AS qrt_ends
			  FROM seq s),
    cp AS (SELECT par_id, par_number, par_company_name FROM partner WHERE par_number = '1007')			  
SELECT 
  q.qrt_starts,
  q.qrt_ends,
  cp.par_id,
  cp.par_number,
  cp.par_company_name,
  t.task_id,
  t.task_para_date_01,
  t.task_para_date_02,
  t.task_description,
  t.wf_status_id,
  (SELECT status_designation FROM status WHERE status_id = t.wf_status_id) AS wf_status_name
FROM
  qrt q,
  cp cp,
  selection_detail sp,
  task t
WHERE 
  sp.object_id = cp.par_id
  AND sp.seldet_type = 'PAR_ID'
  AND t.sel_id = sp.sel_id
  AND t.tasktype_id = 531  
  AND t.task_para_date_01 BETWEEN q.qrt_starts AND q.qrt_ends
  
  
  
WITH seq AS (SELECT level AS num FROM DUAL CONNECT BY level <= 20),
     qrt AS ( SELECT 
	               ADD_MONTHS(TO_DATE('01012017', 'ddmmyyyy'), 3*(s.num-1)) AS qrt_starts,
	               ADD_MONTHS(TO_DATE('01012017', 'ddmmyyyy'), 3*s.num)-1 AS qrt_ends
			  FROM seq s),
    cp AS (SELECT par_id, par_number, par_company_name FROM partner WHERE par_number = '1007')			  
SELECT 
  q.qrt_starts,
  q.qrt_ends,
  cp.par_id,
  cp.par_number,
  cp.par_company_name,
  t.task_id,
  t.task_para_date_02,
  t.task_description,
  t.wf_status_id,
  (SELECT status_designation FROM status WHERE status_id = t.wf_status_id) AS wf_status_name,
  t.status_id
FROM
  qrt q,
  cp cp,
  selection_detail sp,
  task t
WHERE 
  sp.object_id = cp.par_id
  AND sp.seldet_type = 'PAR_ID'
  AND t.sel_id = sp.sel_id
  AND t.tasktype_id = 530
  AND t.task_para_date_02 BETWEEN q.qrt_starts AND q.qrt_ends
  
  
SELECT DISTINCT status_id FROM retro WHERE calc_task_id = 10521
  

select * from SERVERTASK
order bY 1 desc


UPDATE task
  SET wf_status_id = 411
WHERE task_id = 12704  


SELECT * FROM payinstr_rule
ORDER BY 1 DESC

UPDATE pa



SELECT * FROM dsa_source
ORDER BY 1 DESC


SELECT * FROM servertask
ORDER BY 1 DESC