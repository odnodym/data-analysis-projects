INSERT INTO "WITH users_prep AS (
-- 1) Preparing users table:
-- signup_datetime is stored as text and in different formats, therefore:
-- • removing spaces (TRIM)
-- • removing time (keeping only date before space)
-- • standardizing separators to "-" (REPLACE)
    SELECT
        user_id,
        promo_signup_flag,
        REPLACE(REPLACE(SPLIT_PART(TRIM(signup_datetime), ' ', 1), '.', '-'), '/', '-') AS signup_date_txt
    FROM cohort_users_raw
),

users_clean AS (
-- 2) Converting signup_date_txt to proper date:
-- • if year has 2 digits (25) → convert to 2025
-- • pad day/month to 2 digits (1 → 01)
-- • convert to date using TO_DATE with DD-MM-YYYY format
    SELECT
        user_id,
        promo_signup_flag,
        TO_DATE(
            CASE
                WHEN LENGTH(SPLIT_PART(signup_date_txt, '-', 3)) = 2 THEN
                    LPAD(SPLIT_PART(signup_date_txt, '-', 1), 2, '0') || '-' ||
                    LPAD(SPLIT_PART(signup_date_txt, '-', 2), 2, '0') || '-' ||
                    ('20' || SPLIT_PART(signup_date_txt, '-', 3))
                ELSE
                    LPAD(SPLIT_PART(signup_date_txt, '-', 1), 2, '0') || '-' ||
                    LPAD(SPLIT_PART(signup_date_txt, '-', 2), 2, '0') || '-' ||
                    SPLIT_PART(signup_date_txt, '-', 3)
            END,
            'DD-MM-YYYY'
        ) AS signup_date
    FROM users_prep
),

events_prep AS (
-- 3) Preparing events table:
-- • removing spaces
-- • keeping only date without time
-- • standardizing separators to "-"
    SELECT
        event_id,
        user_id,
        event_type,
        revenue,
        REPLACE(REPLACE(SPLIT_PART(TRIM(event_datetime), ' ', 1), '.', '-'), '/', '-') AS event_date_txt
    FROM cohort_events_raw
),

events_clean AS (
-- 4) Converting event_date_txt to date (event_date) 
-- using the same logic as signup_date
    SELECT
        event_id,
        user_id,
        event_type,
        revenue,
        TO_DATE(
            CASE
                WHEN LENGTH(SPLIT_PART(event_date_txt, '-', 3)) = 2 THEN
                    LPAD(SPLIT_PART(event_date_txt, '-', 1), 2, '0') || '-' ||
                    LPAD(SPLIT_PART(event_date_txt, '-', 2), 2, '0') || '-' ||
                    ('20' || SPLIT_PART(event_date_txt, '-', 3))
                ELSE
                    LPAD(SPLIT_PART(event_date_txt, '-', 1), 2, '0') || '-' ||
                    LPAD(SPLIT_PART(event_date_txt, '-', 2), 2, '0') || '-' ||
                    SPLIT_PART(event_date_txt, '-', 3)
            END,
            'DD-MM-YYYY'
        ) AS event_date
    FROM events_prep
),

cohort_base AS (
-- 5) Joining users and events by user_id and calculating:
-- • cohort_month = signup month
-- • activity_month = event month
-- • month_offset = difference between them in months
-- Filtering invalid data: NULL values and test_event (registration kept)
    -- Також фільтрую сміття: NULL + test_event (registration залишаю)
    SELECT
        u.user_id,
        u.promo_signup_flag,
        DATE_TRUNC('month', u.signup_date)::date AS cohort_month,
        DATE_TRUNC('month', e.event_date)::date AS activity_month,
        (
            EXTRACT(YEAR FROM DATE_TRUNC('month', e.event_date)) * 12 +
            EXTRACT(MONTH FROM DATE_TRUNC('month', e.event_date))
        ) -
        (
            EXTRACT(YEAR FROM DATE_TRUNC('month', u.signup_date)) * 12 +
            EXTRACT(MONTH FROM DATE_TRUNC('month', u.signup_date))
        ) AS month_offset
    FROM users_clean u
    JOIN events_clean e
        ON u.user_id = e.user_id
    WHERE u.signup_date IS NOT NULL
      AND e.event_date IS NOT NULL
      AND e.event_type IS NOT NULL
      AND e.event_type <> 'test_event'
)

-- 6) Final step: building cohort table users_total
SELECT
    promo_signup_flag,
    cohort_month,
    month_offset,
    COUNT(DISTINCT user_id) AS users_total
FROM cohort_base
WHERE activity_month BETWEEN DATE '2025-01-01' AND DATE '2025-06-01'
GROUP BY promo_signup_flag, cohort_month, month_offset
ORDER BY promo_signup_flag, cohort_month, month_offset" (promo_signup_flag,cohort_month,month_offset,users_total) VALUES
	 (1,'2025-05-01',1,21),
	 (1,'2025-06-01',0,47);
