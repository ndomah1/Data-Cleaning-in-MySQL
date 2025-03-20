-- Create a new database
CREATE DATABASE layoffs_db;
USE layoffs_db;

-- Create a staging table for raw data import
CREATE TABLE layoffs_raw (
    company VARCHAR(255),
    location VARCHAR(255),
    industry VARCHAR(255),
    total_laid_off INT,
    percentage_laid_off FLOAT,
    date TEXT,  -- Initially stored as TEXT for later conversion
    stage VARCHAR(255),
    country VARCHAR(255),
    funds_raised_millions FLOAT
);

-- Import the dataset (this step is done manually via MySQL Workbench or a script)

-- Create a cleaned version of the table
CREATE TABLE layoffs_staging AS
SELECT * FROM layoffs_raw;

-- Step 1: Remove duplicates
DELETE FROM layoffs_staging 
WHERE id NOT IN (
    SELECT MIN(id) FROM layoffs_staging 
    GROUP BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
);

-- Step 2: Standardize company names (trim extra spaces)
UPDATE layoffs_staging 
SET company = TRIM(company);

-- Step 3: Standardize industry names (merge inconsistent names)
UPDATE layoffs_staging 
SET industry = 'Crypto' 
WHERE industry IN ('Cryptocurrency', 'crypto', 'CryptoCurrency');

-- Step 4: Fix country name formatting (remove trailing periods)
UPDATE layoffs_staging 
SET country = TRIM(TRAILING '.' FROM country);

-- Step 5: Handle missing values
-- Populate missing industry names where possible using existing company data
UPDATE layoffs_staging t1
JOIN layoffs_staging t2 ON t1.company = t2.company AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- Step 6: Convert date column from TEXT to DATE format
UPDATE layoffs_staging 
SET date = STR_TO_DATE(date, '%m/%d/%Y');

-- Step 7: Modify the column type to store the converted DATE values
ALTER TABLE layoffs_staging 
MODIFY COLUMN date DATE;

-- Step 8: Remove rows with missing critical values (optional step)
DELETE FROM layoffs_staging WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Final check: View cleaned dataset
SELECT * FROM layoffs_staging LIMIT 10;
