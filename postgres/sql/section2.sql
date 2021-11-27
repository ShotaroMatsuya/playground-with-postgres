-- Filtering by WHERE

SELECT name, area FROM cities WHERE area > 4000;

SELECT name, area FROM cities WHERE area <> 8223;

SELECT name, area FROM cities WHERE area  BETWEEN 2000 AND 4000;

SELECT name , area FROM cities WHERE name NOT IN ('Delhi', 'Shanghai');

SELECT name, area FROM cities WHERE area NOT IN (3043,8223) AND name = 'Delhi';
SELECT name, area FROM cities WHERE area NOT IN (3043,8223) OR name = 'Delhi';

SELECT name, population / area AS population_density FROM cities WHERE population / area > 6000;

UPDATE cities SET population = 39505000 WHERE name = 'Tokyo';

DELETE FROM cities WHERE name = 'Tokyo';