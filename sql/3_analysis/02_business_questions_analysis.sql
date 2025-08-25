-- This SQL file contains a series of queries designed to answer specific research questions
-- using the 'med_audit' table from the 'HealthTail' dataset.
-- Each query addresses a particular question related to medication spending, usage, and trends.

-- Initial exploration of the med_audit table to view a sample of its content.
SELECT * FROM `verdant-bruin-457710-r2.HealthTail.med_audit` LIMIT 100;

--1. What med did we spend the most money on in total?
-- This query calculates the total amount spent on purchasing each medication.
SELECT  med_name,                 -- Selects the medication name.
        SUM(total_value) AS total_spend     -- Sums the 'total_value' for each medication to get the total spend.
FROM `verdant-bruin-457710-r2.HealthTail.med_audit`
WHERE stock_movement = 'stock in'       -- Filters for records representing medication purchases ('stock in').
GROUP BY 1                              -- Groups the results by medication name (the first column selected).
ORDER BY 2 DESC;                        -- Orders the results by total spend (the second column selected) in descending order to show the highest spend first.
--Answer: Vetmedin (Pimobendan) with total spend of 1035780.0


--2. What med had the highest monthly total_value spent on patients? At what month? 
-- This query identifies the medication and month with the highest spending on patients (medication usage).
SELECT  month,                    -- Selects the month.
        med_name,                 -- Selects the medication name.
        SUM(total_value) AS total_spend     -- Sums the 'total_value' (cost of meds used by patients) for each medication per month.
FROM `verdant-bruin-457710-r2.HealthTail.med_audit`
WHERE stock_movement = 'stock out'      -- Filters for records representing medication usage by patients ('stock out').
GROUP BY 1, 2                           -- Groups the results by month and medication name.
ORDER BY 3 DESC;                        -- Orders by the total spend (third column) in descending order to find the highest monthly spend.
--Answer: Palladia (Toceranib Phosphate) in November 24, with total send of 50000


--3. What month was the highest in packs of meds spent in vet clinic?
-- This query determines which month had the highest number of medication packs used by the vet clinic.
SELECT  month,                    -- Selects the month.
        SUM(total_packs) AS packs       -- Sums the 'total_packs' used for each month.
FROM `verdant-bruin-457710-r2.HealthTail.med_audit`
WHERE stock_movement = 'stock out'      -- Filters for records representing medication usage ('stock out').
GROUP BY 1                              -- Groups the results by month.
ORDER BY 2 DESC;                        -- Orders by the total packs (second column) in descending order to find the month with highest pack usage.
--Answer: December 24 with total 3861.62 packs


-- 4. What’s an average monthly spent in packs of the med that generated the most revenue?
-- This query first identifies the medication that generated the most total revenue ('stock out')
-- and then calculates the average monthly usage in packs for that specific medication.

WITH TopMedByRevenue AS (
    -- Step 1: Find the name of the single medication with the highest total revenue.
    SELECT
        med_name
    FROM
        `verdant-bruin-457710-r2.HealthTail.med_audit`
    WHERE
        stock_movement = 'stock out'
    GROUP BY
        med_name
    ORDER BY
        SUM(total_value) DESC
    LIMIT 1
),
MonthlyPacksOfTopMed AS (
    -- Step 2: For this top medication, calculate the sum of packs used for each month.
    SELECT
        SUM(total_packs) AS total_monthly_packs
    FROM
        `verdant-bruin-457710-r2.HealthTail.med_audit`
    WHERE
        stock_movement = 'stock out'
        AND med_name = (SELECT med_name FROM TopMedByRevenue) -- Filter only by the top-performing medication
    GROUP BY
        month
)
-- Final step: Calculate the average of the monthly total packs.
SELECT
    AVG(total_monthly_packs) AS average_monthly_packs_for_top_med
FROM
    MonthlyPacksOfTopMed;
--Answer: 52,54 packs
