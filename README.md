# Data Cleaning in MySQL - World Layoffs Dataset

## **Overview**

This project focuses on cleaning a dataset of worldwide layoffs using MySQL. The raw dataset contains inconsistencies, missing values, and formatting errors that must be addressed before conducting meaningful analysis. By applying best practices in data cleaning, we ensure that the dataset is well-structured, accurate, and ready for further exploration.

## **Goals and Key Questions**

- How can we remove duplicate records while preserving data integrity?
- What inconsistencies exist in the dataset, and how can we standardize them?
- How should missing values be handled (imputation vs. removal)?
- Are all data types correctly assigned for analysis?

## **Dataset**

Tech firms worldwide have been laying off employees due to economic challenges like slow consumer spending, rising interest rates, and a strong dollar. This dataset tracks tech industry layoffs from **March 11, 2020, to July 20, 2024**, based on reports from Bloomberg, TechCrunch, The New York Times, and other sources.

The dataset includes:

- **Company Name:** The organization that issued the layoffs.
- **Location:** The city or country where the layoffs occurred.
- **Industry:** The sector in which the company operates.
- **Number of Employees Laid Off:** The total number of employees affected.
- **Percentage of Workforce Laid Off:** The proportion of the company’s workforce impacted.
- **Date of Layoffs:** The specific date of the layoff event.
- **Funding Raised (in Millions):** The total financial backing the company has received.

## **Data Cleaning Steps**

### **1. Removing Duplicates**

- Used row numbering and partitioning techniques to identify duplicate records.
- Applied filtering strategies to eliminate redundant duplicate rows while retaining one accurate entry.

**SQL Query:**

```sql
DELETE FROM layoffs_staging
WHERE id NOT IN (
    SELECT MIN(id) FROM layoffs_staging
    GROUP BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
);
```

### **2. Standardizing Data**

- Trimmed extra spaces in company names and locations.
- Unified industry categories for consistency (e.g., combining “Crypto” and “Cryptocurrency” into one category).
- Standardized country names by removing unnecessary punctuation (e.g., “United States.” → “United States”).

**SQL Query:**

```sql
-- Trim spaces from company names
UPDATE layoffs_staging
SET company = TRIM(company);

-- Standardize industry names
UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry IN ('Cryptocurrency', 'crypto', 'CryptoCurrency');

-- Remove trailing periods from country names
UPDATE layoffs_staging
SET country = TRIM(TRAILING '.' FROM country);
```

### **3. Handling Missing Values**

- Identified missing values in critical fields such as industry and layoff counts.
- Filled in missing industry data by referencing existing company records.
- Evaluated whether specific missing values should be removed based on their impact on data quality.

**SQL Query:**

```sql
-- Populate missing industry names using existing company records
UPDATE layoffs_staging t1
JOIN layoffs_staging t2 ON t1.company = t2.company AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;
```

### **4. Changing Data Types**

- Converted the date column from text format to a proper **DATE** type to support time-based analysis.
- Ensured numerical columns were stored in appropriate **INTEGER** or **FLOAT** data types for accurate calculations.

**SQL Query:**

```sql
-- Convert date column from TEXT to DATE format
UPDATE layoffs_staging
SET date = STR_TO_DATE(date, '%m/%d/%Y');

-- Modify column type to store converted DATE values
ALTER TABLE layoffs_staging
MODIFY COLUMN date DATE;
```

## **SQL Scripts Used**

All data cleaning operations were performed using SQL queries, which are included in the `data_cleaning.sql` script. This script covers:

- Table creation and dataset import
- Duplicate removal logic
- Standardization queries
- Handling of missing values
- Data type conversions

## **Future Recommendations**

- **Exploratory Data Analysis (EDA):** Now that the data is clean, further analysis can help uncover trends in layoffs over time, across industries, and based on funding levels.
- **Visualization Dashboards:** Tools like **Tableau** or **Power BI** can be used to create interactive reports and visualizations.
- **Predictive Modeling:** Machine learning techniques could be applied to predict future layoffs based on industry trends and economic conditions.

## **Usage Instructions**

1. Run the `data_cleaning.sql` script in **MySQL Workbench** or any compatible database management tool.
2. Verify the cleaned dataset by executing:
    
    ```sql
    SELECT * FROM layoffs_staging;
    ```
    
3. Use the cleaned data for further analysis, visualization, or reporting.

This project demonstrates how structured data cleaning can transform messy datasets into valuable assets for business insights and decision-making.