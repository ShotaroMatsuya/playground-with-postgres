-- クロス表の作成
CREATE TABLE course_masters(
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(30),
);

CREATE TABLE open_courses(
    id SERIAL PRIMARY KEY,
    month INTEGER,
    course_id REFERENCES course_masters(course_id) ON DELETE CASCADE
);

INSERT INTO course_masters(course_name) VALUES ('経理入門','財務知識','簿記検定開講講座','税理士');
INSERT INTO open_courses(month,course_id) VALUES(201806,1),(201806,3),(201806,4),(201807,4),(201808,2),(201808,4);


SELECT CM.course_name,
    CASE WHEN EXISTS (
        SELECT course_id FROM open_courses OC 
        WHERE month = 201806 AND OC.course_id = CM.course_id
    ) THEN '○' ELSE '✗' END AS "6月",
    CASE WHEN EXISTS (
        SELECT course_id FROM open_courses OC WHERE month = 201807 AND OC.course_id = CM.course_id 
    ) THEN '○' ELSE '✗' END AS "7月",
    CASE WHEN EXISTS (
        SELECT course_id FROM open_couses OC WHERE month = 201808 AND OC.course_id = CM.course_id
    ) THEN '○' ELSE '✗' END AS "8月"
FROM course_masters CM;

CREATE TABLE Class_A(
    id SERIAL PRIMARY KEY,
    name VARCHAR(30),
    age INTEGER,
    city VARCHAR(30)
);

CREATE TABLE Class_B(
    id SERIAL PRIMARY KEY,
    name VARCHAR(30),
    age INTEGER,
    city VARCHAR(30)
);

INSERT INTO Class_A
(name,age,city) VALUES
('ブラウン',22,'東京'),
('ラリー',19,'埼玉'),
('ボギー',21,'千葉');
INSERT INTO Class_B
(name,age,city) VALUES
('斎藤',22,'東京'),('田尻',23,'東京'),
('山田',NULL,'東京'),('和泉',18,'千葉'),
('武田',20,'千葉'),('石川',19,'神奈川');

-- Bクラスの東京在住の生徒と年齢が一致しないAクラスの生徒を選択する（間違い）
SELECT * FROM Class_A 
WHERE age NOT IN (
    SELECT age 
    FROM Class_B 
    WHERE city = '東京'
);

-- 正解
SELECT * FROM Class_A A
WHERE NOT EXISTS (
    SELECT * FROM Class_B B
    WHERE A.age = B.age AND B.city = '東京'
);

-- 存在しないデータを探す

CREATE TABLE Meetings (
    id SERIAL PRIMARY KEY,
    meeting VARCHAR(30),
    person VARCHAR(30)
);

INSERT INTO Meetings (meeting,person) VALUES
('第一回','伊藤'),
('第一回','水島'),
('第一回','坂東'),
('第二回','伊藤'),
('第二回','宮田'),
('第三回','坂東'),
('第三回','水島'),
('第三回','宮田');

-- 欠席者を求めるクエリ(NOT EXISTS差集合演算)
SELECT DISTINCT M1.meeting, M2.person
FROM Meetings M1 CROSS JOIN Meetings M2 
WHERE NOT EXISTS (
    SELECT * FROM Meetings M3 
    WHERE M1.meeting = M3.meeting 
    AND M2.person = M3.person
);

-- 欠席者を求めるクエリ(EXCEPT 差集合演算)
(SELECT M1.meeting, M2.meeting 
FROM Meetings M1, Meetings M2)
EXCEPT 
(SELECT meeting, person 
FROM Meetings);

-- 二条否定への変換（行の全称量化）
CREATE TABLE TestScores (
    id SERIAL PRIMARY KEY,
    student_id INTEGER,
    subject VARCHAR(50),
    score INTEGER
);
INSERT INTO TestScores
(student_id, subject, score) VALUES
(100,'算数',100),
(100,'国語',80),
(100,'理科',80),
(200,'算数',80),
(200,'国語',95),
(300,'算数',40),
(300,'国語',90),
(300,'社会',55),
(400,'算数',80);
-- ある学生のすべての行について教科が50以上
-- 50未満である教科が1つも存在しない生徒
SELECT DISTINCT student_id 
FROM TestScores TS1 
WHERE NOT EXISTS ( 
    SELECT * FROM TestScores TS2
    WHERE TS2.student_id = TS1.student_id 
    AND TS2.score < 50
);

-- ある学生のすべての行において（算数ならば80以上かつ国語ならば50以上）である学生
-- ある学生のすべての行において（算数ならば80未満か国語ならば50未満）である行がひとつも存在しない生徒
SELECT DISTINCT student_id 
FROM TestScores TS1
WHERE subject IN ('算数','国語') 
AND NOT EXISTS (
    SELECT * FROM TestScores TS2
    WHERE TS2.student_id = TS1.student_id 
    AND 1 = CASE WHEN subject = '算数' AND score < 80 THEN 1
                 WHEN subject = '国語' AND score < 50 THEN 1
                 ELSE 0 END
);
GROUP BY student_id 
HAVING COUNT(*) = 2;

-- 全称量化の練習
CREATE TABLE Projects (
    id SERIAL PRIMARY KEY,
    project_id VARCHAR(30),
    step_nbr INTEGER,
    status VARCHAR(30)
);

INSERT INTO Projects (project_id, step_nbr, status) VALUES
('AA100',0,'完了'),
('AA100',1,'待機'),
('AA100',2,'待機'),
('B200',0,'待機'),
('B200',1,'待機'),
('CS300',0,'完了'),
('CS300',1,'完了'),
('CS300',2,'待機'),
('CS300',3,'待機'),
('DY400',0,'完了'),
('DY400',1,'完了'),
('DY400',2,'完了');

-- 工程1番まで完了のプロジェクト
SELECT project_id FROM Projects 
GROUP BY project_id 
HAVING COUNT(*) = SUM(CASE WHEN step_nbr <= 1 AND status = '完了' THEN 1
                           WHEN step_nbr > 1 AND status = '待機' THEN 1
                           ELSE 0 END);

-- プロジェクト内のすべての行において、（工程番号が1以下ならば完了、かつ1より大きれば待機）であるプロジェクト
-- あるプロジェクトのすべての行において、（工程番号が1以下なら待機、あるいは1より大きれば完了）である行が一つも存在しないプロジェクト
SELECT project_id FROM Projects P1
WHERE NOT EXISTS (
    SELECT * FROM Projects P2
    WHERE P1.project_id = P2.project_id
    AND 1 =  (CASE WHEN step_nbr <= 1 AND status <> '完了' THEN 1
                   WHEN step_nbr > 1 AND status <> '待機' THEN 1
              ELSE 0 END)
);

-- ALL述語で全称量化（二重否定に置き換える必要なしで楽だがパフォーマンス↓）
SELECT * FROM Projects P1
WHERE 1 = ALL (
    SELECT 
        CASE WHEN step_nbr <= 1 AND status = '完了' THEN 1 
             WHEN step_nbr > 1 AND status = '待機' THEN 1
        ELSE 0 END
    FROM Projects P2
    WHERE P1.project_id = P2.project_id
);

-- 列に対する全称量化
CREATE TABLE ArrayTbl(
    id SERIAL PRIMARY KEY,
    key VARCHAR(1),
    col1 INTEGER,
    col2 INTEGER,
    col3 INTEGER,
    col4 INTEGER,
    col5 INTEGER,
    col6 INTEGER,
    col7 INTEGER,
    col8 INTEGER,
    col9 INTEGER,
    col10 INTEGER
);
INSERT INTO ArrayTbl (key,col1,col2,col3,col4,col5,col6,col7,col8,col9,col10) VALUES
('A',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('B',3,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('C',1,1,1,1,1,1,1,1,1,1),
('D',NULL,9,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
('E',NULL,3,1,9,NULL,NULL,9,NULL,NULL,NULL);


-- 1.オール1の行を探す
SELECT * FROM ArrayTbl 
WHERE 1 = ALL(array[col1,col2,col3,col4,col5,col6,col7,col8,col9,col10]);

-- 2.少なくとも1つは9の行を探す
SELECT * FROM ArrayTbl 
WHERE 9 = SOME(array[col1,col2,col3,col4,col5,col6,col7,col8,col9,col10]);

SELECT * FROM ArrayTbl
WHERE 9 IN (col1,col2,col3,col4,col5,col6,col7,col8,col9,col10);

-- オールNULL
SELECT * FROM ArrayTbl
WHERE COALESCE(col1,col2,col3,col4,col5,col6,col7,col8,col9,col10) IS NULL;



-- 配列テーブル（行持ちのパターン）

CREATE TABLE ArrayTbl2(
    id SERIAL PRIMARY KEY,
    key VARCHAR(1),
    i INTEGER,
    val INTEGER
);

INSERT INTO ArrayTbl2 (key, i , val) VALUES
('A',1,NULL),
('A',2,NULL),
('A',3,NULL),
('A',4,NULL),
('A',5,NULL),
('A',6,NULL),
('A',7,NULL),
('A',8,NULL),
('A',9,NULL),
('A',10,NULL),
('B',1,3),
('B',2,NULL),
('B',3,NULL),
('B',4,NULL),
('B',5,NULL),
('B',6,NULL),
('B',7,NULL),
('B',8,NULL),
('B',9,NULL),
('B',10,NULL),
('C',1,1),
('C',2,1),
('C',3,1),
('C',4,1),
('C',5,1),
('C',6,1),
('C',7,1),
('C',8,1),
('C',9,1),
('C',10,1);

-- オール1のエンティティ(すべてのkeyにおいてvalが1でないものがひとつも存在しない)
-- 誤答
SELECT key FROM ArrayTbl2 A
WHERE NOT EXISTS (
    SELECT *
    FROM ArrayTbl2 B
    WHERE A.key = B.key
    AND B.val <> 1
);

-- 正当
-- (すべてのkeyにおいてvalが1でないものかつvalがNULLである)ものが一つも存在しない
SELECT key FROM ArrayTbl2 A
WHERE NOT EXISTS (
    SELECT * FROM ArrayTbl2 B
    WHERE A.key = B.key AND (
        B.val <> 1 OR B.val IS NULL
    )
);

-- 別解
SELECT DISTINCT key FROM ArrayTbl2 A
WHERE 1 = ALL (
    SELECT val FROM ArrayTbl2 B
    WHERE A.key = B.key
    );

-- 別解2
SELECT key 
FROM ArrayTbl2 
GROUP BY key 
HAVING SUM(CASE WHEN val = 1 THEN 1 ELSE 0 END) = 10;

