-- ==============================================================================
-- Case Study 2: 12-Month Cohort Retention Decay
-- Goal: Track active user purchasing drops based on their signup/first-purchase month.
-- ==============================================================================

WITH cohort_definition AS (
    -- Identify the first purchase month for each user
    SELECT 
        user_id,
        DATE_TRUNC('month', MIN(created_at)) AS cohort_month
    FROM fct_orders
    WHERE status NOT IN ('Cancelled', 'Returned')
    GROUP BY 1
),
user_activities AS (
    -- Map subsequent purchases to their respective cohort
    SELECT 
        o.user_id,
        cd.cohort_month,
        DATE_TRUNC('month', o.created_at) AS activity_month,
        -- Calculate the integer month difference (Month 0, Month 1, etc.)
        DATEDIFF('month', cd.cohort_month, DATE_TRUNC('month', o.created_at)) AS month_index
    FROM fct_orders o
    JOIN cohort_definition cd ON o.user_id = cd.user_id
    WHERE o.status NOT IN ('Cancelled', 'Returned')
)
-- Pivot the data into an executive-friendly matrix
SELECT 
    cohort_month,
    COUNT(DISTINCT CASE WHEN month_index = 0 THEN user_id END) AS month_0_users,
    ROUND(COUNT(DISTINCT CASE WHEN month_index = 1 THEN user_id END) * 100.0 / NULLIF(COUNT(DISTINCT CASE WHEN month_index = 0 THEN user_id END), 0), 2) AS m1_retention_pct,
    ROUND(COUNT(DISTINCT CASE WHEN month_index = 2 THEN user_id END) * 100.0 / NULLIF(COUNT(DISTINCT CASE WHEN month_index = 0 THEN user_id END), 0), 2) AS m2_retention_pct,
    ROUND(COUNT(DISTINCT CASE WHEN month_index = 3 THEN user_id END) * 100.0 / NULLIF(COUNT(DISTINCT CASE WHEN month_index = 0 THEN user_id END), 0), 2) AS m3_retention_pct,
    ROUND(COUNT(DISTINCT CASE WHEN month_index = 6 THEN user_id END) * 100.0 / NULLIF(COUNT(DISTINCT CASE WHEN month_index = 0 THEN user_id END), 0), 2) AS m6_retention_pct
FROM user_activities
GROUP BY 1
ORDER BY cohort_month DESC;
