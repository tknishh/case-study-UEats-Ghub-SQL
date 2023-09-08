-- Checking All fields
SELECT * FROM `arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours` LIMIT 5;

-- understanding UNNEST
CREATE TEMP FUNCTION jsonObjectKeys(input STRING)
RETURNS Array<String>
LANGUAGE js AS """
  return Object.keys(JSON.parse(input));
""";
WITH keys AS (
  SELECT
    jsonObjectKeys(response) AS keys
  FROM
    `arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours`
  WHERE response IS NOT NULL
)
SELECT
  DISTINCT k
FROM keys
CROSS JOIN UNNEST(keys.keys) AS k
ORDER BY k

-- Extracting business hours from the response field
WITH schedule_rules AS (
  SELECT 
    JSON_EXTRACT_SCALAR(value, '$.days_of_week[0]') AS day,
    JSON_EXTRACT_SCALAR(value, '$.from') AS open_time,    
    JSON_EXTRACT_SCALAR(value, '$.to') AS close_time
  FROM `arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours`, 
  UNNEST(JSON_EXTRACT(response, '$.availability_by_catalog.STANDARD_DELIVERY.schedule_rules')) AS value 
)

SELECT 
  day, 
  open_time,
  close_time
FROM schedule_rules

-- Using function
CREATE FUNCTION ExtractHours(json STRING)
RETURNS ARRAY<STRING>
LANGUAGE js AS """
  const hours = json.availability_by_catalog.STANDARD_DELIVERY.schedule_rules;
  
  return hours.map(rule => {
    return rule.days_of_week[0] + ':' + 
           rule.from + '-' + 
           rule.to;
  });
""";

SELECT
  response,
  ExtractHours(response) AS hours 
FROM `arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours`;


-- nested JSON extract
SELECT 
  vb_name,
  JSON_EXTRACT(response, '$.availability_by_catalog.STANDARD_DELIVERY.schedule_rules') as sch
FROM 
  `arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours` LIMIT 5;


-- Prefinal Query to extract JSON data.

WITH schedule_rules AS (

  SELECT 
    vb_name,
    JSON_EXTRACT_SCALAR(value, '$.from') AS open_time,    
    JSON_EXTRACT_SCALAR(value, '$.to') AS close_time  
  FROM `arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours`,
   UNNEST(JSON_QUERY_ARRAY(response, 
     '$.availability_by_catalog.STANDARD_DELIVERY.schedule_rules')) AS value
)

SELECT * 
FROM schedule_rules