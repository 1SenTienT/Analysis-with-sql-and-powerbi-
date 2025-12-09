-- 1. Create and use the database
CREATE DATABASE IF NOT EXISTS projects;
USE projects;

-- 2. Manually create the hr table with your required columns
DROP TABLE IF EXISTS hr;

CREATE TABLE hr (
    id VARCHAR(20),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    birthdate VARCHAR(50),
    gender VARCHAR(50),
    race VARCHAR(100),
    department VARCHAR(100),
    jobtitle VARCHAR(150),
    location VARCHAR(150),
    hire_date VARCHAR(50),
    termdate VARCHAR(50),
    location_city VARCHAR(150),
    location_state VARCHAR(150)
);

-- 3. Load your CSV file (replace the file path if needed)
LOAD DATA LOCAL INFILE 'C:/Users/Decagon Laptop/Downloads/Human Resources.csv'
INTO TABLE hr
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

-- 4. Convert birthdate formats
SET sql_safe_updates = 0;

UPDATE hr
SET birthdate = CASE
    WHEN birthdate LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr MODIFY COLUMN birthdate DATE;

-- 5. Convert hire_date formats
UPDATE hr
SET hire_date = CASE
    WHEN hire_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr MODIFY COLUMN hire_date DATE;

-- 6. Convert termdate (UTC → date)
UPDATE hr
SET termdate = DATE(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

UPDATE hr
SET termdate = DATE(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate LIKE '%UTC%';

-- Replace blank or invalid values with NULL (fixes Error 1292)
UPDATE hr
SET termdate = NULL
WHERE termdate = '' OR termdate = ' ' OR termdate IS NULL;

-- Now safely convert column to DATE
ALTER TABLE hr MODIFY COLUMN termdate DATE;

-- 7. Add and calculate age
ALTER TABLE hr ADD COLUMN age INT;

UPDATE hr
SET age = TIMESTAMPDIFF(YEAR, birthdate, CURDATE());

-- 8. Basic checks
SELECT MIN(age) AS youngest, MAX(age) AS oldest FROM hr;
SELECT COUNT(*) FROM hr WHERE age < 18;
SELECT COUNT(*) FROM hr WHERE termdate > CURDATE();
SELECT COUNT(*) 
FROM hr 
WHERE termdate IS NULL;
SELECT location FROM hr;