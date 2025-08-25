# HealthTail BI Solution: End-to-End Analytics Project

![Dashboard Preview](docs/dashboard_preview.png)

## 📄 Project Overview

This project is a comprehensive Business Intelligence solution for **HealthTail**, a large veterinary hospital. The goal is to automate their medication auditing process and analyze disease trends among patients.

The project transforms raw `.csv` data into an interactive **Looker Studio dashboard** by leveraging Google Cloud Platform (GCP) services. It demonstrates a complete end-to-end data workflow: from data ingestion and transformation in **BigQuery** to final visualization.

---

## 🚀 Core Business Problems

HealthTail faced two key challenges that this project addresses:

1.  **Auditing Medication Expenses:** The need for a streamlined way to track and analyze annual spending on medications.
2.  **Monitoring Disease Trends:** The desire to identify common diagnoses to optimize staffing and medication procurement, with segmentation by pet type and breed.

---

## 🛠️ Tech Stack & Architecture

* **Cloud Provider:** Google Cloud Platform (GCP)
* **Data Warehouse:** Google BigQuery
* **BI & Visualization:** Looker Studio
* **Data Source:** Raw `.csv` files

### Architecture Diagram

The project follows a modern data stack architecture where data flows from the source files to the final dashboard.

![Architecture](docs/architecture.png)

---

## 📊 Dashboard Analysis & Key Findings

An interactive Looker Studio dashboard was developed to visualize key operational metrics and disease trends. The dashboard provides insights into the most common diagnoses by pet type and breed, analyzes treatment costs versus disease frequency, and tracks trends over time.

> **[➡️ Click here for a detailed breakdown of the dashboard and key findings](docs/Dashboard_Analysis.md)**

---

## 🔗 Live Dashboard

> **[➡️ View the Interactive Looker Studio Report](https://lookerstudio.google.com/reporting/2ee942e6-b8f9-43f1-98a1-f98f33bad7d3)**
