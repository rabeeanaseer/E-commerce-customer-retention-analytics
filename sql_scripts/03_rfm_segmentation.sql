-- ==============================================================================
-- Case Study 3: RFM (Recency, Frequency, Monetary) Customer Segmentation
-- Goal: Group users into high-value, at-risk, and dormant tiers using NTILE logic.
-- ==============================================================================

WITH rfm_base AS (
    SELECT 
        user_id,
        MAX(DATE_TRUNC('day', created_at)) AS last_purchase_date,
        -- Recency: Days since last purchase
        DATEDIFF('day', MAX(DATE_TRUNC('day', created_at)), CURRENT_DATE()) AS recency_days,
        -- Frequency: Total distinct orders
        COUNT(DISTINCT order_id) AS frequency_count,
        -- Monetary: Total lifetime spend
        SUM(sale_price) AS monetary_value
    FROM fct_order_items
    GROUP BY 1
),
rfm_scoring AS (
    SELECT 
        user_id,
        recency_days,
        frequency_count,
        monetary_value,
        -- NTILE handles the percentiles. Reverse order for Recency (lower days = higher score)
        NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency_count ASC) AS f_score,
        NTILE(4) OVER (ORDER BY monetary_value ASC) AS m_score
    FROM rfm_base
)
SELECT 
    user_id,
    recency_days,
    frequency_count,
    monetary_value,
    (r_score + f_score + m_score) AS rfm_total_score,
    CASE 
        WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN '1 - Champions'
        WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 THEN '2 - At Risk High-Value'
        WHEN r_score >= 3 AND f_score <= 2 AND m_score <= 2 THEN '3 - Recent Low-Value'
        WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN '4 - Hibernating/Lost'
        ELSE '5 - Standard Users'
    END AS customer_segment
FROM rfm_scoring
ORDER BY monetary_value DESC;
