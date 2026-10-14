CREATE DATABASE customer_support_analytics;

 USE customer_support_analytics;
select * from customer_support_tickets;

-- SET GLOBAL local_infile = 1;
 -- SHOW VARIABLES LIKE 'local_infile';

CREATE TABLE customer_support_tickets (
    ticket_id INT,
    customer_name VARCHAR(100),
    customer_email VARCHAR(150),
    customer_age INT,
    customer_gender VARCHAR(20),
    product_purchased VARCHAR(100),
    date_of_purchase DATE,
    ticket_type VARCHAR(100),
    ticket_subject VARCHAR(200),
    ticket_description TEXT,
    ticket_status VARCHAR(100),
    resolution TEXT,
    ticket_priority VARCHAR(50),
    ticket_channel VARCHAR(50),
    first_response_time DATETIME,
    time_to_resolution VARCHAR(50),
    customer_satisfaction_rating DECIMAL(3,1)
);
   LOAD DATA LOCAL INFILE 'F:/acer laptop data 22-2-26/Documents/Data Analytics/Projects/Customer Support Operations Analytics/customer_support_tickets_raw.csv'
    INTO TABLE customer_support_tickets
   FIELDS TERMINATED BY ','
   OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 ROWS;

select * 
from customer_support_tickets
limit 10;

-- DESCRIBE customer_support_tickets;

-- DATA QUALITY CHECK

SELECT COUNT(*) AS total_tickets         -- result: 8469
FROM customer_support_tickets;            


-- checking for duplicate ticket ID          result: empty set
SELECT
    ticket_id,
    COUNT(*) AS duplicate_count
FROM customer_support_tickets
GROUP BY ticket_id
HAVING COUNT(*) > 1;

-- checking for null values                  result: empty set
SELECT
    SUM(ticket_id IS NULL) AS ticket_id_missing,
    SUM(customer_name IS NULL) AS customer_name_missing,
    SUM(customer_email IS NULL) AS customer_email_missing,
    SUM(customer_age IS NULL) AS customer_age_missing,
    SUM(customer_gender IS NULL) AS customer_gender_missing,
    SUM(product_purchased IS NULL) AS product_missing,
    SUM(date_of_purchase IS NULL) AS purchase_date_missing,
    SUM(ticket_type IS NULL) AS ticket_type_missing,
    SUM(ticket_subject IS NULL) AS subject_missing,
    SUM(ticket_description IS NULL) AS description_missing,
    SUM(ticket_status IS NULL) AS status_missing,
    SUM(resolution IS NULL) AS resolution_missing,
    SUM(ticket_priority IS NULL) AS priority_missing,
    SUM(ticket_channel IS NULL) AS channel_missing,
    SUM(first_response_time IS NULL) AS response_time_missing,
    SUM(time_to_resolution IS NULL) AS resolution_time_missing,
    SUM(customer_satisfaction_rating IS NULL) AS rating_missing
FROM customer_support_tickets;

-- checking for empty strings                  result: blank_resolution 5700
SELECT
    SUM(TRIM(customer_name) = '') AS blank_customer_name,
    SUM(TRIM(customer_email) = '') AS blank_email,
    SUM(TRIM(product_purchased) = '') AS blank_product,
    SUM(TRIM(ticket_type) = '') AS blank_ticket_type,
    SUM(TRIM(ticket_subject) = '') AS blank_subject,
    SUM(TRIM(ticket_description) = '') AS blank_description,
    SUM(TRIM(ticket_status) = '') AS blank_status,
    SUM(TRIM(resolution) = '') AS blank_resolution,
    SUM(TRIM(ticket_priority) = '') AS blank_priority,
    SUM(TRIM(ticket_channel) = '') AS blank_channel
FROM customer_support_tickets;

-- checking for customer age                   result: between 18 to 70
SELECT
    MIN(customer_age) AS minimum_age,
    MAX(customer_age) AS maximum_age,
    AVG(customer_age) AS average_age
FROM customer_support_tickets;

-- suspicious age values                       result: empty set
SELECT
    ticket_id,
    customer_age
FROM customer_support_tickets
WHERE customer_age < 18
   OR customer_age > 100;

-- checking gender inconsistency                   result: consistent 
SELECT
    customer_gender,
    COUNT(*) AS ticket_count
FROM customer_support_tickets
GROUP BY customer_gender
ORDER BY ticket_count DESC;

-- checking ticket status inconsistency               result: consistent 
SELECT
    ticket_status,
    COUNT(*) AS ticket_count
FROM customer_support_tickets
GROUP BY ticket_status
ORDER BY ticket_count DESC;

-- checking ticket priority inconsistency               result: consistent 
SELECT
    ticket_priority,
    COUNT(*) AS ticket_count
FROM customer_support_tickets
GROUP BY ticket_priority
ORDER BY ticket_count DESC;

-- checking ticket channel inconsistency              result: consistent 
SELECT
    ticket_channel,
    COUNT(*) AS ticket_count
FROM customer_support_tickets
GROUP BY ticket_channel
ORDER BY ticket_count DESC;

-- checking ticket type 
SELECT
    ticket_type,
    COUNT(*) AS ticket_count
FROM customer_support_tickets
GROUP BY ticket_type
ORDER BY ticket_count DESC;

-- checking product name inconsistency                result: consistent 
SELECT
    product_purchased,
    COUNT(*) AS ticket_count
FROM customer_support_tickets
GROUP BY product_purchased
ORDER BY ticket_count DESC; 

-- checking date of purchase range
SELECT
    MIN(date_of_purchase) AS earliest_purchase,
    MAX(date_of_purchase) AS latest_purchase
FROM customer_support_tickets;

-- checking purchase date null values                   result: empty set 
SELECT COUNT(*) AS missing_purchase_dates
FROM customer_support_tickets
WHERE date_of_purchase IS NULL;

-- checking for response time                           result: 0000-00-00 00:00:00	2023-06-02 00:54:00
SELECT
    MIN(first_response_time) AS earliest_response,
    MAX(first_response_time) AS latest_response
FROM customer_support_tickets;

-- checking null values in response time                result: 0
SELECT COUNT(*) AS missing_response_times
FROM customer_support_tickets
WHERE first_response_time IS NULL;

-- checking for customer satisfaction score                      result: 0.0   5.0	 0.97804
SELECT                                                       
   MIN(customer_satisfaction_rating) AS minimum_rating,
   MAX(customer_satisfaction_rating) AS maximum_rating,
   AVG(customer_satisfaction_rating) AS average_rating
FROM customer_support_tickets;

-- checking css range:
SELECT
	customer_satisfaction_rating,
	COUNT(*) AS rating_count
FROM customer_support_tickets
GROUP BY customer_satisfaction_rating
ORDER BY customer_satisfaction_rating;

-- checking for time to resolution missing values 
SELECT
    ticket_status,                            -- result: time_to_resolution is missing for Open and Pending Customer Response tickets, 
    COUNT(*) AS total_tickets,                -- which is expected because these tickets have not been closed. 
    SUM(                                      -- All Closed tickets have a resolution timestamp.
        time_to_resolution IS NULL
        OR TRIM(time_to_resolution) = ''
    ) AS missing_resolution_time
FROM customer_support_tickets
GROUP BY ticket_status;

-- checking for 0000 dates in first response time            result: 2819
SELECT
    COUNT(*) AS zero_response_dates
FROM customer_support_tickets
WHERE YEAR(first_response_time) = 0;   

SELECT
    ticket_id,
    ticket_status,
    first_response_time,
    time_to_resolution
FROM customer_support_tickets
WHERE YEAR(first_response_time) = 0;

-- checking duplicate customer emails 
SELECT
    customer_email,
    COUNT(*) AS ticket_count
FROM customer_support_tickets
GROUP BY customer_email
HAVING COUNT(*) > 1
ORDER BY ticket_count DESC;

SELECT
    ticket_id,
    customer_email
FROM customer_support_tickets
WHERE customer_email IN (
    SELECT customer_email
    FROM customer_support_tickets
    GROUP BY customer_email
    HAVING COUNT(*) > 1
)
ORDER BY customer_email, ticket_id;


-- Data Quality Finding:
-- Multiple tickets can belong to the same customer email.
-- This is not considered a duplicate because ticket_id is unique.
-- Repeated customer emails may represent repeat customers.

-- Data Quality Finding:
-- 2,819 Open tickets contain 0000-00-00 00:00:00
-- in first_response_time.
-- This appears to represent a missing first response timestamp.

-- Data Quality Finding:
-- All 2,881 Pending Customer Response tickets have a blank
-- time_to_resolution value.
-- This is expected because these tickets have not been resolved.
