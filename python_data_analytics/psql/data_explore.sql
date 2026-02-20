-- Show table schema 
\d+ retail;

-- Q1: Show first 10 rows
SELECT * FROM retail limit 10;

-- Q2: Check # of records
SELECT count(*) FROM retail;

-- Q3: Number of clients (unique client ID)
SELECT count(DISTINCT customer_id) FROM retail;

-- Q4: Invoice date range (max/min)
SELECT max(invoice_date), min(invoice_date) FROM retail;

-- Q5: Number of SKU/merchants (unique stock code)
SELECT count(DISTINCT stock_code) FROM retail;

-- Q6: Calculate average invoice amount excluding invoices with a negative amount
WITH invoice_totals AS (
    SELECT invoice_no, SUM(unit_price * quantity) as total_amt
    FROM retail
    GROUP BY invoice_no
    HAVING SUM(unit_price * quantity) > 0
)
SELECT AVG(total_amt) FROM invoice_totals;

-- Q7: Calculate total revenue (sum of unit_price * quantity)
SELECT SUM(unit_price * quantity) FROM retail;

-- Q8: Calculate total revenue by YYYYMM
SELECT
  CAST(EXTRACT(YEAR FROM invoice_date) AS INTEGER) * 100 + CAST(EXTRACT(MONTH FROM invoice_date) AS INTEGER) as yyyymm,
  SUM(unit_price * quantity) as revenue
FROM retail
GROUP BY yyyymm
ORDER BY yyyymm;

