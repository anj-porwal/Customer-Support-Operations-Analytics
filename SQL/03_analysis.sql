USE customer_support_analytics;

-- Analysis 1: Support workload by ticket status
SELECT
    ticket_status,
    COUNT(*) AS total_tickets,
    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM customer_support_tickets_clean),
        2
    ) AS percentage_of_tickets
FROM customer_support_tickets_clean
GROUP BY ticket_status
ORDER BY total_tickets DESC;


-- Analysis 2: Ticket Volume by Priority
SELECT
    ticket_priority,
    COUNT(*) AS total_tickets,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM customer_support_tickets_clean),
        2
    ) AS percentage_of_tickets
FROM customer_support_tickets_clean
GROUP BY ticket_priority
ORDER BY total_tickets DESC;


-- Analysis 3: Ticket Priority vs. Ticket Status
SELECT
    ticket_priority,
    ticket_status,
    COUNT(*) AS total_tickets
FROM customer_support_tickets_clean
GROUP BY
    ticket_priority,
    ticket_status
ORDER BY
    ticket_priority,
    total_tickets DESC;


-- Analysis 4: Ticket Volume by Support Channel
SELECT
     ticket_channel,
     COUNT(*) AS total_tickets,
     ROUND(
     100.0 * COUNT(*) / 
     (SELECT COUNT(*) FROM customer_support_tickets_clean),
     2
     ) AS percentage_of_tickets
FROM customer_support_tickets_clean
GROUP BY ticket_channel
ORDER BY total_tickets desc;


-- Analysis 5: Average Resolution Time by Ticket Priority
    SELECT
    ticket_priority,
    COUNT(resolution_duration_minutes) AS valid_resolved_tickets,
    ROUND(AVG(resolution_duration_minutes), 2) AS average_resolution_minutes
FROM customer_support_tickets_clean
WHERE resolution_duration_minutes IS NOT NULL
GROUP BY ticket_priority
ORDER BY average_resolution_minutes DESC;


-- Analysis 6: Average Resolution Time by Support Channel
SELECT
    ticket_channel,
    COUNT(resolution_duration_minutes) AS valid_resolved_tickets,
    ROUND(AVG(resolution_duration_minutes), 2) AS average_resolution_minutes
FROM customer_support_tickets_clean
WHERE resolution_duration_minutes IS NOT NULL
GROUP BY ticket_channel
ORDER BY average_resolution_minutes DESC;


-- Analysis 7: Average Customer Satisfaction by Ticket Type
SELECT
    ticket_type,
    COUNT(customer_satisfaction_rating) AS rated_tickets,
    ROUND(AVG(customer_satisfaction_rating), 2) AS average_satisfaction
FROM customer_support_tickets_clean
WHERE customer_satisfaction_rating IS NOT NULL
GROUP BY ticket_type
ORDER BY average_satisfaction DESC;


-- Analysis 8: Average Customer Satisfaction by Support Channel
SELECT
    ticket_channel,
    COUNT(customer_satisfaction_rating) AS rated_tickets,
    ROUND(AVG(customer_satisfaction_rating), 2) AS average_satisfaction
FROM customer_support_tickets_clean
WHERE customer_satisfaction_rating IS NOT NULL
GROUP BY ticket_channel
ORDER BY average_satisfaction DESC;


-- Analysis 9: Most Common Ticket Types
SELECT
    ticket_type,
    COUNT(*) AS ticket_type_count
FROM customer_support_tickets_clean
GROUP BY ticket_type
ORDER BY ticket_type_count DESC;


-- Analysis 10: Most Common Ticket Subjects
SELECT
    ticket_subject,
    COUNT(*) AS ticket_subject_count
FROM customer_support_tickets_clean
GROUP BY ticket_subject
ORDER BY ticket_type_count DESC;

 
-- Analysis 11: Ticket Volume by Product
SELECT
    product_purchased,
    COUNT(*) AS total_tickets
FROM customer_support_tickets_clean
GROUP BY product_purchased
ORDER BY total_tickets DESC;


-- Analysis 12: Customers with Multiple Support Tickets
SELECT
    customer_email,
    COUNT(*) AS ticket_count
FROM customer_support_tickets_clean
GROUP BY customer_email
HAVING ticket_count > 1
ORDER BY ticket_count DESC;


-- Analysis 13: Percentage of Repeat Customers
SELECT
    ROUND(
        100.0 *
        (
            SELECT COUNT(*)
            FROM (
                SELECT customer_email
                FROM customer_support_tickets_clean
                GROUP BY customer_email
                HAVING COUNT(*) > 1
            ) AS repeat_customers
        )
        /
        (SELECT COUNT(DISTINCT customer_email)
         FROM customer_support_tickets_clean),
        2
    ) AS repeat_customer_percentage;


-- Analysis 14: Resolution Time Distribution
SELECT
    CASE
        WHEN resolution_duration_minutes <= 120 THEN 'Up to 2 hours'
        WHEN resolution_duration_minutes <= 360 THEN '2–6 hours'
        WHEN resolution_duration_minutes <= 720 THEN '6–12 hours'
        WHEN resolution_duration_minutes <= 1440 THEN '12–24 hours'
        ELSE 'More than 24 hours'
    END AS resolution_time_band,
    COUNT(customer_satisfaction_rating) AS rated_tickets,
    ROUND(AVG(customer_satisfaction_rating), 2) AS average_satisfaction
FROM customer_support_tickets_clean
WHERE resolution_duration_minutes IS NOT NULL
GROUP BY
    CASE
        WHEN resolution_duration_minutes <= 120 THEN 'Up to 2 hours'
        WHEN resolution_duration_minutes <= 360 THEN '2–6 hours'
        WHEN resolution_duration_minutes <= 720 THEN '6–12 hours'
        WHEN resolution_duration_minutes <= 1440 THEN '12–24 hours'
        ELSE 'More than 24 hours'
    END
ORDER BY average_satisfaction DESC;


-- Analysis 16: Product + Ticket Type Combinations
SELECT
    product_purchased,
    ticket_type,
    COUNT(*) AS ticket_count
FROM customer_support_tickets_clean
GROUP BY
    product_purchased,
    ticket_type
ORDER BY
    ticket_count DESC;


-- Analysis 17: High-Volume Products
SELECT
    product_purchased,
    COUNT(*) AS total_support_tickets
FROM customer_support_tickets_clean
GROUP BY product_purchased
HAVING total_support_tickets > 200
ORDER BY total_support_tickets DESC;


-- Analysis 18: Support Channels Above Average Ticket Volume
WITH channel_tickets AS (
    SELECT
        ticket_channel,
        COUNT(*) AS ticket_count
    FROM customer_support_tickets_clean
    GROUP BY ticket_channel
)

SELECT
    ticket_channel,
    ticket_count,
    ROUND(
        (SELECT AVG(ticket_count)
         FROM channel_tickets), 2
    ) AS average_channel_ticket_count
FROM channel_tickets
WHERE ticket_count > (
    SELECT AVG(ticket_count)
    FROM channel_tickets
)
ORDER BY ticket_count DESC;


















