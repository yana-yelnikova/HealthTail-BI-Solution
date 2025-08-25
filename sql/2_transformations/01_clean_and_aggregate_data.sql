-- This SQL script creates a new table named 'registration_clean' in the 'HealthTail' dataset.
-- The purpose is to clean and standardize data from the original 'reg_cards' table.
CREATE OR REPLACE TABLE `verdant-bruin-457710-r2.HealthTail.registration_clean` AS
WITH
  -- CTE 1: cleaned_breed
  -- This CTE standardizes the 'breed' information from the 'reg_cards' table.
  cleaned_breed AS (
    SELECT
      patient_id,
      owner_name,      -- Owner's name, carried over as is.
      owner_phone,     -- Owner's phone number, carried over for further cleaning in the next CTE.
      -- Standardize the 'breed' column:
      -- If 'breed' is NULL, an empty string, or 'unknown' (case-insensitive), it's replaced with 'Unknown'.
      -- Otherwise, the original breed name is kept.
      CASE
        WHEN breed IS NULL OR breed = '' OR LOWER(breed) = 'unknown' THEN 'Unknown'
        ELSE breed
      END AS breed,
      patient_name     -- Patient's name, carried over as is for now.
    FROM
      `verdant-bruin-457710-r2.HealthTail.reg_cards` -- The source table containing raw registration card data.
  ),
  -- CTE 2: cleaned_phone
  -- This CTE takes the output from 'cleaned_breed' and standardizes the 'owner_phone' numbers.
  cleaned_phone AS (
    SELECT
      patient_id,
      owner_name,      -- Owner's name, passed through from 'cleaned_breed'.
      -- Standardize 'owner_phone':
      -- If the phone number starts with a '+', preserve the '+' and remove all non-numeric characters from the rest of the string.
      -- Otherwise (if it doesn't start with '+'), remove all non-numeric characters from the entire string.
      CASE
        WHEN STARTS_WITH(owner_phone, '+') THEN '+' || REGEXP_REPLACE(SUBSTR(owner_phone, 2), '[^0-9]', '')
        ELSE REGEXP_REPLACE(owner_phone, '[^0-9]', '')
      END AS owner_phone, 
      breed,           -- Standardized breed from 'cleaned_breed'.
      patient_name     -- Patient's name, passed through from 'cleaned_breed'.
    FROM
      cleaned_breed      -- Input for
