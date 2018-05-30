-- list of jobs created from iOS or Android with contact and passenger details

SELECT 
	j.id job
	, convert(date, j.jobDate) jobDate
	, case 
		when j.creationType = 3 then 'Android'
		when j.creationType = 2 then 'iOS'
	end as creationType
	, c.fullName contactFullName
	, c.primaryPhone contactPhone
	, p.name passengerName
	, p.mobile mobilePhone
FROM jobs j
JOIN contacts c ON c.id = j.contact_id
LEFT JOIN job_passengers jp ON jp.job_id = j.id
LEFT JOIN passengers p ON p.id = jp.passenger_id
WHERE 1 = 1
AND j.creationtype IN (2, 3)
AND j.jobStatus IN (7, 10)
AND j.creationDate > '2017-12-01'
AND (c.fullName <> ISNULL(p.name, '') AND c.primaryEmail <> ISNULL(p.mobile, ''))
ORDER BY j.creationType, j.id


-- number of jobs created from iOS or Android for a specific time
SELECT 
	 case 
		when j.creationType = 3 then 'Android'
		when j.creationType = 2 then 'iOS'
	end as creationType
	, count(1) qty
FROM jobs j
JOIN contacts c ON c.id = j.contact_id
LEFT JOIN job_passengers jp ON jp.job_id = j.id
LEFT JOIN passengers p ON p.id = jp.passenger_id
WHERE 1 = 1
AND j.creationtype IN (2, 3)
AND j.jobStatus IN (7, 10)
AND j.creationDate > '2017-12-01'
AND (c.fullName <> ISNULL(p.name, '') AND c.primaryEmail <> ISNULL(p.mobile, ''))
GROUP BY creationType


-- quantity of jobs created by iOS or Android users
SELECT 
	distinct
	ca.number + ' - ' + ca.name as customerAccount
	, c.fullName contactFullName
	, c.primaryPhone contactPhone
	, count(1) qty
FROM jobs j
JOIN contacts c ON c.id = j.contact_id
JOIN customer_accounts ca ON ca.id = j.customer_account_id
LEFT JOIN job_passengers jp ON jp.job_id = j.id
LEFT JOIN passengers p ON p.id = jp.passenger_id
WHERE 1 = 1
AND j.creationtype IN (2, 3)
AND j.jobStatus IN (7, 10)
AND j.creationDate > '2017-12-01'
AND (c.fullName <> ISNULL(p.name, '') AND c.primaryEmail <> ISNULL(p.mobile, ''))
GROUP BY ca.number, ca.name, c.fullName, c.primaryPhone
ORDER BY qty DESC