USE playstore_db; -- specify which database to be used if you have multiple database

/* 1. What are the top 5 app categories based average user rating which are free to use? */
SELECT 
    category, ROUND(AVG(rating), 2) AS avg_rating
FROM
    playstore
WHERE
    type = 'free'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

/* 2. Which category of app generates most revenue(in paid category). Give top 3. Round the revenue to 2 decimal place.
      (revenue is calculated as price * number of installations)? */
SELECT 
    category, AVG(price * installs) AS revenue
FROM
    playstore
WHERE
    type = 'paid'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

/* 3. Give distribution of apps in every category in terms of count and percentage? */
SELECT 
    *,
    ((cnt / (SELECT 
            COUNT(*)
        FROM
            playstore)) * 100) AS percent
FROM
    (SELECT 
        category, COUNT(*) AS cnt
    FROM
        playstore
    GROUP BY 1) x;

/* 4. Recommend companies to develop apps as 'free' or 'paid' for each category, based on average user rating. Sort the result in 
      alphabetical order. Result should contain category, free_app_rating, paid_app_rating, decision */
SELECT 
    *,
    IF(free_rating > paid_rating,
        'develop free app',
        'develop paid app') AS decision
FROM
    (SELECT 
        x.category, free_rating, paid_rating
    FROM
        (SELECT 
        category, ROUND(AVG(rating), 2) AS free_rating
    FROM
        playstore
    WHERE
        type = 'free'
    GROUP BY 1) x
    INNER JOIN (SELECT 
        category, ROUND(AVG(rating), 2) AS paid_rating
    FROM
        playstore
    WHERE
        type = 'paid'
    GROUP BY 1) y ON x.category = y.category
    GROUP BY 1) a;

/* 5. Create a trigger to track changes made in prices of apps. Store the result in a seperate table. Show both the tables original table as well
   as new table? */

CREATE TABLE pricechange (
    app VARCHAR(255),
    new_price DECIMAL(10 , 2 ),
    old_price DECIMAL(10 , 2 ),
    operation_type VARCHAR(255),
    operation_time TIMESTAMP
);
    
CREATE TABLE duplicate_playstore AS SELECT * FROM   -- creating new duplicate table so original table remain intact
    playstore;

DELIMITER //      -- create trigger on table duplicate_playstore
CREATE TRIGGER price_change_log1
AFTER UPDATE
ON duplicate_playstore
FOR EACH ROW
BEGIN
	INSERT INTO pricechange( app, new_price, old_price, operation_type, operation_time)
    VALUES (new.app, new.price, old.price, 'update', CURRENT_TIMESTAMP());
END;
// DELIMITER ;

-- make some changes so the trigger can activate
UPDATE duplicate_playstore   -- change 1
SET 
    price = 4
WHERE
    app = 'Paper flowers instructions';

UPDATE duplicate_playstore   -- change 2
SET 
    price = 10
WHERE
    reviews = 159;

-- final result
UPDATE duplicate_playstore1 AS a
        INNER JOIN
    pricechange AS b ON a.app = b.app 
SET 
    a.price = b.old_price;

-- correlation between rating and reviews
/* 6. In genres column there are multiple values in a single row. Create another genre in seperate column, if there is only one genre 
then leave the new column blank? */
DELIMITER // -- function to extract 1 genre
CREATE FUNCTION f1_name(a VARCHAR(255))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
	SET @l = LOCATE(';',a);
    SET @s = IF (@l>0, LEFT(a,@l-1), a);
	RETURN @s;
END
// DELIMITER ;

DELIMITER // -- another function to extract 2nd genre
CREATE FUNCTION f3_name(a VARCHAR(255))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
	SET @l = LOCATE(';',a);
    SET @s = IF (@l=0,' ',SUBSTRING(a,@l+1, LENGTH(a)));
	RETURN @s;
END
// DELIMITER ;

SELECT 
    genres,
    F1_NAME(genres) AS first_genre,
    F3_NAME(genres) AS second_genre
FROM
    playstore;
