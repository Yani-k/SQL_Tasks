-- ============================================
-- Postgres Data Cleaning Reference File
-- Includes table schema and detailed explanations in comments for each step.
-- ============================================

-- Example schema for demonstration
-- This sample schema will be used throughout the cleaning queries.
CREATE TABLE my_table (
    id SERIAL PRIMARY KEY,          -- Unique identifier for each row
    name TEXT,                      -- Person or entity name
    city TEXT,                      -- City name, may contain inconsistent formats
    score NUMERIC,                  -- Numeric score, may contain NULLs
    amount TEXT,                    -- Amount stored as text (to be converted)
    salary NUMERIC,                 -- Employee salary
    order_date TEXT,                -- Order date stored as text
    updated_at TIMESTAMP            -- Timestamp for last update
);

-- Mapping table for correcting city names
CREATE TABLE mapping_table (
    city_wrong TEXT,                 -- Incorrect or short city name
    city_correct TEXT                 -- Correct standardized city name
);

-- 1. REMOVE DUPLICATES (keeping the most recent record)
-- This query deletes duplicate rows based on 'id', keeping the one with the latest 'ctid'.
DELETE FROM my_table a
USING my_table b
WHERE a.ctid < b.ctid  -- ctid is a unique row identifier in Postgres
  AND a.id = b.id;     -- duplicate criteria: same id value

-- Alternatively: select unique latest rows without deleting
SELECT DISTINCT ON (id) *
FROM my_table
ORDER BY id, updated_at DESC; -- keeps the latest updated record per id

-- 2. HANDLE MISSING VALUES
-- COALESCE() replaces NULLs with a specified default value.
-- For numbers, you can fill NULL with an average using a window function.
SELECT COALESCE(name, 'Unknown') AS name_clean,
       COALESCE(score, AVG(score) OVER()) AS score_filled
FROM my_table;

-- 3. STANDARDIZE TEXT FORMATTING
-- TRIM() removes extra spaces, UPPER()/LOWER() standardizes casing.
-- REPLACE() can correct inconsistent abbreviations or spelling.
SELECT UPPER(TRIM(name)) AS name_upper,
       REPLACE(city, 'NYC', 'New York') AS city_full
FROM my_table;

-- 4. NORMALIZE DATA TYPES AND FORMATS
-- Convert a column to a numeric type for calculations.
ALTER TABLE my_table
ALTER COLUMN amount TYPE numeric USING amount::numeric;

-- Standardize date formats for consistency.
SELECT TO_DATE(order_date, 'YYYY-MM-DD') AS clean_date
FROM my_table;

-- 5. HANDLE OUTLIERS
-- Filter rows within a valid range. Useful for sanity-checking numeric values.
SELECT *
FROM my_table
WHERE salary BETWEEN 30000 AND 200000;

-- 6. ENFORCE DATA INTEGRITY
-- Prevent invalid values by adding a CHECK constraint.
ALTER TABLE my_table
ADD CONSTRAINT chk_salary CHECK (salary > 0);

-- Ensure important columns are always populated.
ALTER TABLE my_table
ALTER COLUMN name SET NOT NULL;

-- 7. CORRECT DATA ERRORS USING A MAPPING TABLE
-- Update incorrect city names using a reference mapping table.
UPDATE my_table t
SET city = m.city_correct
FROM mapping_table m
WHERE t.city = m.city_wrong;

-- 8. USE WINDOW FUNCTIONS FOR CLEANING
-- Assign row numbers within each id group to identify duplicates.
SELECT id, name, score,
       ROW_NUMBER() OVER (PARTITION BY id ORDER BY updated_at DESC) AS rn
FROM my_table;

-- Remove duplicates while keeping only the latest record.
WITH ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY id ORDER BY updated_at DESC) AS rn
  FROM my_table
)
DELETE FROM ranked WHERE rn > 1;
