CREATE TABLE Products(
    id SERIAL PRIMARY KEY,
    name VARCHAR(30),
    price INTEGER
);
INSERT INTO Products (name,price) VALUES('りんご',50),('みかん',100),
('ぶどう',50),('スイカ',80),('レモン',30),
('いちご',100),('バナナ',100);

-- 重複順列
SELECT P1.name AS name_1, P2.name AS name_2
FROM Products P1, Products P2;

-- 順列①　
SELECT P1.name AS name_1, P2.name AS name_2 
FROM Products P1 INNER JOIN Products P2
ON P1.name <> P2.name;
-- 順列②ー非推奨
SELECT P1.name AS name_1, P2.name AS name_2 
FROM Products P1, Products P2 
WHERE P1.name <> P2.name;

-- 組み合わせ
SELECT P1.name AS name_1, P2.name AS name_2 
FROM Products P1 INNER JOIN Products P2
ON P1.name > P2.name;

-- 組み合わせ3列
SELECT P1.name AS name_1, P2.name AS name_2 ,P3.name AS name_3
FROM Products P1 
INNER JOIN Products P2 ON P1.name > P2.name
INNER JOIN Products P3 ON P2.name > P3.name;

-- 重複組合せ
SELECT P1.name AS name_1, P2.name AS name_2
FROM Products P1 
INNER JOIN Products P2 ON P1.name  >= P2.name 


-- 重複する行の削除①
DELETE FROM Products P1 
WHERE id < (
    SELECT MAX(P2.id) 
    FROM Products P2 
    WHERE P1.name = P2.name 
    AND P1.price = P2.price
);

-- 重複する行の削除② (EXISTS句)
DELETE FROM Products P1 
WHERE EXISTS (
    SELECT * FROM Products P2 
    WHERE P1.name = P2.name 
    AND P1.price = P2.price 
    AND P1.id < P2.id
);

-- 部分的に不一致(一致)なキーの検索
CREATE TABLE Addresses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(30),
    family_id INTEGER,
    address VARCHAR(255)
);

INSERT INTO Addresses (name, family_id, address) 
VALUES
('前田義明',100,'東京都港区虎ノ門3-2-29'),('前田由美',100,'東京都港区虎ノ門3-2-92'),
('加藤茶',200,'東京都新宿区西新宿2-8-1'),('加藤勝',200,'東京都新宿区西新宿2-8-1'),
('ホームズ',300,'ベーカー街221B'),('ワトソン',400,'ベーカー街221B');

-- 同じ家族で違うaddress
SELECT DISTINCT A1.name, A1.address 
FROM Addresses A1 INNER JOIN Addresses A2
ON A1.family_id = A2.family_id 
AND A1.address <> A2.address;

INSERT INTO Products (name,price) VALUES('りんご',50),('みかん',100),
('ぶどう',50),('スイカ',80),('レモン',30),
('いちご',100),('バナナ',100);

-- 同じ値段で違う商品名
SELECT DISTINCT P1.name , P1.price 
FROM Products P1 INNER JOIN Products P2 
ON P1.price = P2.price 
AND P1.name <> P2.name 
ORDER BY P1.price;




