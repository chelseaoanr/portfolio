-- ==================================================
-- Data Cleaning Project
-- Dataset: World Layoffs
-- Objective: Clean and prepare raw layoff data for analysis
-- ==================================================

-- Step 1: Create staging tables

-- Step 2: Remove duplicates

-- Step 3: Standardize text values

-- Step 4: Convert dates

-- Step 5: Handle missing values

-- Step 6: Remove unnecessary rows

-- Step 7: Remove helper columns

-- ====================================================



-- Step 1: Create staging tables
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;


-- Step 2: Remove duplicates
SELECT *,
ROW_NUMBER () OVER(PARTITION BY company, industry, total_laid_off,percentage_laid_off, `date` ) AS row_num
FROM layoffs_staging;


WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER () OVER(
PARTITION BY company, location, industry, total_laid_off,percentage_laid_off, `date`) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;



WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER () OVER(PARTITION BY company, location, industry, total_laid_off,percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER () OVER(
PARTITION BY company, location, industry, total_laid_off,percentage_laid_off, `date`, stage
, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Remove duplicate records

SET SQL_SAFE_UPDATES = 0;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Re-enable safe updates
SET SQL_SAFE_UPDATES = 1;



-- Step 3: Standardize text values

UPDATE layoffs_staging2
SET company = TRIM(company);


SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


-- Step 4: Convert dates

SELECT `date`,
str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET date = str_to_date(`date`, '%m/%d/%Y');


SELECT `date`
FROM layoffs_staging2;


ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;



-- Step 5: Handle Null and Blank Values
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT DISTINCT * 
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = ' ';


SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = ' ')
AND t2.industry IS NOT NULL;

   
-- Populate missing industry values using matching company records

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2 
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- Step 6: Remove unnecessary rows

DELETE
FROM layoffs_staging2 
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- Step 7: Remove Helper Columns

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Rename Table 
RENAME TABLE layoffs_staging2 TO layoffs_cleaned;

SELECT COUNT(*) AS total_rows
FROM layoffs_cleaned;


SELECT COUNT(DISTINCT company) AS unique_companies
FROM layoffs_cleaned;


SELECT *
FROM layoffs_cleaned
LIMIT 10;

-- ==================================================
-- Data Cleaning Complete
-- Final Table: layoffs_cleaned
-- Ready for Exploratory Data Analysis
-- ==================================================