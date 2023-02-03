-- sales テーブルのorder_price*order_amountの合計値の7日間平均を求める

SELECT order_date, order_price * order_amount FROM orders ORDER BY order_date;

-- 日別 売上合計
SELECT *,
SUM(order_price*order_amount) OVER(PARTITION BY order_date)
FROM orders;

-- 日別売上合計 7日間平均
-- まず日別の合計値を求める
WITH daily_summary AS(
SELECT order_date, SUM(order_price * order_amount) AS sale
FROM orders
GROUP BY order_date)

-- 次に7日間ごとに集計する
SELECT *,
AVG(sale) OVER(ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
FROM daily_summary;

-- ORDER BYと PARTITION BYの集計処理の違い
-- ORDER BYはデフォルトだとORDER区間同士の比較では最初の区間から追加していく
-- 一方PARTITION BYだと、パーティション区間を超えたら比較に用いていた値はリセットされる

-- 年齢の範囲に応じて収入の合計値を集計
SELECT *,
SUM(summary_salary.payment) 
OVER(ORDER BY age RANGE BETWEEN 3 PRECEDING AND CURRENT ROW) AS p_summary
FROM employees AS emp
INNER JOIN
  (SELECT employee_id,
  SUM(payment) AS payment
  FROM salaries
  GROUP BY employee_id) AS summary_salary -- 従業員ごとの収入合計
ON emp.id = summary_salary.employee_id;