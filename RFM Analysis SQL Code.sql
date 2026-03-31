-- Step 1: Calculate RFM metrics for each customer
-- Recency: Days since last purchase
-- Frequency: Average number of transactions per year
-- Monetary: Average spending per year
WITH Customer_Statistics AS(
SELECT CustomerID,
       DATEDIFF(DAY, MAX(Purchase_Date), '2022/9/1') AS Recency,
       CASE WHEN DATEDIFF(YEAR, created_date, '2022/9/1') = 0 THEN 0
            ELSE ROUND(1.0 * COUNT(Transaction_ID)/DATEDIFF(YEAR, created_date, '2022/9/1'), 2)
       END AS Frequency,
       CASE WHEN DATEDIFF(YEAR, created_date, '2022/9/1') = 0 THEN 0
            ELSE ROUND(1.0 * SUM(GMV)/DATEDIFF(YEAR, created_date, '2022/9/1'), 2)
       END AS Monetary
FROM Customer_Transaction ct JOIN Customer_Registered cr ON ct.CustomerID = cr.ID
WHERE ct.Purchase_Date IS NOT NULL AND ct.Purchase_Date < '2022-09-01'
GROUP BY CustomerID, created_date
),
-- Step 2: Rank customers by each Recency, Frequency, Monetary metric
rn_RFM AS (
SELECT cs.*,
       ROW_NUMBER() OVER (ORDER BY Recency ASC) AS rn_Recency,
       ROW_NUMBER() OVER (ORDER BY Frequency ASC) AS rn_Frequency,
       ROW_NUMBER() OVER (ORDER BY Monetary ASC) AS rn_Monetary
FROM Customer_Statistics cs
),
-- Step 3: Assign R, F, M scores using quartile thresholds (25%, 50%, 75%)
-- Recency is inversely scored (lower is better)
-- Frequency & Monetary are positively scored (higher is better)
Customer_RFM AS (
SELECT CustomerID, Recency, Frequency, Monetary,
       -- R Score
       CASE WHEN Recency >= MIN(Recency)
                 AND Recency < (SELECT rr.Recency FROM rn_RFM rr WHERE rn_Recency = (SELECT ROUND(MAX(rn_Recency)*0.25,0) FROM rn_RFM)) THEN '4'
            WHEN Recency >= (SELECT rr.Recency FROM rn_RFM rr WHERE rn_Recency = (SELECT ROUND(MAX(rn_Recency)*0.25,0) FROM rn_RFM))
                 AND Recency < (SELECT rr.Recency FROM rn_RFM rr WHERE rn_Recency = (SELECT ROUND(MAX(rn_Recency)*0.5,0) FROM rn_RFM)) THEN '3'
            WHEN Recency >= (SELECT rr.Recency FROM rn_RFM rr WHERE rn_Recency = (SELECT ROUND(MAX(rn_Recency)*0.5,0) FROM rn_RFM))
                 AND Recency < (SELECT rr.Recency FROM rn_RFM rr WHERE rn_Recency = (SELECT ROUND(MAX(rn_Recency)*0.75,0) FROM rn_RFM)) THEN '2'
       ELSE '1'
       END AS R,
       -- F Score
       CASE WHEN Frequency >= MIN(Frequency)
                 AND Frequency < (SELECT rr.Frequency FROM rn_RFM rr WHERE rn_Frequency = (SELECT ROUND(MAX(rn_Frequency)*0.25,0) FROM rn_RFM)) THEN '1'
            WHEN Frequency >= (SELECT rr.Frequency FROM rn_RFM rr WHERE rn_Frequency = (SELECT ROUND(MAX(rn_Frequency)*0.25,0) FROM rn_RFM))
                 AND Frequency < (SELECT rr.Frequency FROM rn_RFM rr WHERE rn_Frequency = (SELECT ROUND(MAX(rn_Frequency)*0.5,0) FROM rn_RFM)) THEN '2'
            WHEN Frequency >= (SELECT rr.Frequency FROM rn_RFM rr WHERE rn_Frequency = (SELECT ROUND(MAX(rn_Frequency)*0.5,0) FROM rn_RFM))
                 AND Frequency < (SELECT rr.Frequency FROM rn_RFM rr WHERE rn_Frequency = (SELECT ROUND(MAX(rn_Frequency)*0.75,0) FROM rn_RFM)) THEN '3'
       ELSE '4'
       END AS F,
       -- M Score
       CASE WHEN Monetary >= MIN(Monetary)
                 AND Monetary < (SELECT rr.Monetary FROM rn_RFM rr WHERE rn_Monetary = (SELECT ROUND(MAX(rn_Monetary)*0.25,0) FROM rn_RFM)) THEN '1'
            WHEN Monetary >= (SELECT rr.Monetary FROM rn_RFM rr WHERE rn_Monetary = (SELECT ROUND(MAX(rn_Monetary)*0.25,0) FROM rn_RFM))
                 AND Monetary < (SELECT rr.Monetary FROM rn_RFM rr WHERE rn_Monetary = (SELECT ROUND(MAX(rn_Monetary)*0.5,0) FROM rn_RFM)) THEN '2'
            WHEN Monetary >= (SELECT rr.Monetary FROM rn_RFM rr WHERE rn_Monetary = (SELECT ROUND(MAX(rn_Monetary)*0.5,0) FROM rn_RFM))
                 AND Monetary < (SELECT rr.Monetary FROM rn_RFM rr WHERE rn_Monetary = (SELECT ROUND(MAX(rn_Monetary)*0.75,0) FROM rn_RFM)) THEN '3'
       ELSE '4'
       END AS M
FROM rn_RFM
GROUP BY CustomerID, Recency, Frequency, Monetary
),
-- Step 4: Combine R, F, M into a single RFM score
RFM AS (
SELECT cr.*, CONCAT(R, F, M) AS RFM
FROM Customer_RFM cr
)
-- Step 5: Map RFM score to customer segments
SELECT CAST(CustomerID AS VARCHAR) AS CustomerID, R, F, M, rfm.RFM, cs.Customer_Segment AS "Customer Segment", cs.BCG_Matrix AS "BCG Matrix Segment"
FROM RFM rfm JOIN customer_segment cs ON rfm.RFM = cs.RFM
