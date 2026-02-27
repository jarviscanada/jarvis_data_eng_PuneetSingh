# London Gift Shop (LGS) — Retail Customer Analytics (RFM)

## Overview
London Gift Shop (LGS) is a UK-based e-commerce store selling gifts for different occasions. The business has accumulated transactional sales data over time, but it wasn’t being used to answer key customer questions like:

- Who are our best customers?
- Which customers are drifting away?
- What segments should marketing focus on first?

This project turns raw retail transactions into a structured analytics dataset and produces **RFM customer segments** (Recency, Frequency, Monetary) so teams can shift from guesswork to **data-backed targeting, retention, and revenue growth**.

---

## Tech Stack
- **Docker** — reproducible local environment for the database + analytics setup  
- **PostgreSQL** — acts as the **data warehouse** for storing cleaned retail data  
- **Python** — analysis and transformation logic  
- **Pandas / NumPy** — cleaning, preparation, and feature engineering  
- **Jupyter Notebook** — exploration, reporting, and visualization

---

## Solution Design
### High-level Flow
1. **Data Source (LGS Web App Export)**  
   Retail transactions provided as a database dump / raw extract.
2. **PostgreSQL Warehouse (Dockerized)**  
   Stores structured tables used for analytics and reporting.
3. **Analytics Layer (Jupyter + Python)**  
   Pulls data from the warehouse, cleans it, builds RFM features, and generates charts/insights.
4. **Business Users (Marketing / Growth Team)**  
   Use segmentation outputs to run campaigns and measure results.

> [![Project Architecture](./assets/architecture.png)](./assets/architecture.png)

---

## Analytics & Data Preparation
The notebook contains the full workflow including:
- loading data into the warehouse
- data quality checks (nulls, duplicates, formatting)
- cleaning and standardization
- customer-level aggregation
- RFM scoring + segmentation
- summary visuals and insights

**Notebook:** `./retail_data_analytics_wrangling.ipynb`

---

## RFM Segmentation (Customer Grouping)
RFM groups customers based on:
- **Recency:** how recently a customer purchased
- **Frequency:** how often they purchase
- **Monetary:** how much they spend overall

After scoring, customers are classified into meaningful segments (examples):
- **Champions** (high value, recent, frequent)
- **Potential Loyalists** (showing strong signals, need nurturing)
- **Hibernating** (purchased before, not recently active)

---

## Business Value Delivered
### 1) More Effective Marketing Targeting
Instead of blasting the same message to everyone, the marketing team can tailor campaigns:

- **Hibernating:** reactivation offers like “We miss you” discounts or limited-time coupons  
- **Potential Loyalists:** loyalty nudges (free shipping thresholds, points programs, bundles)  
- **Champions:** VIP benefits (early access, exclusive drops, thank-you rewards)

### 2) Revenue and Retention Focus
- Protect the highest lifetime-value customers (Champions)
- Recover lost revenue by re-engaging churn-risk customers (Hibernating)
- Improve repeat purchasing by moving customers upward through segments

---

## Future Enhancements
If this project were extended, the next steps would be:

1. **Automated ETL**
   - Replace manual loads with a scheduled pipeline (e.g., daily ingestion)
   - Use a Python job to fetch new files/exports and update the warehouse automatically

2. **Cloud Hosting**
   - Deploy containers to a cloud VM (e.g., AWS EC2)
   - Enable 24/7 access for the team and support collaboration

3. *(Optional)* **Operational Dashboards**
   - Add a BI layer (Power BI / Metabase) for self-serve segmentation and KPIs

---

## Deliverables
- Dockerized PostgreSQL warehouse (local analytics-ready environment)
- Cleaned and aggregated customer dataset
- RFM scores + segment labels
- Notebook with analysis and visual outputs

---

