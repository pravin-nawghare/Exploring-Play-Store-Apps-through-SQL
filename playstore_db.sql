-- Create a database to store data
CREATE DATABASE playstore_db;

-- Create a table to store the data
CREATE TABLE playstore (
	App TEXT,
	Category VARCHAR(20), 
	Rating FLOAT,
	Reviews INT(11),
	Size VARCHAR(10),
	Installs INT(11), 
	Type VARCHAR(20), 
	Price INT(11), 
	Content_Rating VARCHAR(20), 
	Genres TEXT, 
	Last_Updated DATE, 
	Current_Ver VARCHAR(10), 
	Android_Ver VARCHAR(20)
);

-- Load the data into table
LOAD DATA INFILE "ENTER YOUR FILE LOCATION"
INTO TABLE YOUR_TABLE_NAME
FIELDS TERMINATED BY ","
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
