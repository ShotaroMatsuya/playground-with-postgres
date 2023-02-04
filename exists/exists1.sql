SELECT * FROM employees E
WHERE E.department_id IN (SELECT id FROM departments);

SELECT * FROM employees E
WHERE EXISTS (
  SELECT 'x' FROM departments D WHERE E.department_id = D.id AND D.name IN ('営業部', '開発部')
);


SELECT * FROM customers;

SELECT * FROM customers C1
WHERE EXISTS (
  SELECT 'x' FROM customers C2 WHERE C1.first_name = C2.first_name AND C1.last_name = C2.last_name AND C1.phone_number = C2.phone_number
);


-- NOT EXISTS の場合(NULLを取り出せる：相関サブクエリはいずれの表も返さないため,WHEREで評価される)
SELECT * FROM customers C1
WHERE NOT EXISTS (
  SELECT 'x' FROM customers C2 WHERE C1.first_name = C2.first_name AND C1.last_name = C2.last_name AND C1.phone_number = C2.phone_number
);

-- NOT INの場合(NULLを取り出せない：相関サブクエリの返り値がunknownになるため WHEREで評価されない)
SELECT * FROM customers C1
WHERE (first_name, last_name, phone_number) NOT IN (
  SELECT first_name, last_name, phone_number FROM customers C2
);

-- EXCEPT(差集合) → NOT EXISTSで代用

SELECT * FROM customers;
SELECT * FROM customers_2;

-- EXCEPTの場合
SELECT * FROM customers
EXCEPT
SELECT * FROM customers_2;

-- NOT EXISTSの場合(NULLを含むカラムには注意が必要)
SELECT * FROM customers C1
WHERE NOT EXISTS (
  SELECT 'x' FROM customers_2 C2
  WHERE C1.id = C2.id AND C1.first_name = C2.first_name AND C1.last_name = C2.last_name AND (C1.phone_number = C2.phone_number OR (C1.phone_number IS NULL AND C2.phone_number IS NULL)) AND C1.age = C2.age
);


-- INTERSECT(積集合) → EXISTSで代用

-- INTERSECTの場合
SELECT * FROM customers
INTERSECT
SELECT * FROM customers_2;

-- EXISTSの場合(NULLを含むカラムには注意が必要)
SELECT * FROM customers C1
WHERE EXISTS (
  SELECT 'x' FROM customers_2 C2
  WHERE C1.id = C2.id AND C1.first_name = C2.first_name AND C1.last_name = C2.last_name AND (C1.phone_number = C2.phone_number OR (C1.phone_number IS NULL AND C2.phone_number IS NULL)) AND C1.age = C2.age
);