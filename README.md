# Customer 360 — RFM Segmentation Analysis

![Azure SQL](https://img.shields.io/badge/Azure%20SQL-0078D4?style=flat-square&logo=microsoftazure&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=flat-square&logo=powerbi&logoColor=black)
![Looker Studio](https://img.shields.io/badge/Looker%20Studio-4285F4?style=flat-square&logo=googleanalytics&logoColor=white)
![Status](https://img.shields.io/badge/Status-Completed-2EA44F?style=flat-square)

> Segmenting customers into actionable BCG Matrix segments to enable more effective personalized marketing for year-end campaigns.

---

## Table of contents

- [1. Business context](#1-business-context)
- [2. Data sources](#2-data-sources)
- [3. RFM Analysis](#3-rfm-analysis)
- [4. Recommended actions per segment](#4-recommended-actions-per-segment)
---

## 1. Business context

The marketing team was running a year-end campaign but treating all customers the same wastes CS resources and reduces conversion rates.

**Goal:** Build a data-driven segmentation model that classifies existing customers into distinct, well-characterized groups, labels each segment clearly, and recommends tailored care policies so the CS team can act on them immediately.

---

## 2. Data sources

| Table | Description | Key field |
|---|---|---|
| `Customer_Registered` | Contains detailed information about customers  who have registered membership cards | `ID` (PK) |
| `Customer_Transaction` | Contains detailed transaction of customers  from June 2022 to August 2022 | `Transactions_ID` (PK) <br> `Customer_ID` (FK) |

---

## 3. RFM Analysis

### Step 1 — Compute RFM metrics

| Metric | Definition |
|---|---|
| **Recency** | Days since the customer's most recent purchase |
| **Frequency** | Average number of transactions per contract-age year |
| **Monetary** | Average spend per contract-age year |

### Step 2 — Score each metric using the IQR method

Scores are determined by categorizing each customer’s metric value into its corresponding interquartile range.

**Recency** - lower values indicate more active customers:

| Range | Score |
|---|---|
| Min → Q1 | 4 |
| Q1 → Q2 | 3 |
| Q2 → Q3 | 2 |
| Q3 → Max | 1 |

**Frequency & Monetary** - higher values indicate better customers:

| Range | Score |
|---|---|
| Min → Q1 | 1 |
| Q1 → Q2 | 2 |
| Q2 → Q3 | 3 |
| Q3 → Max | 4 |

Each customer is evaluated using three metrics - R_score, F_score, and M_score - each scored on a scale from 1 to 4.

### Step 3 — Map to segments using the BCG Matrix

RFM score combinations are mapped to four strategic customer groups based on the BCG Matrix:

| **BCG Matrix** | **Customer Segment** | **RFM Score** | **Description** |
|---|---|---|---|
| ⭐ Star | **VIP Customers** | 333, 334, 343, 344, 433, 434, 443, 444 | Customers who **buy recently**, **frequently**, and **spend the most**. They are the most valuable customers. |
| 🐄 Cash Cows | **Loyal Customers** | 232, 233, 234, 242, 243, 244, 332, 342, 432, 442 | Customers who **buy regularly** and **maintain steady spending**. |
| ❓ Question Marks | **Potential Customers** | 223, 224, 312, 321, 322, 323, 324, 331, 341, 412, 421, 422, 423, 424, 431, 441 | Customers who **buy recently**, have low purchase frequency or spending, but **showing potential for future growth**. |
| 🐕 Dogs | **At-Risk Customers** | 122, 123, 124, 132, 133, 134, 142, 143, 144 | Customers who **used to buy frequently or spend well** but have **not bought recently** and may stop buying. |
| 🐕 Dogs | **Occasional Customers** | 111, 112, 121, 131, 141, 211, 212, 221, 222, 231, 241, 311, 411 | Customers who **buy occasionally** and have **low spending**. |

---

## 4. Recommended actions per segment

| **BCG Matrix** | **Customer Segment** | **Recommeded actions** |
|---|---|---|
| ⭐ Star | **VIP Customers <br> - Retain & reward** | • Launch VIP program: priority support, birthday gifts, free shipping. <br> • Send personalized product recommendations based on purchase history. <br> • If VIP hasn't bought in 25–30 days → send a retention offer immediately. |
| 🐄 Cash Cows | **Loyal Customers <br> - Upgrade to VIP** | • Show how close they are to the VIP segment (for example, "2 more orders to become VIP customer"). <br> • Offer bundle deals and cross-sells to increase order value and purchase frequency. <br> • Give points for repeat purchases - more buys = more rewards. |
| ❓ Question Marks | **Potential Customers <br> - Drive next purchase** | • Send a 3–5 email welcome sequence highlighting product value & tips. <br> • Offer a short-term discount (for example, 10% off the next order within 7 days). <br> • Test messaging: price, benefits, or social proof. |
| 🐕 Dogs | **At-Risk Customers <br> - Win-Back strategy** | • Send a personalized message about their past orders and the special offers. <br> • Create urgency: limited-time discount or bonus points. <br> • If no response after 2–3 tries → reduce contact frequency to avoid annoying the customers. |
| 🐕 Dogs | **Occasional Customers <br> - Keep costs low** | • Use only automated channels: newsletter, seasonal promotion, and major sales. <br> • Avoid paid retargeting or manual outreach. <br> • Monitor activity: if buying more frequently → move to "Potential Customers" flow. |

---
