INSERT INTO "WITH users_prep AS (
    -- 1) Готую таблицю користувачів:
    -- signup_datetime у тексті та в різних форматах, тому:
    -- • прибираю пробіли (TRIM)
    -- • відкидаю час (беру тільки дату до пробілу)
    -- • приводжу розділювачі до одного виду ""-"" (REPLACE)
    SELECT
        user_id,
        promo_signup_flag,
        REPLACE(REPLACE(SPLIT_PART(TRIM(signup_datetime), ' ', 1), '.', '-'), '/', '-') AS signup_date_txt
    FROM cohort_users_raw
),

users_clean AS (
    -- 2) Перетворюю signup_date_txt у нормальну дату:
    -- • якщо рік 2 цифри (25) → роблю 2025
    -- • день/місяць доповнюю до 2 цифр (1 → 01)
    -- • після цього роблю TO_DATE у форматі DD-MM-YYYY
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
    -- 3) Готую таблицю подій так само:
    -- • прибираю пробіли
    -- • залишаю тільки дату без часу
    -- • роблю один розділювач ""-""
    SELECT
        event_id,
        user_id,
        event_type,
        revenue,
        REPLACE(REPLACE(SPLIT_PART(TRIM(event_datetime), ' ', 1), '.', '-'), '/', '-') AS event_date_txt
    FROM cohort_events_raw
),

events_clean AS (
    -- 4) Перетворюю event_date_txt у дату (event_date) за тією ж логікою, що і signup_date
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
    -- 5) Об’єдную користувачів і події по user_id та рахую:
    -- • cohort_month = місяць реєстрації
    -- • activity_month = місяць події
    -- • month_offset = різниця між ними в місяцях
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

-- 6) Фінал: збираю когортну таблицю users_total
SELECT
    promo_signup_flag,
    cohort_month,
    month_offset,
    COUNT(DISTINCT user_id) AS users_total
FROM cohort_base
WHERE activity_month BETWEEN DATE '2025-01-01' AND DATE '2025-06-01'
GROUP BY promo_signup_flag, cohort_month, month_offset
ORDER BY promo_signup_flag, cohort_month, month_offset" (promo_signup_flag,cohort_month,month_offset,users_total) VALUES
	 (0,'2025-01-01',0,70),
	 (0,'2025-01-01',1,58),
	 (0,'2025-01-01',2,54),
	 (0,'2025-01-01',3,52),
	 (0,'2025-01-01',4,43),
	 (0,'2025-01-01',5,39),
	 (0,'2025-02-01',0,63),
	 (0,'2025-02-01',1,46),
	 (0,'2025-02-01',2,48),
	 (0,'2025-02-01',3,49);
INSERT INTO "WITH users_prep AS (
    -- 1) Готую таблицю користувачів:
    -- signup_datetime у тексті та в різних форматах, тому:
    -- • прибираю пробіли (TRIM)
    -- • відкидаю час (беру тільки дату до пробілу)
    -- • приводжу розділювачі до одного виду ""-"" (REPLACE)
    SELECT
        user_id,
        promo_signup_flag,
        REPLACE(REPLACE(SPLIT_PART(TRIM(signup_datetime), ' ', 1), '.', '-'), '/', '-') AS signup_date_txt
    FROM cohort_users_raw
),

users_clean AS (
    -- 2) Перетворюю signup_date_txt у нормальну дату:
    -- • якщо рік 2 цифри (25) → роблю 2025
    -- • день/місяць доповнюю до 2 цифр (1 → 01)
    -- • після цього роблю TO_DATE у форматі DD-MM-YYYY
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
    -- 3) Готую таблицю подій так само:
    -- • прибираю пробіли
    -- • залишаю тільки дату без часу
    -- • роблю один розділювач ""-""
    SELECT
        event_id,
        user_id,
        event_type,
        revenue,
        REPLACE(REPLACE(SPLIT_PART(TRIM(event_datetime), ' ', 1), '.', '-'), '/', '-') AS event_date_txt
    FROM cohort_events_raw
),

events_clean AS (
    -- 4) Перетворюю event_date_txt у дату (event_date) за тією ж логікою, що і signup_date
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
    -- 5) Об’єдную користувачів і події по user_id та рахую:
    -- • cohort_month = місяць реєстрації
    -- • activity_month = місяць події
    -- • month_offset = різниця між ними в місяцях
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

-- 6) Фінал: збираю когортну таблицю users_total
SELECT
    promo_signup_flag,
    cohort_month,
    month_offset,
    COUNT(DISTINCT user_id) AS users_total
FROM cohort_base
WHERE activity_month BETWEEN DATE '2025-01-01' AND DATE '2025-06-01'
GROUP BY promo_signup_flag, cohort_month, month_offset
ORDER BY promo_signup_flag, cohort_month, month_offset" (promo_signup_flag,cohort_month,month_offset,users_total) VALUES
	 (0,'2025-02-01',4,43),
	 (0,'2025-03-01',0,51),
	 (0,'2025-03-01',1,41),
	 (0,'2025-03-01',2,47),
	 (0,'2025-03-01',3,41),
	 (0,'2025-04-01',0,61),
	 (0,'2025-04-01',1,50),
	 (0,'2025-04-01',2,47),
	 (0,'2025-05-01',0,63),
	 (0,'2025-05-01',1,55);
INSERT INTO "WITH users_prep AS (
    -- 1) Готую таблицю користувачів:
    -- signup_datetime у тексті та в різних форматах, тому:
    -- • прибираю пробіли (TRIM)
    -- • відкидаю час (беру тільки дату до пробілу)
    -- • приводжу розділювачі до одного виду ""-"" (REPLACE)
    SELECT
        user_id,
        promo_signup_flag,
        REPLACE(REPLACE(SPLIT_PART(TRIM(signup_datetime), ' ', 1), '.', '-'), '/', '-') AS signup_date_txt
    FROM cohort_users_raw
),

users_clean AS (
    -- 2) Перетворюю signup_date_txt у нормальну дату:
    -- • якщо рік 2 цифри (25) → роблю 2025
    -- • день/місяць доповнюю до 2 цифр (1 → 01)
    -- • після цього роблю TO_DATE у форматі DD-MM-YYYY
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
    -- 3) Готую таблицю подій так само:
    -- • прибираю пробіли
    -- • залишаю тільки дату без часу
    -- • роблю один розділювач ""-""
    SELECT
        event_id,
        user_id,
        event_type,
        revenue,
        REPLACE(REPLACE(SPLIT_PART(TRIM(event_datetime), ' ', 1), '.', '-'), '/', '-') AS event_date_txt
    FROM cohort_events_raw
),

events_clean AS (
    -- 4) Перетворюю event_date_txt у дату (event_date) за тією ж логікою, що і signup_date
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
    -- 5) Об’єдную користувачів і події по user_id та рахую:
    -- • cohort_month = місяць реєстрації
    -- • activity_month = місяць події
    -- • month_offset = різниця між ними в місяцях
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

-- 6) Фінал: збираю когортну таблицю users_total
SELECT
    promo_signup_flag,
    cohort_month,
    month_offset,
    COUNT(DISTINCT user_id) AS users_total
FROM cohort_base
WHERE activity_month BETWEEN DATE '2025-01-01' AND DATE '2025-06-01'
GROUP BY promo_signup_flag, cohort_month, month_offset
ORDER BY promo_signup_flag, cohort_month, month_offset" (promo_signup_flag,cohort_month,month_offset,users_total) VALUES
	 (0,'2025-06-01',0,50),
	 (1,'2025-01-01',0,34),
	 (1,'2025-01-01',1,21),
	 (1,'2025-01-01',2,17),
	 (1,'2025-01-01',3,3),
	 (1,'2025-01-01',4,6),
	 (1,'2025-01-01',5,3),
	 (1,'2025-02-01',0,41),
	 (1,'2025-02-01',1,24),
	 (1,'2025-02-01',2,17);
INSERT INTO "WITH users_prep AS (
    -- 1) Готую таблицю користувачів:
    -- signup_datetime у тексті та в різних форматах, тому:
    -- • прибираю пробіли (TRIM)
    -- • відкидаю час (беру тільки дату до пробілу)
    -- • приводжу розділювачі до одного виду ""-"" (REPLACE)
    SELECT
        user_id,
        promo_signup_flag,
        REPLACE(REPLACE(SPLIT_PART(TRIM(signup_datetime), ' ', 1), '.', '-'), '/', '-') AS signup_date_txt
    FROM cohort_users_raw
),

users_clean AS (
    -- 2) Перетворюю signup_date_txt у нормальну дату:
    -- • якщо рік 2 цифри (25) → роблю 2025
    -- • день/місяць доповнюю до 2 цифр (1 → 01)
    -- • після цього роблю TO_DATE у форматі DD-MM-YYYY
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
    -- 3) Готую таблицю подій так само:
    -- • прибираю пробіли
    -- • залишаю тільки дату без часу
    -- • роблю один розділювач ""-""
    SELECT
        event_id,
        user_id,
        event_type,
        revenue,
        REPLACE(REPLACE(SPLIT_PART(TRIM(event_datetime), ' ', 1), '.', '-'), '/', '-') AS event_date_txt
    FROM cohort_events_raw
),

events_clean AS (
    -- 4) Перетворюю event_date_txt у дату (event_date) за тією ж логікою, що і signup_date
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
    -- 5) Об’єдную користувачів і події по user_id та рахую:
    -- • cohort_month = місяць реєстрації
    -- • activity_month = місяць події
    -- • month_offset = різниця між ними в місяцях
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

-- 6) Фінал: збираю когортну таблицю users_total
SELECT
    promo_signup_flag,
    cohort_month,
    month_offset,
    COUNT(DISTINCT user_id) AS users_total
FROM cohort_base
WHERE activity_month BETWEEN DATE '2025-01-01' AND DATE '2025-06-01'
GROUP BY promo_signup_flag, cohort_month, month_offset
ORDER BY promo_signup_flag, cohort_month, month_offset" (promo_signup_flag,cohort_month,month_offset,users_total) VALUES
	 (1,'2025-02-01',3,13),
	 (1,'2025-02-01',4,8),
	 (1,'2025-03-01',0,31),
	 (1,'2025-03-01',1,18),
	 (1,'2025-03-01',2,14),
	 (1,'2025-03-01',3,11),
	 (1,'2025-04-01',0,44),
	 (1,'2025-04-01',1,24),
	 (1,'2025-04-01',2,14),
	 (1,'2025-05-01',0,45);
INSERT INTO "WITH users_prep AS (
    -- 1) Готую таблицю користувачів:
    -- signup_datetime у тексті та в різних форматах, тому:
    -- • прибираю пробіли (TRIM)
    -- • відкидаю час (беру тільки дату до пробілу)
    -- • приводжу розділювачі до одного виду ""-"" (REPLACE)
    SELECT
        user_id,
        promo_signup_flag,
        REPLACE(REPLACE(SPLIT_PART(TRIM(signup_datetime), ' ', 1), '.', '-'), '/', '-') AS signup_date_txt
    FROM cohort_users_raw
),

users_clean AS (
    -- 2) Перетворюю signup_date_txt у нормальну дату:
    -- • якщо рік 2 цифри (25) → роблю 2025
    -- • день/місяць доповнюю до 2 цифр (1 → 01)
    -- • після цього роблю TO_DATE у форматі DD-MM-YYYY
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
    -- 3) Готую таблицю подій так само:
    -- • прибираю пробіли
    -- • залишаю тільки дату без часу
    -- • роблю один розділювач ""-""
    SELECT
        event_id,
        user_id,
        event_type,
        revenue,
        REPLACE(REPLACE(SPLIT_PART(TRIM(event_datetime), ' ', 1), '.', '-'), '/', '-') AS event_date_txt
    FROM cohort_events_raw
),

events_clean AS (
    -- 4) Перетворюю event_date_txt у дату (event_date) за тією ж логікою, що і signup_date
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
    -- 5) Об’єдную користувачів і події по user_id та рахую:
    -- • cohort_month = місяць реєстрації
    -- • activity_month = місяць події
    -- • month_offset = різниця між ними в місяцях
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

-- 6) Фінал: збираю когортну таблицю users_total
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
