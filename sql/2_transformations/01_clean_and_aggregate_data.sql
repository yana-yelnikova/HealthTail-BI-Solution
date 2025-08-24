-- This SQL script creates a new table named 'registration_clean' in the 'health_tail_cleaned' dataset.
-- The purpose is to clean and standardize data from the original 'reg_cards' table.
CREATE TABLE `sprint-1-457714.health_tail_cleaned.registration_clean` AS
WITH
  -- CTE 1: cleaned_breed
  -- This CTE standardizes the 'breed' information from the 'reg_cards' table.
  cleaned_breed AS (
    SELECT
      patient_id,
      owner_name,       -- Owner's name, carried over as is.
      owner_phone,      -- Owner's phone number, carried over for further cleaning in the next CTE.
      -- Standardize the 'breed' column:
      -- If 'breed' is NULL, an empty string, or 'unknown' (case-insensitive), it's replaced with 'Unknown'.
      -- Otherwise, the original breed name is kept.
      CASE
        WHEN breed IS NULL OR breed = '' OR LOWER(breed) = 'unknown' THEN 'Unknown'
        ELSE breed
      END AS breed,
      patient_name      -- Patient's name, carried over as is for now.
    FROM
      `sprint-1-457714.health_tail.reg_cards` -- The source table containing raw registration card data.
  ),
  -- CTE 2: cleaned_phone
  -- This CTE takes the output from 'cleaned_breed' and standardizes the 'owner_phone' numbers.
  cleaned_phone AS (
    SELECT
      patient_id,
      owner_name,       -- Owner's name, passed through from 'cleaned_breed'.
      -- Standardize 'owner_phone':
      -- If the phone number starts with a '+', preserve the '+' and remove all non-numeric characters from the rest of the string.
      -- Otherwise (if it doesn't start with '+'), remove all non-numeric characters from the entire string.
      CASE
        WHEN STARTS_WITH(owner_phone, '+') THEN '+' || REGEXP_REPLACE(SUBSTR(owner_phone, 2), '[^0-9]', '')
        ELSE REGEXP_REPLACE(owner_phone, '[^0-9]', '')
      END AS owner_phone, 
      breed,              -- Standardized breed from 'cleaned_breed'.
      patient_name        -- Patient's name, passed through from 'cleaned_breed'.
    FROM
      cleaned_breed       -- Input for this CTE is the result of 'cleaned_breed'.
  )
-- Final SELECT statement to construct the 'registration_clean' table.
-- It joins the original 'reg_cards' table with the 'cleaned_phone' CTE
-- to combine original uncleaned fields with the newly cleaned ones.
SELECT
  r.patient_id,                         -- Original patient ID.
  r.owner_id,                           -- Original owner ID.
  r.owner_name,                         -- Original owner's name.
  r.pet_type,                           -- Original pet type.
  cp.breed,                             -- Standardized breed from 'cleaned_phone' CTE.
  UPPER(cp.patient_name) AS patient_name, -- Patient's name from 'cleaned_phone' CTE, converted to uppercase.
  r.gender,                             -- Original pet gender.
  r.patient_age,                        -- Original patient age.
  r.date_registration,                  -- Original date of registration.
  cp.owner_phone                        -- Standardized owner's phone number from 'cleaned_phone' CTE.
FROM
  `sprint-1-457714.health_tail.reg_cards` r -- Alias the original table as 'r'.
JOIN
  cleaned_phone cp ON r.patient_id = cp.patient_id; -- Join based on 'patient_id' to link original records with their cleaned 'breed', 'patient_name', and 'owner_phone'.





-- This SQL script creates a new table named 'med_audit' in the 'health_tail_cleaned' dataset.
-- The purpose of this table is to track the monthly movement of medications,
-- by consolidating both purchases (stock in) from the 'invoices' table
-- and medication usage during visits (stock out) from the 'visits' table.
CREATE TABLE `sprint-1-457714.health_tail_cleaned.med_audit` AS
SELECT
    month,            -- The month of the transaction (formatted as YYYY-MM-01).
    med_name,         -- Standardized name of the medication.
    total_packs,      -- Total number of medication packs (either purchased or used).
    total_value,      -- Total monetary value associated with the packs (cost of purchase or cost of medication used).
    stock_movement    -- Type of stock movement: 'stock in' for purchases, 'stock out' for usage.
  FROM
    ( -- This subquery defines and then combines monthly medication inflows (purchases) and outflows (usage).
      WITH
        -- CTE 1: invoices_monthly
        -- This CTE aggregates data from the 'invoices' table to calculate
        -- total medications purchased (stock in) per month for each medication.
        invoices_monthly AS (
          SELECT
            FORMAT_DATE('%Y-%m-01', month_invoice) AS month, -- Standardize the invoice month to the first day of that month.
            -- Standardize medication names for consistency across different data sources.
            CASE
              WHEN med_name = 'Clavamox (Amoxicillin + Clavulanic)' THEN 'Clavamox (Amoxicillin/Clavulanic)'
              WHEN med_name = 'Arthroflex' THEN 'ArthriFlex'
              ELSE med_name
            END AS med_name,
            SUM(packs) AS total_packs,          -- Calculate the total number of packs purchased for each medication per month.
            SUM(total_price) AS total_value,    -- Calculate the total cost of these purchases.
            'stock in' AS stock_movement        -- Label these transactions as 'stock in' (medication received).
          FROM
            `sprint-1-457714.health_tail.invoices` -- Source table containing medication purchase invoices.
          GROUP BY
            month, med_name                     -- Group results by month and standardized medication name for aggregation.
        ),
        -- CTE 2: visits_monthly
        -- This CTE aggregates data from the 'visits' table to calculate
        -- total medications used (stock out) per month for each medication prescribed.
        visits_monthly AS (
          SELECT
            FORMAT_DATE('%Y-%m-01', CAST(visit_datetime AS DATE)) AS month, -- Standardize the visit month (from visit_datetime) to the first day of that month.
            -- Standardize medication names (from prescriptions) to match the naming in invoices_monthly.
            CASE
              WHEN med_prescribed = 'Clavamox (Amoxicillin + Clavulanic)' THEN 'Clavamox (Amoxicillin/Clavulanic)'
              WHEN med_prescribed = 'Arthroflex' THEN 'ArthriFlex'
              ELSE med_prescribed
            END AS med_name,
            SUM(med_dosage) AS total_packs,     -- Calculate total packs used (med_dosage represents share of a full package).
            SUM(med_cost) AS total_value,       -- Calculate the total cost of medications prescribed/used during visits.
            'stock out' AS stock_movement       -- Label these transactions as 'stock out' (medication dispensed/used).
          FROM
            `sprint-1-457714.health_tail.visits` -- Source table containing patient visit records.
          GROUP BY
            month, med_name                     -- Group results by month and standardized medication name for aggregation.
        )
      -- Combine the aggregated purchase data (stock in) and usage data (stock out).
      SELECT
        month,
        med_name,
        total_packs,
        total_value,
        stock_movement
      FROM
        invoices_monthly -- Select all records from the monthly purchases CTE.
      UNION ALL -- Combine with all records from the monthly usage CTE.
                -- UNION ALL is used because 'stock in' and 'stock out' records for the same month/medication are distinct events.
      SELECT
        month,
        med_name,
        total_packs,
        total_value,
        stock_movement
      FROM
        visits_monthly -- Select all records from the monthly usage CTE.
    )
;
