# 📊 Project Omnia: E-Commerce Customer Retention & LTV Optimization

![SQL](https://img.shields.io/badge/SQL-Advanced-blue?logo=postgresql&logoColor=white)
![BigQuery](https://img.shields.io/badge/BigQuery-Optimized-4285F4?logo=google-cloud&logoColor=white)
![Snowflake](https://img.shields.io/badge/Snowflake-Ready-29B5E8?logo=snowflake&logoColor=white)
![Python](https://img.shields.io/badge/Python-Mock_Data-3776AB?logo=python&logoColor=white)
![Status](https://img.shields.io/badge/Status-Complete-success)

**Role:** Senior Data Analyst / Analytics Engineer  
**Domain:** E-Commerce / Consumer Retail  
**Techniques Used:** CTEs, Window Functions, Cohort Analysis, RFM Modeling, Data Modeling  

---

## 1. EXECUTIVE BRIEF & BUSINESS CONTEXT

### The Business Scenario
"NovaGear", a high-growth outdoor apparel e-commerce platform, has successfully scaled its user base over the past three years. However, driven by macroeconomic shifts and privacy policy updates, **Customer Acquisition Cost (CAC) has increased by 42% YoY**. 

The executive mandate has shifted from *growth-at-all-costs* to *profitability and sustainable unit economics*. To achieve this, the business must maximize the value of its existing customer base by identifying behavioral bottlenecks and uncovering high-LTV cross-sell opportunities.

### Critical Executive KPIs
This analysis focuses on optimizing three primary KPIs:
1. **Gross Merchandise Value (GMV) Rolling Trajectory:** Identifying the true underlying revenue growth rate, normalized for seasonal anomalies.
2. **12-Month Cohort Retention Rate:** Quantifying the exact month-over-month drop-off of acquired users.
3. **Customer Lifetime Value (CLTV) via RFM Segmentation:** Categorizing the user base by Recency, Frequency, and Monetary metrics to enable targeted, high-ROI marketing workflows.

---

## 2. DATA ARCHITECTURE & SCHEMA OVERVIEW

The underlying data warehouse utilizes a standard star-schema approach. This project queries four core transactional tables structured for a modern cloud data warehouse (Snowflake/BigQuery).

| Table Name | Primary Key | Foreign Keys | Granularity | Description |
| :--- | :--- | :--- | :--- | :--- |
| `dim_users` | `user_id` | N/A | 1 Row per User | Customer demographic and acquisition data. |
| `fct_orders` | `order_id` | `user_id` | 1 Row per Order | Order-level metadata (timestamps, shipping). |
| `fct_order_items`| `order_item_id` | `order_id`, `product_id`| 1 Row per Item | Line-item product details and sale prices. |
| `fct_payments` | `payment_id` | `order_id` | 1 Row per Payment | Payment gateway statuses and amounts. |

---

## 3. ADVANCED ANALYTICAL SQL DEEP-DIVE

### Case Study 1: Month-over-Month (MoM) Revenue Growth & Rolling Averages
**A) Strategic Business Question:** *How is our baseline revenue trending when we smooth out month-to-month volatility and seasonal spikes?* 

**[🖥️ View the Advanced SQL Script: MoM Revenue & Rolling Averages](sql_scripts/01_mom_revenue_growth.sql)**

**B) Visualization & Sample Output:**

![MoM Revenue Trend]<img width="2816" height="1536" alt="MoM Revenue Trend " src="https://github.com/user-attachments/assets/8f49e96b-d6b9-41fd-8804-0de8022d29f0" />

*Figure 1: Baseline revenue vs. 3-month rolling average smoothing out Q4 seasonal spikes.*

| order_month | total_revenue | mom_growth_pct | rolling_3m_avg_revenue |
| :--- | :--- | :--- | :--- |
| 2023-11-01 | \$420,500.00 | +35.56% | \$341,900.00 |
| 2023-10-01 | \$310,200.00 | +5.15% | \$302,400.00 |
| 2023-09-01 | \$295,000.00 | -2.32% | \$298,333.33 |

**C) Executive Insight & Recommendation:**
While November saw a massive +35.56% MoM growth, the `rolling_3m_avg_revenue` indicates a much steadier, stabilized growth trajectory. Supply chain forecasting should be modeled against the 3-month rolling average (\$341k) rather than baseline MoM jumps to prevent over-purchasing inventory for Q1.

---

### Case Study 2: 12-Month Cohort Retention Decay
**A) Strategic Business Question:** *When users make their first purchase, how many return to buy again in the subsequent months, and where is the steepest drop-off?*

**[🖥️ View the Advanced SQL Script: Cohort Retention Decay](sql_scripts/02_cohort_retention.sql)**

**B) Visualization & Sample Output:**

![Cohort Retention Heatmap]<img width="2102" height="1291" alt="Cohort Retention Heatmap" src="https://github.com/user-attachments/assets/8abcc3a2-c901-4360-acaf-f046348e55d8" />


*Figure 2: Monthly cohort retention decay highlighting the steep Month 1 to Month 2 drop-off.*

| cohort_month | month_0_users | m1_retention_pct | m2_retention_pct | m3_retention_pct |
| :--- | :--- | :--- | :--- | :--- |
| 2023-08-01 | 1,450 | 22.4% | 14.2% | 10.1% |
| 2023-07-01 | 1,200 | 24.1% | 15.0% | 11.2% |
| 2023-06-01 | 1,600 | 18.5% | 10.1% | 8.0% |

**C) Executive Insight & Recommendation:**
The data reveals a critical "retention cliff" between Month 1 and Month 2, dropping an average of 8-9 absolute percentage points. Deploy a dynamic discount code strictly delivered at **Day 25** post-first-purchase to bridge this M1-to-M2 drop-off, shifting budget away from top-of-funnel discounting.

---

### Case Study 3: RFM Customer Segmentation
**A) Strategic Business Question:** *Who are our absolute best customers, and who is on the verge of churning?*

**[🖥️ View the Advanced SQL Script: RFM Segmentation](sql_scripts/03_rfm_segmentation.sql)**

**B) Visualization & Sample Output:**

![RFM Segmentation Pie Chart]<img width="2129" height="1174" alt="RFM Segmentation Pie Chart" src="https://github.com/user-attachments/assets/8845a9eb-758c-4092-9c86-490b907e6380" />

*Figure 3: User distribution across RFM segments, pinpointing the "At Risk High-Value" cluster.*

| user_id | recency_days | frequency_count | monetary_value | rfm_total_score | customer_segment |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `usr_982` | 4 | 12 | \$3,450.00 | 12 | 1 - Champions |
| `usr_556` | 145 | 9 | \$2,750.00 | 9 | 2 - At Risk High-Value |
| `usr_882` | 310 | 1 | \$45.00 | 3 | 4 - Hibernating/Lost |

**C) Executive Insight & Recommendation:**
We have successfully isolated the `At Risk High-Value` segment. Immediately pipe this segment into a VIP win-back campaign (e.g., direct mail catalog, personalized concierge email) to prevent churn of top revenue drivers. Exclude "Hibernating/Lost" from paid retargeting to save on CAC.

---

## 4. PERFORMANCE OPTIMIZATION TECHNIQUES
If deploying these queries as scheduled dbt models or Airflow DAGs within BigQuery/Snowflake, I would implement the following optimizations to minimize compute cost and execution time:

1. **Partitioning:** Partition `fct_orders` and `fct_payments` by the `created_at` timestamp. This ensures that rolling average and cohort queries only scan the necessary timeframes via partition pruning.
2. **Clustering:** Cluster the tables by `user_id` and `status`. Because the RFM and Cohort queries aggregate heavily on `user_id`, clustering co-locates this data under the hood, dramatically speeding up `JOIN` and `GROUP BY` operations.
3. **Incremental Materialization:** Instead of calculating massive historical datasets *ad hoc* every time a dashboard loads, `monthly_revenue` and `rfm_base` should be structured as **Incremental Models in dbt**. The warehouse will only process new rows from the last 24 hours and append them, drastically reducing credit consumption.

---

## 5. REPRODUCING THIS PROJECT

### Repository Structure
```text
ecommerce-retention-sql-analysis/
├── README.md                  
├── assets/                    # Contains visualization images
│   ├── chart_1_mom_revenue.png
│   ├── chart_2_cohort_heatmap.png
│   └── chart_3_rfm_segments.png
├── sql_scripts/               # Raw SQL files for the 3 case studies
│   ├── 01_mom_revenue_growth.sql
│   ├── 02_cohort_retention.sql
│   └── 03_rfm_segmentation.sql
└── mock_data_generator/       # Python pipeline engine
    └── generate_data.py
```

### How to Run Locally

1. **Clone this repository:**
   ```bash
   git clone https://github.com
   ```

2. **Navigate to the mock data generator folder:**
   ```bash
   cd ecommerce-retention-sql-analysis/mock_data_generator
   ```

3. **Install the required Python packages:**
   ```bash
   pip install pandas numpy matplotlib seaborn
   ```

4. **Run the generation pipeline:**
   ```bash
   python generate_data.py
   ```

The script will automatically generate 3 mock relational CSV database tables (`dim_users.csv`, `fct_orders.csv`, `fct_payments.csv`) and regenerate the visual analytics assets directly inside the `assets/` folder.

### Next Steps for Deployment
1. Upload the generated flat `.csv` tables into your **BigQuery Workspace Sandbox or Snowflake Schema**.
2. Run any script from the `sql_scripts/` directory inside your cloud warehouse console to process data metrics.
