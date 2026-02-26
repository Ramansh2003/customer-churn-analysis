# Customer Churn Prediction & Retention Strategy

## Project Overview
Analysis of 7,032 telecom customers to predict churn risk and design a data-driven retention strategy using PostgreSQL and Excel.

## Business Problem
A telecom company is losing customers at a 26.58% churn rate resulting in £1.37 million annual revenue at risk. This project identifies high risk customers before they leave and recommends a targeted retention strategy.

## Tools Used
- **PostgreSQL 18** — Data cleaning, feature engineering, risk scoring
- **Excel** — Segmentation analysis, scenario modeling, interactive dashboard

## Dataset
- **Source:** Kaggle — Telco Customer Churn
- **Size:** 7,032 customers, 21 columns
- **Link:** https://www.kaggle.com/datasets/blastchar/telco-customer-churn

## Project Structure
- `Customer_Churn_SQL_Script.sql` — All PostgreSQL queries with comments
- `Customer_Churn_Analysis.xlsx` — Excel dashboard with scenario model
- `WA_Fn-UseC_-Telco-Customer-Churn.csv` — Original dataset

## SQL Concepts Covered
- Data cleaning and transformation
- Feature engineering with CASE WHEN
- Risk scoring model
- CTEs (Common Table Expressions)
- Window Functions (RANK, DENSE_RANK, ROW_NUMBER)
- JOINs across multiple tables

## Key Findings
| Risk Tier | Customers | Churn Rate | Revenue At Risk |
|-----------|-----------|------------|-----------------|
| High | 2,264 | 48% | £736,595 |
| Medium | 2,327 | 26% | £477,720 |
| Low | 2,441 | 7% | £155,151 |

## Key Insights
1. New customers churn at **47.68%** vs **11.93%** for loyal customers
2. Month-to-month contracts drive highest churn at **48%**
3. £1.37 million annual revenue at risk from churned customers

## Retention Strategy
With a £25,000 retention budget targeting High Risk customers:
- **1,250 customers reached**
- **188 customers saved**
- **£127,396 revenue protected**
- **409% ROI**

## How To Run SQL Scripts
1. Install PostgreSQL 18
2. Open pgAdmin 4
3. Open Query Tool connected to **postgres** database
4. Run Step 1 from SQL script to create raw_customers table
5. Right click raw_customers → Import/Export → Import the CSV file
6. Then run Steps 2-8 in order

## Author
Ramansh Bahutra
- LinkedIn: https://www.linkedin.com/in/ramansh-bahutra-rb
- GitHub: https://github.com/Ramansh2003/customer-churn-analysis.git
