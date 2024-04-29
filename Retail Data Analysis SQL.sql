USE project1;


-- Data Preparation

--Qus1
SELECT * FROM dbo.Customer;
SELECT * FROM dbo.Transactions;
SELECT * FROM dbo.prod_cat_info;


--Qus2
SELECT Count(*) 
FROM dbo.Transactions
WHERE Qty < 0;


--Qus3
SELECT CONVERT(date, tran_date, 105) AS tran_date
FROM dbo.Transactions
ORDER BY tran_date;


--Qus4
SELECT 
     DATEDIFF(day, max(CONVERT(date, tran_date, 105)), min(CONVERT(date, tran_date, 105))) AS days,
     DATEDIFF(month, max(CONVERT(date, tran_date, 105)), min(CONVERT(date, tran_date, 105))) AS months,
     DATEDIFF(year, max(CONVERT(date, tran_date, 105)), min(CONVERT(date, tran_date, 105))) AS years
FROM dbo.Transactions;


--Qus5
SELECT prod_cat
FROM prod_cat_info
WHERE prod_subcat = 'DIY';


--Data Analysis

--Qus1
SELECT Top 1 
     COUNT(*), 
     Store_type
FROM dbo.Transactions
GROUP BY Store_type
ORDER BY Store_type;


--Qus2
SELECT 
     Gender,
     Case 
          WHEN Gender = 'M' THEN count(Gender)
          WHEN Gender = 'F' THEN count(Gender)
     End AS Count
FROM dbo.Customer
GROUP BY Gender;


--Qus3
SELECT Top 1 
     city_code AS City, 
     COUNT(*) AS Count
FROM dbo.Customer
GROUP BY city_code
ORDER BY Count DESC;


--Qus4
SELECT 
     prod_cat, 
     COUNT(prod_subcat) AS Count
FROM dbo.prod_cat_info
WHERE prod_cat = 'Books'
GROUP BY prod_cat;


--Qus5
SELECT 
     tran_date,
     sum(Qty) AS Total_Qty
FROM dbo.Transactions
GROUP BY tran_date
ORDER BY Total_Qty DESC;


--Qus6
SELECT 
     p.prod_cat,
     sum(t.total_amt) AS Total_Rev
FROM dbo.Transactions AS t
INNER JOIN dbo.prod_cat_info AS p 
     ON t.prod_cat_code = p.prod_cat_code AND t.prod_subcat_code = p.prod_sub_cat_code
WHERE p.prod_cat = 'Electronics' OR p.prod_cat = 'Books'
GROUP BY p.prod_cat;


--Qus7
SELECT COUNT(*) AS Total_Cust
FROM
    (SELECT 
          c.customer_Id,
          count(t.Qty) AS Total_tran      
     FROM dbo.Transactions AS t
     INNER JOIN dbo.Customer AS c
         ON t.cust_id = c.customer_Id
     WHERE t.Qty > 0 
     GROUP BY c.customer_Id
     HAVING count(t.Qty) > 10) As subquery;


--Qus8
SELECT sum(Total_Rev)  Total_Revenue
FROM(    
     SELECT 
          p.prod_cat,
          sum(t.total_amt) AS Total_Rev
     FROM dbo.Transactions AS t
     INNER JOIN dbo.prod_cat_info AS p 
          ON t.prod_cat_code = p.prod_cat_code AND t.prod_subcat_code = p.prod_sub_cat_code
     WHERE (p.prod_cat = 'Electronics' OR p.prod_cat = 'Clothing') AND Store_type = 'Flagship Store'
     GROUP BY p.prod_cat) AS subquery;


--Qus9
SELECT 
     p.prod_subcat,
     sum(t.total_amt) AS Total_Rev
FROM dbo.Customer AS c
INNER Join dbo.Transactions AS t
     ON c.customer_Id = t.cust_id
INNER JOIN dbo.prod_cat_info AS p 
     ON t.prod_cat_code = p.prod_cat_code AND t.prod_subcat_code = p.prod_sub_cat_code
WHERE p.prod_cat = 'Electronics' AND c.Gender = 'M'
GROUP BY p.prod_subcat ;


--Qus10
SELECT Top 5 
     p.prod_subcat,
     (SUM(CASE when t.Qty > 0 then 1 else 0 END ) * 1.0/ COUNT(*)) * 100 AS Sales,
     (SUM(CASE when t.Qty < 0 then 1 else 0 END ) * 1.0/ COUNT(*)) * 100 AS Returns
FROM dbo.Transactions AS t
INNER JOIN dbo.prod_cat_info AS p 
     ON t.prod_cat_code = p.prod_cat_code AND t.prod_subcat_code = p.prod_sub_cat_code
GROUP BY p.prod_subcat 
ORDER BY Sales DESC;

--Qus11
SELECT 
     SUM(t.total_amt) AS net_total_revenue
FROM dbo.Transactions AS t
JOIN Cdbo.Customer AS c
     ON t.cust_id = c.customer_id
WHERE DATEDIFF(DAY, t.tran_date, GETDATE()) <= 30 AND DATEDIFF(YEAR, c.DOB, GETDATE()) BETWEEN 25 AND 35;


--Qus12
SELECT 
     p.prod_cat, 
     SUM(t.total_amt) AS total_return_value
FROM dbo.Transactions AS t
JOIN dbo.prod_cat_info as p
     ON t.prod_cat_code = p.prod_cat_code
WHERE t.tran_date >= DATEADD(MONTH, -3, GETDATE())
AND t.total_amt < 0
GROUP BY p.prod_cat
ORDER BY total_return_value DESC
LIMIT 1;



--Qus13
SELECT 
    Store_type, 
    MAX(total_sales_amount) AS max_sales_amount, 
    MAX(total_quantity_sold) AS max_quantity_sold
FROM (
    SELECT 
        Store_type, 
        SUM(total_amt) AS total_sales_amount,
        0 AS total_quantity_sold
    FROM dbo.Transactions
    GROUP BY Store_type
    UNION ALL
    SELECT 
        Store_type, 
        0 AS total_sales_amount,
        SUM(Qty) AS total_quantity_sold
    FROM dbo.Transactions
    GROUP BY Store_type
) AS combined
GROUP BY Store_type;



--Qus14
SELECT prod_cat
FROM (
    SELECT prod_cat, AVG(total_amt) AS avg_revenue
    FROM dbo.Transactions
    GROUP BY prod_cat
) AS category_avg
WHERE avg_revenue > ( SELECT AVG(total_amt) FROM dbo.Transactions);



--Qus15
WITH Top5Categories AS (
    SELECT 
          prod_cat_code, 
          SUM(Qty) AS total_quantity
    FROM dbo.Transactions
    GROUP BY prod_cat_code
    ORDER BY total_quantity DESC
    LIMIT 5
)
SELECT 
    pc.prod_cat, 
    psi.prod_subcat, 
    AVG(t.total_amt) AS avg_revenue, 
    SUM(t.total_amt) AS total_revenue
FROM dbo.Transactions t
JOIN prod_cat_info pc 
     ON t.prod_cat_code = pc.prod_cat_code
JOIN prod_cat_info psi 
     ON t.prod_subcat_code = psi.prod_subcat_code
JOIN Top5Categories tc 
     ON t.prod_cat_code = tc.prod_cat_code
GROUP BY 
     pc.prod_cat,
      psi.prod_subcat;


