/* 
The issue:
1. A job is in planning
2. A job is moved to Soft Allocated status (ja.jobStatus = 13)
3. The job is missed out of planning

Solution:
1. Find jobs which were planned since the dedicated @startDate period
2. Find out duration between two consecutive planning executions
3. Filter out jobs which planned longer than pauseInMinutesBetweenAllocations interval
4. Filter out jobs which were Soft Allocated and then stopped to add in planning: (DATEDIFF(second, r.timestamp, p.nextPlanningExecution) > DATEDIFF(second, p.planningTimestamp, r.timestamp)

Result:
This script allowed to find out why jobs are missed out from planning and prepare fix for that
*/



DECLARE @startDate date = DATEADD(day,DATEDIFF(day, 1, GETDATE()), 0) -- since yesterday
DECLARE @pauseInMinutesBetweenAllocations int = 10;

;WITH
preselect as (
SELECT 
	jobid
	, planningTimestamp
	, lead(planningTimestamp, 1) OVER (ORDER BY jobid, planningTimestamp) as nextPlanningExecution
	, ROW_NUMBER() OVER (PARTITION BY jobid ORDER BY planningTimestamp DESC) as rank
	, DATEDIFF(mi, planningTimestamp, lead(planningTimestamp, 1) OVER (ORDER BY jobid, planningTimestamp)) diffExecutionsInMinutes
FROM autoallocations
WHERE 
	planningTimestamp > @startDate
	AND jobid IN
				( 
					SELECT 
						ja.id
					FROM jobs_aud ja
					JOIN REVINFO r ON r.id = ja.rev AND ja.jobStatus = 13
					WHERE 
						r.timestamp >  @startDate
				)
)

SELECT 
	p.jobid
	, p.planningTimestamp
	, p.nextPlanningExecution
	, p.diffExecutionsInMinutes
	, j.jobStatus
	, r.timestamp statusUpdateTime
	, r.username
FROM 
	preselect p
JOIN jobs_aud j ON j.id = p.jobid
JOIN REVINFO r ON r.id = j.rev
WHERE 
	diffExecutionsInMinutes > @pauseInMinutesBetweenAllocations
	AND DATEDIFF(second, r.timestamp, p.nextPlanningExecution) > DATEDIFF(second, p.planningTimestamp, r.timestamp)
	AND rank > 1
	AND jobstatus IN (13)
	AND r.timestamp > p.planningTimestamp
ORDER BY jobId