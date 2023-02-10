CREATE DATABASE bicycle_project;

USE bicycle_project;

-- Main table.
CREATE TABLE 2022_bicycle
(
ride_id VARCHAR(255),
rideable_type VARCHAR(255),
started_at DATETIME,
ended_at DATETIME,
start_station_name VARCHAR(255),
start_station_id VARCHAR(255),
end_station_name VARCHAR(255),
end_station_id VARCHAR(255),
start_lat VARCHAR(255),
start_lgn VARCHAR(255),
end_lat VARCHAR(255),
end_lgn VARCHAR(255),
member_casual VARCHAR(255),

PRIMARY KEY (ride_id)
);

-- temporary table to load the general data.
CREATE TABLE 2022_bicycle_tmp
(
ride_id VARCHAR(255),
rideable_type VARCHAR(255),
started_at VARCHAR(255),
ended_at VARCHAR(255),
start_station_name VARCHAR(255),
start_station_id VARCHAR(255),
end_station_name VARCHAR(255),
end_station_id VARCHAR(255),
start_lat VARCHAR(255),
start_lgn VARCHAR(255),
end_lat VARCHAR(255),
end_lgn VARCHAR(255),
member_casual VARCHAR(255)
);

-- Importing data.
LOAD DATA INFILE '~/2022_12.csv' 
INTO TABLE bicycle_project_2.2022_bicycle_tmp
FIELDS TERMINATED BY ',';




-- Searching for inconsistencies on the data.
{

SELECT MIN(LENGTH(started_at))
FROM 2022_bicycle_tmp;

SELECT MAX(LENGTH(started_at))
FROM 2022_bicycle_tmp;

SELECT MIN(LENGTH(ended_at))
FROM 2022_bicycle_tmp;

SELECT MAX(LENGTH(ended_at))
FROM 2022_bicycle_tmp;


-- The normal size of date and time data is 19–21 of length.
-- Let's check the lines that don't fit the requirement.

SELECT 
  ride_id, started_at, ride_id
FROM 
  2022_bicycle_tmp
WHERE 
  (LENGTH(started_at) != 19 AND LENGTH(started_at) != 21) OR (LENGTH(ended_at) != 19 AND LENGTH(ended_at) != 21)
LIMIT 100;


-- Counting how many length divergencies there are.
SELECT 
  COUNT(ride_id)
FROM 
  2022_bicycle_tmp
WHERE
  ride_id = 'ride_id' OR ride_id = '"ride_id"';


-- Cleaning the dirty rows.
DELETE FROM 2022_bicycle_tmp
WHERE started_at = 'started_at'
OR started_at = '"started_at"';

}


-- Deleting duplicates and time travelers.
{

SELECT 
  ride_id, 
  COUNT(ride_id)
FROM
  2022_bicycle_tmp
GROUP BY ride_id
HAVING COUNT(ride_id) > 1
LIMIT 100;


SELECT
  started_at, ended_at
FROM
  2022_bicycle_tmp
WHERE
  ended_at < started_at;


DELETE FROM
  2022_bicycle_tmp
WHERE
  ended_at < started_at;

}




-- Inserting the cleaned data in the 2022_bicycle table.
{

INSERT INTO
  2022_bicycle
  (ride_id,
  rideable_type,
  started_at,
  ended_at,
  start_station_name,
  start_station_id,
  end_station_name,
  end_station_id,
  start_lat,
  start_lgn,
  end_lat,
  end_lgn,
  member_casual)
SELECT
  ride_id,
  rideable_type,
  started_at,
  ended_at,
  start_station_name,
  start_station_id,
  end_station_name,
  end_station_id,
  start_lat,
  start_lgn,
  end_lat,
  end_lgn,
  member_casual
FROM
  2022_bicycle_tmp
WHERE
  LENGTH(started_at) = 19;

INSERT INTO
  2022_bicycle
  (ride_id,
  rideable_type,
  started_at,
  ended_at,
  start_station_name,
  start_station_id,
  end_station_name,
  end_station_id,
  start_lat,
  start_lgn,
  end_lat,
  end_lgn,
  member_casual)
SELECT
  SUBSTRING(ride_id, 2, LENGTH(ride_id) - 2),
  SUBSTRING(rideable_type, 2, LENGTH(rideable_type) - 2),
  SUBSTRING(started_at, 2, LENGTH(started_at) - 2),
  SUBSTRING(ended_at, 2, LENGTH(ended_at) - 2),
  SUBSTRING(start_station_name, 2, LENGTH(start_station_name) - 2),
  SUBSTRING(start_station_id, 2, LENGTH(start_station_id) - 2),
  SUBSTRING(end_station_name, 2, LENGTH(end_station_name) - 2),
  SUBSTRING(end_station_id, 2, LENGTH(end_station_id) - 2),
  start_lat,
  start_lgn,
  end_lat,
  end_lgn,
  SUBSTRING(member_casual, 2, LENGTH(member_casual) - 2)
FROM
  2022_bicycle_tmp
WHERE
  LENGTH(started_at) = 21;

}




-- Creating summary table.
{

CREATE TABLE ride_info
(
ride_id VARCHAR(255),
ride_duration TIME,
ride_started_date DATE,
ride_week_day INT
);


INSERT INTO
  ride_info
  (ride_id, ride_duration, ride_started_date, ride_week_day)
SELECT
  ride_id,
  CAST(ADDTIME(SEC_TO_TIME((TO_DAYS(LEFT(ended_at, 10)) - TO_DAYS(LEFT(started_at, 10))) * 86400), SUBTIME(RIGHT(ended_at, 8), RIGHT(started_at, 8))) AS TIME),
  LEFT(started_at, 10),
  DAYOFWEEK(started_at)
FROM
  2022_bicycle;

}




-- Creating general_info table: average ride duration, maximum ride duration, the day it most occurs rides,
-- the average ride duration for members and not members, the ride average duration by day of the week and
-- how many rides per day in a week
{

CREATE TABLE ride_info_scalar
(
info_name VARCHAR(255),
info_data VARCHAR(255)
);

CREATE TABLE ride_info_week
(
day_of_week VARCHAR(255),
average_ride_duration TIME,
rides_number INT
);


-- Coalescing week general data.
{

DROP PROCEDURE IF EXISTS generalInfoWeek;

DELIMITER $$

CREATE PROCEDURE generalInfoWeek(IN dayName VARCHAR(255))

BEGIN
  INSERT INTO
    ride_info_week
    (day_of_week, average_ride_duration, rides_number)
  SELECT
    dayName,
    CAST(SEC_TO_TIME(AVG(TIME_TO_SEC(ride_duration))) AS TIME),
    COUNT(ride_week_day)
  FROM
    ride_info
  WHERE
    DAYNAME(ride_started_date) = dayName;
END $$

DELIMITER ;


CALL generalInfoWeek('Monday');
CALL generalInfoWeek('Tuesday');
CALL generalInfoWeek('Wednesday');
CALL generalInfoWeek('Thursday');
CALL generalInfoWeek('Friday');
CALL generalInfoWeek('Saturday');
CALL generalInfoWeek('Sunday');

}


-- CAST to remove the dirty decimal right numbers
INSERT INTO
  ride_info_scalar
  (info_name, info_data)
SELECT
  'Average Ride Duration',
  CAST(SEC_TO_TIME(AVG(TIME_TO_SEC(ride_duration))) AS TIME)
FROM
  ride_info;


-- CONVERT to compare numbers properly.
INSERT INTO
  ride_info_scalar
  (info_name, info_data)
SELECT
  'Max Ride Duration',
  CAST(SEC_TO_TIME(MAX(TIME_TO_SEC(ride_duration))) AS TIME)
FROM
  ride_info;


INSERT INTO
  ride_info_scalar
  (info_name, info_data)
SELECT
  'Most Rides Day',
  day_of_week
FROM
  ride_info_week
WHERE
  (
  SELECT
    MAX(rides_number)
  FROM
    ride_info_week
  )
  <= rides_number;


INSERT INTO
  ride_info_scalar
  (info_name, info_data)
SELECT
  'Average Ride Duration (Members)',
  CAST(SEC_TO_TIME(AVG(TIME_TO_SEC(ADDTIME(SEC_TO_TIME((TO_DAYS(LEFT(ended_at, 10)) - TO_DAYS(LEFT(started_at, 10))) * 86400), SUBTIME(RIGHT(ended_at, 8), RIGHT(started_at, 8)))))) AS TIME)
FROM
  2022_bicycle
WHERE
  member_casual = 'member';


INSERT INTO
  ride_info_scalar
  (info_name, info_data)
SELECT
  'Average Ride Duration (Casuals)',
  CAST(SEC_TO_TIME(AVG(TIME_TO_SEC(ADDTIME(SEC_TO_TIME((TO_DAYS(LEFT(ended_at, 10)) - TO_DAYS(LEFT(started_at, 10))) * 86400), SUBTIME(RIGHT(ended_at, 8), RIGHT(started_at, 8)))))) AS TIME)
FROM
  2022_bicycle
WHERE
  member_casual = 'casual';


-- coalescing month information.
{

CREATE TABLE ride_info_month
(
month VARCHAR(255),
rides_number INT,
average_ride_duration TIME
);


DROP PROCEDURE IF EXISTS monthInfo;

DELIMITER $$

CREATE PROCEDURE monthInfo (IN monthName VARCHAR(255))

BEGIN
  INSERT INTO
    ride_info_month
    (month, rides_number, average_ride_duration)
  SELECT
    monthName,
    COUNT(*),
    CAST(SEC_TO_TIME(AVG(TIME_TO_SEC(ride_duration))) AS TIME)
  FROM
    ride_info
  WHERE
    MONTHNAME(ride_started_date) = monthName;
END $$

DELIMITER ;


CALL monthInfo('January');
CALL monthInfo('February');
CALL monthInfo('March');
CALL monthInfo('April');
CALL monthInfo('May');
CALL monthInfo('June');
CALL monthInfo('July');
CALL monthInfo('August');
CALL monthInfo('September');
CALL monthInfo('October');
CALL monthInfo('November');
CALL monthInfo('December');

}

}




-- Exporting ride_info table
{

(
SELECT
  'ride_id', 'ride_duration', 'ride_started_date', 'ride_week_day'
)
UNION

SELECT
  ride_id, ride_duration, ride_started_date, ride_week_day
FROM
  ride_info

INTO OUTFILE '/data/data/com.termux/files/home/2022_bicycle_ride_info.csv'
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

}


-- Exporting ride_info_week table.
{

(
SELECT
  'day_of_week', 'average_ride_duration', 'rides_number'
)
UNION

SELECT
  day_of_week, average_ride_duration, rides_number
FROM
  ride_info_week

INTO OUTFILE '/data/data/com.termux/files/home/2022_bicycle_general_info_week.csv'
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

}


-- Exporting ride_info_month table.
{

(
SELECT
  'month', 'rides_number', 'average_ride_duration'
)
UNION

SELECT
  month, rides_number, average_ride_duration
FROM
  ride_info_month

INTO OUTFILE '/data/data/com.termux/files/home/2022_bicycle_ride_info_month.csv'
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

}


-- Exporting ride_info_scalar table.
{

(
SELECT
  'info_name', 'info_data'
)
UNION

SELECT
  info_name, info_data
FROM
  ride_info_scalar

INTO OUTFILE '/data/data/com.termux/files/home/2022_bicycle_ride_info_scalar.csv'
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

}


--Exporting 2022_bicycle
{

(
SELECT
  'ride_id', 'rideable_type', 'started_at', 'ended_at',
  'start_station_name', 'start_station_id', 'end_station_name',
  'end_station_id', 'start_lat', 'start_lgn', 'end_lat',
  'end_lgn', 'member_casual'
)
UNION

SELECT
  *
FROM
  2022_bicycle

INTO OUTFILE '/data/data/com.termux/files/home/2022_bicycle.csv'
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

}