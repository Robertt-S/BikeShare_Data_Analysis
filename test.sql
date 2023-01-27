SELECT (started_at - ended_at)
FROM 2021_11_2022_10_bicycle
WHERE ride_id = '00001BEE76AB24E0';




CREATE TABLE
  test
(
int_numbers INT,
float_numbers FLOAT
);

CREATE TABLE
  test_transfer
(
int_numbers INT,
float_numbers FLOAT
);


INSERT INTO
  test
  (int_numbers, float_numbers)
VALUES
  (1, 1.1),
  (2, 2.2),
  (3, 3.3),
  (4, 4.4);

INSERT INTO
  test_transfer
  (int_numbers, float_numbers)
SELECT
  *
FROM
  test
LIMIT 2;


-- Searching for an specific error
SELECT
  COUNT(started_at), started_at, ended_at
FROM
  2021_11_2022_10_bicycle
WHERE
  RIGHT(started_at, 8) = '2:24:10"' 
  OR 
  RIGHT(ended_at, 8) = '2:24:10"'
LIMIT 10;



SELECT
  ride_duration, started_at, ended_at
FROM
  2021_11_2022_10_summarized_info
LIMIT 100;


SELECT
  ride_duration, started_at, ended_at
FROM
  2021_11_2022_10_summarized_info
WHERE
  LENGTH(ride_duration) = 9
LIMIT 100;

SELECT
  COUNT(*)
FROM
  2021_11_2022_10_summarized_info
WHERE
  LENGTH(ride_duration) = 9;

-- Time traveler...
SELECT 
  started_at, ended_at
FROM
  2021_11_2022_10_bicycle
WHERE
    SUBTIME(RIGHT(ended_at, 8), RIGHT(started_at, 8)) = '-00:28:59'
LIMIT 10;


SELECT 
  started_at, ended_at
FROM
  2021_11_2022_10_bicycle
WHERE
    SUBTIME(RIGHT(ended_at, 8), RIGHT(started_at, 8)) = '-23:49:19'
LIMIT 10;


SELECT
  started_at, ended_at, ADDTIME(ride_duration, 24:00:00)
FROM
  2021_11_2022_10_summarized_info
WHERE
  LENGTH(ride_duration) = 9
LIMIT 10;


SELECT
  COUNT(*)
FROM
  2021_11_2022_10_summarized_info
WHERE
  LENGTH(ride_duration) = 9
;




-- Checking arithmetic with datetime type

CREATE TABLE test
(
my_date0 DATETIME,
my_date1 DATETIME
);

INSERT INTO
  test
VALUES
  ('2010-10-10 12:00:00', '2010-10-12 12:00:00'),
  ('2010-10-10 12:00:00', '2010-10-14 00:00:00');


SELECT
  ADDTIME(my_date0, '2')
FROM
  test;








SELECT 
  start_station_name, end_station_name
FROM
  2021_11_2022_10_bicycle
WHERE
  start_lat = '41.65186780228521';
LIMIT 150;




SELECT
  started_at, ended_at
FROM
  bicycle_started_ended
WHERE
  ended_at < started_at;

SELECT
  SUBSTRING(
  TO_DAYS('date');
  


SELECT
  started_at, ended_at
FROM
  bicycle_started_ended
WHERE
  SUBSTRING(started_at, 6, 2) != SUBSTRING(ended_at, 6, 2);





CREATE TABLE test
(
id INT
);

CREATE TABLE test_where
(
id INT
);

INSERT INTO
  test
VALUES
  (1), (2), (3);

INSERT INTO
  test_from
VALUES
  (1), (2), (3);


DELETE 
  test,
  test_from,
  test_where
FROM 
  test
  INNER JOIN test_from ON test.id = test_from.id
  WHERE  test.id = 3;


DELETE 
  bicycle_rideable_type,
  bicycle_started_ended,
  bicycle_station_name_id,
  bicycle_latitude_longitude,
  bicycle_member_casual
FROM 
  bicycle_started_ended
INNER JOIN bicycle_rideable_type ON bicycle_started_ended.ride_id = bicycle_rideable_type.ride_id
INNER JOIN bicycle_station_name_id ON bicycle_started_ended.ride_id = bicycle_station_name_id.ride_id
INNER JOIN bicycle_latitude_longitude ON bicycle_started_ended.ride_id = bicycle_latitude_longitude.ride_id
INNER JOIN bicycle_member_casual ON bicycle_started_ended.ride_id = bicycle_member_casual.ride_id
WHERE 
  bicycle_started_ended.ended_at < bicycle_started_ended.started_at;


CREATE TABLE
  test
  (
  id INT,
  name VARCHAR(255)
  );
  
INSERT INTO
  test
VALUES
(1, 'Matheus'),
(2, 'Santos'),
(3, 'Marcos');

SELECT 
  id, name
FROM
    test

INTO OUTFILE '/data/data/com.termux/files/home/test.csv'
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';