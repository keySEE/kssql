-- show records when new scheduler executions starts before the current execution has been finished

with prep as (
SELECT startTime, duration, dateadd(ms, duration, startTime) finishTime, lead(startTime, 1) OVER (ORDER BY id) as nextExecution
FROM continuous_scheduler_executions
WHERE startTime > '2018-04-24 12:00'
)

SELECT *
FROM prep
WHERE finishTime > nextExecution
ORDER BY startTime desc