-- select jobs
SELECT j.id job, j.jobDate, j.jobstatus, jcdl.name,jcdl.applied,jcdl.units,jcdl.uom,jcdl.comments
FROM jobs j
 JOIN customer_accounts ca ON ca.id = j.customer_account_id
 JOIN pricing_groups pg ON pg.id = ca.pricing_group_id AND pg.name = 'Standard'
 JOIN job_calculation_detail_line jcdl ON jcdl.calculation_result_id = j.pricing_result_id /*and jcdl.applied=1*/ AND jcdl.name IN ('Peak AM Surcharge','Peak PM Surcharge')
WHERE j.invoicingStatus = 0
 AND j.jobStatus NOT IN (9)
 AND jcdl.overrideByUser <> 1
 AND j.jobDate > '2018-01-01'
ORDER BY j.id DESC, jcdl.positionIndex


-- update jobs
UPDATE jcdl 
 SET 
  overrideByUser = 1,
  overrideNetByUser = 1,
  overridePrice = 1,
  comments = ISNULL(comments + ' ' + '-- marked as manually changed by Magenta on request #9180', '-- marked as manually changed by Magenta on request #9180')
FROM jobs j
 JOIN customer_accounts ca ON ca.id = j.customer_account_id
 JOIN pricing_groups pg ON pg.id = ca.pricing_group_id AND pg.name = 'Standard'
 JOIN job_calculation_detail_line jcdl ON jcdl.calculation_result_id = j.pricing_result_id /*and jcdl.applied=1*/ AND jcdl.name IN ('Peak AM Surcharge','Peak PM Surcharge')
WHERE  j.invoicingStatus = 0
 AND j.jobStatus NOT IN (9)
 AND jcdl.overrideByUser <> 1
 AND j.jobDate > '2018-01-01'
