-- ==================================================
-- Exploratory Data Analysis Project
-- Dataset: World Layoffs
-- Cleaned Table: layoffs_cleaned
-- ==================================================

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_cleaned;


SELECT *
FROM layoffs_cleaned
WHERE percentage_laid_off = 1;



