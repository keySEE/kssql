use GGT_Tracking

-- 1 Aggregate values of accuracy
SELECT 
	MIN(accuracy) minA
	, round(AVG(accuracy), 2) avgA
	, MAX(accuracy) maxA
FROM tracking_events

-- 2 distribution of GPS events by accuracy
;WITH
distribution as (
SELECT 
	case 
		when accuracy >=1 and accuracy < 2 then '1-2'
		when accuracy >=2 and accuracy < 3 then '2-3'
		when accuracy >=3 and accuracy < 5 then '3-5'
		when accuracy >=5 and accuracy < 10 then '5-10'
		when accuracy >=10 and accuracy < 20 then '10-20'
		when accuracy >=20 and accuracy < 50 then '20-50'
		when accuracy >=50 and accuracy < 100 then '50-100'
		when accuracy >= 100 then '100+'
		when accuracy is null then 'no data'
		else '10. other'
	end range
FROM tracking_events
)

SELECT 
	'Percents, %' 'Range'
	, cast(round(100 * sum(case when range = '1-2'		then 1 else 0 end) / cast(count(1) as float), 2) as decimal(10, 2)) '1-2'
	, cast(round(100 * sum(case when range = '2-3'		then 1 else 0 end) / cast(count(1) as float), 2) as decimal(10, 2)) '2-3'
	, cast(round(100 * sum(case when range = '3-5'		then 1 else 0 end) / cast(count(1) as float), 2) as decimal(10, 2)) '3-5'
	, cast(round(100 * sum(case when range = '5-10'		then 1 else 0 end) / cast(count(1) as float), 2) as decimal(10, 2)) '5-10'
	, cast(round(100 * sum(case when range = '10-20'	then 1 else 0 end) / cast(count(1) as float), 2) as decimal(10, 2)) '10-20'
	, cast(round(100 * sum(case when range = '20-50'	then 1 else 0 end) / cast(count(1) as float), 2) as decimal(10, 2)) '20-50'
	, cast(round(100 * sum(case when range = '50-100'	then 1 else 0 end) / cast(count(1) as float), 2) as decimal(10, 2)) '50-100'
	, cast(round(100 * sum(case when range = '100+'		then 1 else 0 end) / cast(count(1) as float), 2) as decimal(10, 2)) '100+'
	, cast(round(100 * sum(case when range = 'no data'	then 1 else 0 end) / cast(count(1) as float), 2) as decimal(10, 2)) 'no data'
	, cast(round(100 * sum(case when range = 'other'	then 1 else 0 end) / cast(count(1) as float), 2) as decimal(10, 2)) 'other'
FROM distribution