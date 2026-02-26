-- ================================================
-- CUSTOMER CHURN PREDICTION & RETENTION STRATEGY
-- Author: Ramansh Bahutra
-- Date: February 2026
-- Tool: PostgreSQL 18
-- Dataset: Telco Customer Churn (Kaggle, 7,032 rows)
-- ================================================


-- ================================================
-- STEP 1: CREATE RAW TABLE
-- ================================================

CREATE TABLE raw_customers (
    customer_id TEXT PRIMARY KEY,
    gender TEXT,
    senior_citizen INTEGER,
    partner TEXT,
    dependents TEXT,
    tenure INTEGER,
    phone_service TEXT,
    multiple_lines TEXT,
    internet_service TEXT,
    online_security TEXT,
    online_backup TEXT,
    device_protection TEXT,
    tech_support TEXT,
    streaming_tv TEXT,
    streaming_movies TEXT,
    contract TEXT,
    paperless_billing TEXT,
    payment_method TEXT,
    monthly_charges DECIMAL(10,2),
    total_charges TEXT,
    churn TEXT
);


-- ================================================
-- STEP 2: DATA CLEANING
-- Converting Yes/No to 1/0 and fixing data types
-- ================================================

CREATE TABLE customers AS
SELECT 
    customer_id,
    gender,
    senior_citizen,
    partner,
    dependents,
    tenure,
    CASE WHEN phone_service = 'Yes' THEN 1 ELSE 0 END AS has_phone,
    CASE WHEN multiple_lines = 'Yes' THEN 1 ELSE 0 END AS has_multiple_lines,
    internet_service,
    CASE WHEN online_security = 'Yes' THEN 1 ELSE 0 END AS has_security,
    CASE WHEN online_backup = 'Yes' THEN 1 ELSE 0 END AS has_backup,
    CASE WHEN device_protection = 'Yes' THEN 1 ELSE 0 END AS has_protection,
    CASE WHEN tech_support = 'Yes' THEN 1 ELSE 0 END AS has_support,
    CASE WHEN streaming_tv = 'Yes' THEN 1 ELSE 0 END AS has_streaming_tv,
    CASE WHEN streaming_movies = 'Yes' THEN 1 ELSE 0 END AS has_streaming_movies,
    contract,
    paperless_billing,
    payment_method,
    monthly_charges,
    CAST(total_charges AS DECIMAL(10,2)) AS total_charges,
    CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END AS churn_flag
FROM raw_customers
WHERE total_charges != ' ';


-- ================================================
-- STEP 3: FEATURE ENGINEERING
-- Creating new meaningful columns for analysis
-- ================================================

CREATE TABLE customer_features AS
SELECT 
    customer_id,
    gender,
    senior_citizen,
    partner,
    dependents,
    tenure,
    contract,
    payment_method,
    monthly_charges,
    total_charges,
    churn_flag,
    (has_phone + has_multiple_lines + has_security + 
     has_backup + has_protection + has_support + 
     has_streaming_tv + has_streaming_movies) AS service_count,
    CASE 
        WHEN contract = 'Month-to-month' THEN 'High Risk'
        WHEN contract = 'One year' THEN 'Medium Risk'
        WHEN contract = 'Two year' THEN 'Low Risk'
    END AS contract_risk,
    CASE 
        WHEN tenure <= 12 THEN 'New'
        WHEN tenure <= 36 THEN 'Growing'
        ELSE 'Loyal'
    END AS tenure_segment
FROM customers;


-- ================================================
-- STEP 4: RISK SCORING
-- Assigning risk score 0-100 to each customer
-- ================================================

CREATE TABLE customer_risk_scores AS
SELECT 
    customer_id,
    tenure,
    monthly_charges,
    total_charges,
    service_count,
    contract,
    tenure_segment,
    contract_risk,
    churn_flag AS actual_churn,
    (
        CASE WHEN tenure <= 12 THEN 25 
             WHEN tenure <= 36 THEN 15 
             ELSE 0 END
    ) +
    (
        CASE WHEN contract = 'Month-to-month' THEN 30 
             WHEN contract = 'One year' THEN 15 
             ELSE 0 END
    ) +
    (
        CASE WHEN service_count <= 2 THEN 25 
             ELSE 0 END
    ) +
    (
        CASE WHEN monthly_charges > 70 THEN 20 
             ELSE 0 END
    ) AS risk_score
FROM customer_features;

ALTER TABLE customer_risk_scores ADD COLUMN risk_tier TEXT;

UPDATE customer_risk_scores
SET risk_tier = 
    CASE 
        WHEN risk_score >= 70 THEN 'High'
        WHEN risk_score >= 40 THEN 'Medium'
        ELSE 'Low'
    END;


-- ================================================
-- STEP 5: CTE ANALYSIS
-- Churn rate by tenure segment and contract risk
-- ================================================

WITH churn_summary AS (
    SELECT 
        tenure_segment,
        contract_risk,
        COUNT(*) AS total_customers,
        SUM(churn_flag) AS churned,
        ROUND(AVG(churn_flag) * 100, 2) AS churn_rate_pct
    FROM customer_features
    GROUP BY tenure_segment, contract_risk
)
SELECT * FROM churn_summary
ORDER BY churn_rate_pct DESC;


-- ================================================
-- STEP 6: WINDOW FUNCTIONS
-- Ranking customers by risk score
-- ================================================

SELECT 
    customer_id,
    tenure,
    monthly_charges,
    risk_score,
    risk_tier,
    actual_churn,
    RANK() OVER (ORDER BY risk_score DESC) AS risk_rank,
    DENSE_RANK() OVER (ORDER BY risk_score DESC) AS dense_rank,
    ROW_NUMBER() OVER (ORDER BY risk_score DESC) AS row_num,
    RANK() OVER (PARTITION BY risk_tier ORDER BY monthly_charges DESC) AS rank_within_tier
FROM customer_risk_scores
LIMIT 20;


-- ================================================
-- STEP 7: JOIN ANALYSIS
-- Combining customer data with regional data
-- ================================================

CREATE TABLE region_data (
    customer_id TEXT,
    region TEXT,
    city TEXT,
    customer_value TEXT
);

INSERT INTO region_data VALUES
('7590-VHVEG', 'North', 'Manchester', 'Premium'),
('5575-GNVDE', 'South', 'London', 'Standard'),
('3668-QPYBK', 'East', 'Birmingham', 'Premium'),
('7795-CFOCW', 'West', 'Bristol', 'Standard'),
('9237-HQITU', 'North', 'Leeds', 'Basic'),
('9305-CDSKC', 'South', 'London', 'Premium'),
('1452-KIOVK', 'East', 'Norwich', 'Basic'),
('6713-OKOMC', 'West', 'Cardiff', 'Standard'),
('7892-POOKP', 'North', 'Manchester', 'Premium'),
('6388-TABGU', 'South', 'London', 'Basic');

SELECT 
    c.customer_id,
    c.tenure,
    c.monthly_charges,
    c.risk_score,
    c.risk_tier,
    c.actual_churn,
    r.region,
    r.city,
    r.customer_value
FROM customer_risk_scores c
JOIN region_data r 
    ON c.customer_id = r.customer_id
ORDER BY c.risk_score DESC;


-- ================================================
-- STEP 8: FINAL BUSINESS INSIGHT
-- Risk tier summary for dashboard
-- ================================================

SELECT 
    risk_tier,
    COUNT(*) AS total_customers,
    SUM(actual_churn) AS churned,
    ROUND(AVG(actual_churn) * 100, 2) AS churn_rate_pct,
    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges
FROM customer_risk_scores
GROUP BY risk_tier
ORDER BY churn_rate_pct DESC;