SELECT * FROM employees;

-- OVER
SELECT *, AVG(age) OVER(), COUNT(*) OVER()
FROM employees;

-- PARTITION BY
SELECT * , AVG(age) OVER(PARTITION BY department_id) AS avg_age,
COUNT(*) OVER(PARTITION BY department_id) AS count_department
FROM employees;

-- 年代別人口
SELECT DISTINCT CONCAT(COUNT(*) OVER(PARTITION BY FLOOR(age/10)), '人') AS "人数", FLOOR(age/10) * 10 AS "年代"
FROM employees;

-- 月別売上
SELECT *, TO_CHAR(order_date, 'YYYY/MM'), SUM(order_amount*order_price) OVER(PARTITION BY TO_CHAR(order_date, 'YYYY/MM'))
FROM orders;