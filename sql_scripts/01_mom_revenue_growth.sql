
-- ==============================================================================
-- Case Study 1: Month-over-Month (MoM) Revenue Growth & Rolling Averages
-- Goal: Isolate seasonal anomalies and find the true underlying growth rate.
-- ==============================================================================

WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', o.created_at) AS order_month,
        SUM(p.amount) AS total_revenue,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM fct_orders o
    JOIN fct_payments p ON o.order_id = p.order_id
    WHERE o.status NOT IN ('Cancelled', 'Returned')
      AND p.status = 'Success'
    GROUP BY 1
)
SELECT 
    order_month,
    total_revenue,
    total_orders,
    -- Calculate standard MoM difference
    LAG(total_revenue) OVER (ORDER BY order_month) AS prev_month_revenue,
    ROUND((total_revenue - LAG(total_revenue) OVER (ORDER BY order_month)) / 
           NULLIF(LAG(total_revenue) OVER (ORDER BY order_month), 0) * 100, 2) AS mom_growth_pct,
    -- Calculate 3-month rolling average to smooth volatility 
    AVG(total_revenue) OVER (
        ORDER BY order_month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling_3m_avg_revenue
FROM monthly_revenue
ORDER BY order_month DESC;
