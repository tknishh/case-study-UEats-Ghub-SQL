-- Checking all fields
SELECT *
FROM `arboreal-vision-339901.take_home_v2.virtual_kitchen_ubereats_hours`
LIMIT 5;

-- Reviewed schema and retrieving reg_hours
SELECT
      JSON_EXTRACT(value, "$.regularHours.endTime") AS end_time,  
      JSON_EXTRACT(value, "$.regularHours.startTime") AS start_time
FROM 
  `arboreal-vision-339901.take_home_v2.virtual_kitchen_ubereats_hours`,
  UNNEST(JSON_QUERY_ARRAY(response, '$.data.menus.sections')) as value