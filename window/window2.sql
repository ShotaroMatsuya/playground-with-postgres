-- ORDER BY (デフォルトだとフレームは最初から同じ値の行まで)

SELECT *, COUNT(*) OVER(ORDER BY age) AS tmp_count
FROM employees;

SELECT * , SUM(order_price) OVER(ORDER BY order_date DESC)
FROM orders;

SELECT FLOOR(age/ 10), COUNT(*) OVER(ORDER BY FLOOR(age/10)) FROM employees;


