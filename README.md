# 🏁 Formula 1 Data Engineering & Analytics Project

# Author: AZAMBEK ANVAROV

## 📌 Project Overview

This project demonstrates an end-to-end Data Engineering workflow using a Formula 1 dataset.
The goal is to transform raw race data into business-ready insights and visualize them in an interactive dashboard.

The project follows a **Medallion Architecture (Bronze → Silver → Gold)** approach to ensure data quality, scalability, and analytical usability.

---

## 🏗️ Architecture

* **Bronze Layer**
  Raw ingestion of Formula 1 datasets (no transformations)

* **Silver Layer**
  Data cleaning, standardization, and joins

  * Fixed data types
  * Removed inconsistencies
  * Prepared relational structure

* **Gold Layer**
  Business-level aggregations and KPIs for analytics

  * Driver performance metrics
  * Constructor performance
  * Race-level insights
  * Championship progression

---

## 📊 Gold Layer Tables

### 1. `gold_driver_summary`

Driver-level KPIs per season:

* Total races
* Wins & Podiums
* Total points
* Average finish position
* DNF count
* Win rate

---

### 2. `gold_constructor_summary`

Team performance analytics:

* Total points
* Wins
* Podiums
* Average position

---

### 3. `gold_race_summary`

Race-level insights:

* Winner
* Total drivers
* DNF count
* Average position

---

### 4. `gold_championship_progress`

Season progression using window functions:

* Cumulative points per driver
* Race-by-race performance tracking

---

## 📈 Dashboard (Tableau)

Built using Tableau

Key features:

* Driver ranking by total points
* Win rate vs podium analysis
* Average finish position comparison
* DNF impact analysis
* Championship progression (line chart)

---

## 🛠️ Technologies Used

* SQL (PostgreSQL)
* Data Modeling
* ETL / ELT concepts
* Window Functions
* Tableau (Data Visualization)

---

## 🚀 Key Learnings

* Designed a multi-layer data architecture
* Built analytical datasets for BI tools
* Applied business logic to raw data
* Created interactive dashboards for insights
* Handled data quality and type inconsistencies

---


## 📂 Future Improvements

* Add real-time data pipeline
* Integrate Apache Airflow for orchestration
* Expand advanced analytics (driver consistency, strategy analysis)
* Deploy dashboard online

---

## 💡 Conclusion

This project showcases how raw data can be transformed into meaningful business insights using modern data engineering practices and visualization tools.
