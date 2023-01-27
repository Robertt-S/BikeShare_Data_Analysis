-- Queries to storage the data.





SELECT
  *
FROM
  2021_11_2022_10_bicycle_formatted
WHERE
  ADDTIME(SEC_TO_TIME((TO_DAYS(LEFT(ended_at, 10)) - TO_DAYS(LEFT(started_at, 10))) * 86400), SUBTIME(RIGHT(ended_at, 8), RIGHT(started_at, 8))) > '100:00:00'
LIMIT 100 \G


SELECT
  CAST(SEC_TO_TIME(AVG(TIME_TO_SEC(ride_duration))) AS TIME)
FROM
  ride_info;
WHERE
  ride_duration < '100:00:00';
  
  
  
  
SELECT
  name,
  COUNT(name)
FROM
  (
  SELECT
    name
  FROM
    test
  WHERE
    name IN('Marcia', 'Marcos')
  ) AS derived_1
GROUP BY
  name;




SELECT 
  family AS 'Bird Family', COUNT(*) AS 'Number of Birds' 
FROM
  (
  SELECT
    families.scientific_name AS family 
  FROM
    birds
  JOIN 
    bird_families AS families USING(family_id)
  WHERE
    families.scientific_name IN('Pelecanidae','Ardeidae')
  ) AS derived_1 
GROUP BY family;




CREATE TABLE test
(
  id INT,
  name varchar(255)
);


INSERT INTO
  test
  (name)
SELECT
  'Test';

}


SELECT
 COUNT(*)
FROM
  ride_info
WHERE
  ride_duration > '24:00:00';
  
CREATE TABLE outliers LIKE 2021_11_2022_10_bicycle_formatted;





CREATE TABLE
  test2
(
id INT,
profession VARCHAR(255)
);


INSERT INTO
  test2
VALUES
  (1, 'Baiano'),
  (2, 'Xuxa');


CREATE TABLE
  test3
(
id VARCHAR(255)
);


INSERT INTO
  test3
SELECT
  test.id
FROM
  test
JOIN
  test2
WHERE
  test.id = test2.id;
  


SELECT
  *
FROM
  ride_info
JOIN
  bicycle_member_casual
WHERE
  bicycle_member_casual.ride_id = ride_info.ride_id
LIMIT 1000 \G



SELECT
  ride_info.ride_id
FROM
  ride_info
JOIN
  bicycle_member_casual
WHERE
  ride_info.ride_id = bicycle_member_casual.ride_id
  AND
  bicycle_member_casual.member_casual = 'member'
LIMIT 100;




CREATE TABLE test
(
ride_duration VARCHAR(255)
);

INSERT INTO
  test
VALUES
  ('1.999999'),
  ('3.33333'),
  ('7.77777777');


ALTER TABLE
  test
CHANGE COLUMN ride_duration ride_duration FLOAT(1,10);



UPDATE 
  test
SET ride_duration = TIME_TO_SEC(ride_duration);


UPDATE
  ride_info
SET ride_duration = CONVERT(ride_duration, DECIMAL(12, 10));



SELECT
  AVG(TIME_TO_SEC(ADDTIME(SEC_TO_TIME((TO_DAYS(LEFT(ended_at, 10)) - TO_DAYS(LEFT(started_at, 10))) * 86400), SUBTIME(RIGHT(ended_at, 8), RIGHT(started_at, 8))))) AS 'Average Ride Duration'
FROM
  2022_bicycle
WHERE
  member_casual = 'member';




SELECT
  TIME_TO_SEC(ADDTIME(SEC_TO_TIME((TO_DAYS(LEFT(ended_at, 10)) - TO_DAYS(LEFT(started_at, 10))) * 86400), SUBTIME(RIGHT(ended_at, 8), RIGHT(started_at, 8)))) AS 'Average Ride Duration'
FROM
  2022_bicycle
WHERE
  member_casual = 'member';




CREATE TABLE father
(
ID VARCHAR(255),
name VARCHAR(255)
);


CREATE TABLE child
(
ID VARCHAR(255),
phone_number VARCHAR(255)
);


INSERT INTO
  father
VALUES
  ('ABC', 'João'),
  ('DEF', 'Maria');
  
INSERT INTO
  child
VALUES
  ('ABC', '123'),
  ('DEF', '456');



ALTER TABLE
  father
ADD PRIMARY KEY (ID);

ALTER TABLE
  child
ADD FOREIGN KEY (ID) REFERENCES father(ID)
ON DELETE CASCADE
ON UPDATE CASCADE;




CREATE TABLE customer (  
  ID INT NOT NULL AUTO_INCREMENT,  
  Name varchar(50) NOT NULL,  
  City varchar(50) NOT NULL,  
  PRIMARY KEY (ID)  
);



CREATE TABLE contact (  
  ID INT,  
  Customer_Id INT,  
  Customer_Info varchar(50) NOT NULL,  
  Type varchar(50) NOT NULL,  
  INDEX par_ind (Customer_Id),  
  CONSTRAINT fk_customer FOREIGN KEY (Customer_Id)  
  REFERENCES customer(ID)  
  ON DELETE CASCADE  
  ON UPDATE CASCADE  
);


ALTER TABLE
  child
DROP FOREIGN KEY fk_ID;


SELECT
  ride_week_day,
  COUNT(ride_week_day)
FROM
  (
  SELECT
    ride_week_day
  FROM
    ride_info
  WHERE
    ride_week_day IN('1', '2', '3', '4', '5', '6', '7')
  ) AS derived_1
GROUP BY
  ride_week_day;


SELECT
  day_of_week
FROM
  ride_info_week
WHERE
  MAX(rides_number) = rides_number;
  
  
CREATE TABLE test
(
value DECIMAL(10,2)
)






DROP PROCEDURE LoopDemo;

DELIMITER $$
CREATE PROCEDURE LoopDemo()
BEGIN
	DECLARE x  INT;
	DECLARE str  VARCHAR(255);
        
	SET x = 1;
	SET str =  '';
        
	loop_label:  LOOP
		IF  x > 10 THEN 
			LEAVE  loop_label;
		END  IF;
            
		SET  x = x + 1;
		IF  (x mod 2) THEN
			ITERATE  loop_label;
		ELSE
			SET  str = CONCAT(str,x,',');
		END  IF;
	END LOOP;
	SELECT str;
END$$

DELIMITER ;




CREATE TABLE ride_info_month
(
month VARCHAR(255),
rides_number INT,
average_ride_duration DECIMAL(8,4)
);



DROP PROCEDURE IF EXISTS monthInfo;

DELIMITER $$

CREATE PROCEDURE monthInfo (IN monthName VARCHAR(255), IN monthNumber VARCHAR(255))

BEGIN
  INSERT INTO
    ride_info_month
    (month, rides_number, average_ride_duration)
  SELECT
    monthName,
    COUNT(*),
    AVG(ride_duration)
  FROM
    ride_info
  WHERE
    SUBSTRING(ride_started_date, 6, 2) = monthNumber;

END $$

DELIMITER ;








DROP PROCEDURE IF EXISTS monthInfo;

DELIMITER $$

CREATE PROCEDURE monthInfo (IN monthName VARCHAR(255), IN monthNumber VARCHAR(255))

BEGIN
  SELECT
    COUNT(*)
  FROM
    ride_info
  WHERE
    SUBSTRING(ride_started_date, 6, 2) = monthNumber;

END $$

DELIMITER ;


CALL monthInfo('January', '01');
CALL monthInfo('February', '02');
CALL monthInfo('March', '03');
CALL monthInfo('April', '04');
CALL monthInfo('May', '05');
CALL monthInfo('June', '06');
CALL monthInfo('July', '07');
CALL monthInfo('August', '08');
CALL monthInfo('September', '09');
CALL monthInfo('October', '10');
CALL monthInfo('November', '11');
CALL monthInfo('December', '12');








DELIMITER //

CREATE FUNCTION CalcIncome ( starting_value INT )
RETURNS INT

BEGIN

   DECLARE income INT;

   SET income = 0;

   label1: WHILE income <= 3000 DO
     SET income = income + starting_value;
   END WHILE label1;

   RETURN income;

END; //

DELIMITER ;






DROP PROCEDURE IF EXISTS monthInfo;

DELIMITER $$

CREATE PROCEDURE monthInfo (IN monthName VARCHAR(255))

BEGIN
  
  
  
  SELECT
    monthName,
    COUNT(*),
    AVG(ride_duration)
  FROM
    ride_info
  WHERE
    MONTHNAME(ride_started_date) = monthName;
    
END $$

DELIMITER ;