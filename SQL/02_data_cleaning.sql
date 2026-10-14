 USE customer_support_analytics;

CREATE TABLE customer_support_tickets_clean LIKE customer_support_tickets;
INSERT INTO customer_support_tickets_clean
SELECT
    ticket_id,
    customer_name,
    customer_email,
    customer_age,
    customer_gender,
    product_purchased,
    date_of_purchase,
    ticket_type,
    ticket_subject,
    ticket_description,
    ticket_status,
    resolution,
    ticket_priority,
    ticket_channel,

    CASE
        WHEN YEAR(first_response_time) = 0 THEN NULL
        ELSE first_response_time
    END AS first_response_time,

    time_to_resolution,
    customer_satisfaction_rating

FROM customer_support_tickets;

-- checking all rows imported                          result: 8469
SELECT
    COUNT(*) AS total_clean_records
FROM customer_support_tickets_clean;

-- checking for 0 dates in clean table                  result:0
SELECT
    COUNT(*) AS zero_first_response_dates
FROM customer_support_tickets_clean
WHERE YEAR(first_response_time) = 0;

-- checking for null first_response_time records in clean table   result: 2819
SELECT
    COUNT(*) AS missing_first_response
FROM customer_support_tickets_clean
WHERE first_response_time IS NULL;


-- adding a new column 
ALTER TABLE customer_support_tickets_clean
ADD COLUMN resolution_datetime DATETIME;

-- Convert the text-based time_to_resolution values into a proper DATETIME column named resolution_datetime.
UPDATE customer_support_tickets_clean
SET resolution_datetime =
    CASE
        WHEN TRIM(time_to_resolution) = '' THEN NULL
        ELSE STR_TO_DATE(time_to_resolution, '%m/%d/%Y %H:%i')
    END;


-- checking for the rows where resolution_datetime< first_response_time       result: 1365 rows 
SELECT
    COUNT(*) AS resolution_before_response
FROM customer_support_tickets_clean
WHERE resolution_datetime IS NOT NULL
  AND first_response_time IS NOT NULL
  AND resolution_datetime < first_response_time;


-- checking for all negative duration values 
SELECT
    ticket_id,
    first_response_time,
    resolution_datetime,
    TIMESTAMPDIFF(
        MINUTE,
        first_response_time,
        resolution_datetime
    ) AS difference_minutes
FROM customer_support_tickets_clean
WHERE resolution_datetime IS NOT NULL
  AND first_response_time IS NOT NULL
  AND resolution_datetime < first_response_time
LIMIT 20;


-- checking for tickets having both timestamps, incorrect records timestamps and correct record timestamps       result: 2769	1365	1404
SELECT
    COUNT(*) AS total_with_resolution,
    SUM(
        resolution_datetime < first_response_time
    ) AS resolution_before_response,
    SUM(
        resolution_datetime >= first_response_time
    ) AS valid_resolution_order
FROM customer_support_tickets_clean
WHERE resolution_datetime IS NOT NULL
  AND first_response_time IS NOT NULL;


-- checking for the valid vs invalid records as percentages             result: 49.30	50.70
SELECT
    ROUND(
        100 * SUM(resolution_datetime < first_response_time) / COUNT(*),
        2
    ) AS invalid_resolution_percentage,
    ROUND(
        100 * SUM(resolution_datetime >= first_response_time) / COUNT(*),
        2
    ) AS valid_resolution_percentage
FROM customer_support_tickets_clean
WHERE resolution_datetime IS NOT NULL
  AND first_response_time IS NOT NULL;

-- creating a new column for calculating duration btw both time stamps 
ALTER TABLE customer_support_tickets_clean
ADD COLUMN resolution_duration_minutes INT;

-- calculating duration 
UPDATE customer_support_tickets_clean
SET resolution_duration_minutes =
    CASE
        WHEN first_response_time IS NOT NULL
             AND resolution_datetime IS NOT NULL
             AND resolution_datetime >= first_response_time
        THEN TIMESTAMPDIFF(
            MINUTE,
            first_response_time,
            resolution_datetime
        )
        ELSE NULL
    END;


-- Invalid resolution timestamps are retained for traceability,
-- but their resolution duration is set to NULL because
-- resolution_datetime occurs before first_response_time.


-- checking for min, max and avg resolution duration                    result: min 0, max 1408, avg 454.68
SELECT
    MIN(resolution_duration_minutes) AS min_minutes,
    MAX(resolution_duration_minutes) AS max_minutes,
    ROUND(AVG(resolution_duration_minutes), 2) AS avg_minutes
FROM customer_support_tickets_clean
WHERE resolution_duration_minutes IS NOT NULL;


-- checking for customer_satisfaction_rating descrepency                      result: min: 0, max: 5, total: 8469
SELECT
    MIN(customer_satisfaction_rating) AS min_rating,
    MAX(customer_satisfaction_rating) AS max_rating,
    COUNT(*) AS total_ratings
FROM customer_support_tickets_clean
WHERE customer_satisfaction_rating IS NOT NULL;


-- checking for count records of each rating 
SELECT
    customer_satisfaction_rating,
    COUNT(*) AS ticket_count
FROM customer_support_tickets_clean
GROUP BY customer_satisfaction_rating
ORDER BY customer_satisfaction_rating;


-- checking for ticket status of records which has 0 satisfaction score              result: pending: 2881, open: 2819
SELECT
    ticket_status,
    COUNT(*) AS zero_rating_tickets
FROM customer_support_tickets_clean
WHERE customer_satisfaction_rating = 0
GROUP BY ticket_status
ORDER BY zero_rating_tickets DESC;

-- replacing rating 0 to null 
UPDATE customer_support_tickets_clean
SET customer_satisfaction_rating = NULL
WHERE customer_satisfaction_rating = 0;

-- Verifying that rating 0 values were replaced with NULL                 result: 0
SELECT
    COUNT(*) AS remaining_zero_ratings
FROM customer_support_tickets_clean
WHERE customer_satisfaction_rating = 0;

-- Verifying the final customer satisfaction rating distribution          
SELECT
    customer_satisfaction_rating,
    COUNT(*) AS ticket_count
FROM customer_support_tickets_clean
GROUP BY customer_satisfaction_rating
ORDER BY customer_satisfaction_rating;
