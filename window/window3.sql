-- PARTITION BY + ORDER BY

SELECT *, 
MAX(age) OVER(PARTITION BY department_id ORDER BY age ASC) AS count_value
FROM employees;

-- 人毎の最大収入
SELECT e.id, e.first_name, e.last_name ,s.paid_date,s.payment, 
MAX(s.payment) OVER(PARTITION BY e.id)
FROM employees e
INNER JOIN salaries s
ON e.id = s.employee_id;

-- 月別、合計収入　集計表
SELECT e.id, e.first_name, e.last_name,s.paid_date,
SUM(s.payment) OVER(PARTITION BY s.paid_date ORDER BY e.id)
FROM employees e
INNER JOIN salaries s
ON e.id = s.employee_id;

-- SELECT paid_date ,e.id, MAX(payment)
-- FROM employees e
-- INNER JOIN salaries s
-- ON e.id = s.employee_id
-- GROUP BY paid_date, e.id
-- ORDER BY s.paid_date ASC;