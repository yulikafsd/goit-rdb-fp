-- Завдання 1

CREATE SCHEMA IF NOT EXISTS `pandemic`;

USE `pandemic`;

SELECT
	`Entity`,
    `Code`,
    `Year`,
    `Number_yaws`,
    `polio_cases`,
    `cases_guinea_worm`,
    `Number_rabies`,
    `Number_malaria`,
    `Number_hiv`,
    `Number_tuberculosis`,
    `Number_smallpox`,
    `Number_cholera_cases`
FROM `pandemic`.`infectious_cases`;

-- Завдання 2

CREATE TABLE IF NOT EXISTS entities (
	entity_id INT AUTO_INCREMENT PRIMARY KEY,
	entity VARCHAR(255) NOT NULL,
    entity_code VARCHAR(10)
);

INSERT INTO entities (entity, entity_code)
SELECT DISTINCT entity, code 
FROM infectious_cases;

SELECT * FROM entities;

CREATE TABLE infectious_cases_norm 
LIKE infectious_cases;

ALTER TABLE infectious_cases_norm
	DROP COLUMN Entity,
    DROP COLUMN Code,
	ADD COLUMN case_id INT AUTO_INCREMENT PRIMARY KEY FIRST,
    ADD COLUMN entity_id INT NOT NULL AFTER case_id,
    ADD FOREIGN KEY (entity_id) REFERENCES entities(entity_id);

INSERT INTO infectious_cases_norm (
    entity_id,
    Year,
	Number_yaws,
	polio_cases,
	cases_guinea_worm,
	Number_rabies,
	Number_malaria,
	Number_hiv,
	Number_tuberculosis,
	Number_smallpox,
	Number_cholera_cases)
SELECT
	e.entity_id,
	ic.Year,
	ic.Number_yaws,
	ic.polio_cases,
	ic.cases_guinea_worm,
	ic.Number_rabies,
	ic.Number_malaria,
	ic.Number_hiv,
	ic.Number_tuberculosis,
	ic.Number_smallpox,
	ic.Number_cholera_cases
FROM infectious_cases as ic
JOIN entities as e
	ON ic.entity = e.entity
    AND (ic.Code = e.entity_code OR (ic.Code IS NULL AND e.entity_code IS NULL));

SELECT 
	(SELECT COUNT(*) FROM infectious_cases) AS initial_number_of_rows, 
	(SELECT COUNT(*) FROM infectious_cases_norm) AS norm_number_of_rows;

-- Завдання 3

SELECT
	e.entity,
    e.entity_code,
    SUM(icn.Number_rabies) AS total_rabies,
	AVG(icn.Number_rabies) AS avg_rabies,
    MIN(icn.Number_rabies) AS min_rabies,
    MAX(icn.Number_rabies) AS max_rabies
FROM infectious_cases_norm as icn
JOIN entities AS e ON icn.entity_id = e.entity_id
WHERE icn.Number_rabies != '' 
AND Number_rabies IS NOT NULL
GROUP BY e.entity, e.entity_code
ORDER BY avg_rabies DESC
LIMIT 10;

-- Завдання 4

SELECT
	icn.year,
	MAKEDATE(icn.year, 1) AS case_year,
    CURDATE() AS cur_date,
    TIMESTAMPDIFF(YEAR, MAKEDATE(icn.Year, 1), CURDATE()) AS years_diff
FROM infectious_cases_norm as icn;

-- Завдання 5.1

DROP FUNCTION IF EXISTS Calc_diff;

DELIMITER //

CREATE FUNCTION Calc_diff(input_year INT)
RETURNS INT
NOT DETERMINISTIC 
NO SQL
BEGIN
    DECLARE diff INT;
    SET diff = TIMESTAMPDIFF(YEAR, MAKEDATE(input_year, 1), CURDATE());
    RETURN diff;
END //

DELIMITER ;

SELECT 
    icn.year,
	MAKEDATE(icn.year, 1) AS case_year,
    CURDATE() AS cur_date,
    Calc_diff(icn.year) AS diff
FROM infectious_cases_norm as icn;

-- Завдання 5.2

DROP FUNCTION IF EXISTS Calc_disease_freq;

DELIMITER //

CREATE FUNCTION Calc_disease_freq(
	input_quantity DOUBLE, 
	input_period INT
)
RETURNS DOUBLE
DETERMINISTIC 
NO SQL
BEGIN
    DECLARE freq DOUBLE;
    
    IF input_quantity IS NULL 
       OR input_quantity < 0 
       OR input_period NOT IN (2, 4, 12) 
	THEN
		RETURN NULL;
    END IF;
    
    SET freq = input_quantity / input_period;
    RETURN ROUND(freq, 2);
END //

DELIMITER ;

SET @period = 12;

SELECT
    icn.Year,
    Calc_disease_freq(SUM(NULLIF(icn.Number_yaws, '')), @period) AS yaws_avg,
    Calc_disease_freq(SUM(NULLIF(icn.polio_cases, '')), @period) AS polio_avg,
    Calc_disease_freq(SUM(NULLIF(icn.cases_guinea_worm, '')), @period) AS guinea_worm_avg,
    Calc_disease_freq(SUM(NULLIF(icn.Number_rabies, '')), @period) AS rabies_avg,
    Calc_disease_freq(SUM(NULLIF(icn.Number_malaria, '')), @period) AS malaria_avg,
    Calc_disease_freq(SUM(NULLIF(icn.Number_hiv, '')), @period) AS hiv_avg,
    Calc_disease_freq(SUM(NULLIF(icn.Number_tuberculosis, '')), @period) AS tuberculosis_avg,
    Calc_disease_freq(SUM(NULLIF(icn.Number_smallpox, '')), @period) AS smallpox_avg,
    Calc_disease_freq(SUM(NULLIF(icn.Number_cholera_cases, '')), @period) AS cholera_avg
FROM infectious_cases_norm AS icn
GROUP BY icn.Year
ORDER BY icn.Year ASC;

SET @period = 4;

SELECT
    icn.Year,
    Calc_disease_freq(SUM(NULLIF(icn.Number_yaws, '')), @period) AS yaws_avg,
    Calc_disease_freq(SUM(NULLIF(icn.polio_cases, '')), @period) AS polio_avg,
    Calc_disease_freq(SUM(NULLIF(icn.cases_guinea_worm, '')), @period) AS guinea_worm_avg,
    Calc_disease_freq(SUM(NULLIF(icn.Number_rabies, '')), @period) AS rabies_avg,
    Calc_disease_freq(SUM(NULLIF(icn.Number_malaria, '')), @period) AS malaria_avg,
    Calc_disease_freq(SUM(NULLIF(icn.Number_hiv, '')), @period) AS hiv_avg,
    Calc_disease_freq(SUM(NULLIF(icn.Number_tuberculosis, '')), @period) AS tuberculosis_avg,
    Calc_disease_freq(SUM(NULLIF(icn.Number_smallpox, '')), @period) AS smallpox_avg,
    Calc_disease_freq(SUM(NULLIF(icn.Number_cholera_cases, '')), @period) AS cholera_avg
FROM infectious_cases_norm AS icn
GROUP BY icn.Year
ORDER BY icn.Year ASC;

SET @period = 2;

SELECT
    icn.Year,
    Calc_disease_freq(SUM(NULLIF(icn.Number_yaws, '')), @period) AS yaws_avg,
    Calc_disease_freq(SUM(NULLIF(icn.polio_cases, '')), @period) AS polio_avg,
    Calc_disease_freq(SUM(NULLIF(icn.cases_guinea_worm, '')), @period) AS guinea_worm_avg,
    Calc_disease_freq(SUM(NULLIF(icn.Number_rabies, '')), @period) AS rabies_avg,
    Calc_disease_freq(SUM(NULLIF(icn.Number_malaria, '')), @period) AS malaria_avg,
    Calc_disease_freq(SUM(NULLIF(icn.Number_hiv, '')), @period) AS hiv_avg,
    Calc_disease_freq(SUM(NULLIF(icn.Number_tuberculosis, '')), @period) AS tuberculosis_avg,
    Calc_disease_freq(SUM(NULLIF(icn.Number_smallpox, '')), @period) AS smallpox_avg,
    Calc_disease_freq(SUM(NULLIF(icn.Number_cholera_cases, '')), @period) AS cholera_avg
FROM infectious_cases_norm AS icn
GROUP BY icn.Year
ORDER BY icn.Year ASC;