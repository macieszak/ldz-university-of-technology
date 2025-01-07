SET CURRENT SCHEMA A10@
VALUES CURRENT SCHEMA@
SELECT SCHEMANAME FROM SYSCAT.SCHEMATA WHERE DEFINER = 'DB2ADMIN'@

-- 1. Napisać funkcję zamieniajacą wszystkie spacje podkreśleniem (można wewnątrz funkcji wykorzystać inne funkcje wbudowane).
CREATE OR REPLACE FUNCTION A10.REPLACE_SPACES(input_string VARCHAR(100))
RETURNS VARCHAR(100)
BEGIN
    RETURN REPLACE(input_string, ' ', '_');
END@

SELECT A10.REPLACE_SPACES('Hello World Test') AS RESULT FROM SYSIBM.SYSDUMMY1@

-- 2. Napisać funkcję do odwracania stringu (można wewnątrz funkcji wykorzystać inne funkcje wbudowane).
CREATE OR REPLACE FUNCTION A10.REVERSE_STRING(input_string VARCHAR(100))
RETURNS VARCHAR(100)
BEGIN
    DECLARE reversed_string VARCHAR(100) DEFAULT '';
    DECLARE i INTEGER;
    
    SET i = LENGTH(input_string);
    
    WHILE i > 0 DO
        SET reversed_string = reversed_string || SUBSTR(input_string, i, 1);
        SET i = i - 1;
    END WHILE;
    
    RETURN reversed_string;
END@

SELECT A10.REVERSE_STRING('Hello World') AS RESULT FROM SYSIBM.SYSDUMMY1@

-- 3. Napisać funkcję, która sprawdza czy liczba znaków jest większa niż parametr a1 oraz w stringu musi być jedna duża litera. 
-- Funkcja zwraca 0 lub 1 (gdy warunki są spełnione).
CREATE OR REPLACE FUNCTION A10.VALIDATE_STRING(input_string VARCHAR(100), a1 INTEGER)
RETURNS INTEGER
BEGIN
    IF LENGTH(input_string) > a1 AND REGEXP_LIKE(input_string, '[A-Z]') THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END@

SELECT A10.VALIDATE_STRING('HelloWorld', 5) AS RESULT FROM SYSIBM.SYSDUMMY1@
SELECT A10.VALIDATE_STRING('helloworld', 5) AS RESULT FROM SYSIBM.SYSDUMMY1@
SELECT A10.VALIDATE_STRING('hello', 5) AS RESULT FROM SYSIBM.SYSDUMMY1@

-- 4. Zdefiniować funkcję, która zwraca z daty podanej jako parametr wejściowy dzień tygodnia w języku polskim.
CREATE OR REPLACE FUNCTION A10.DAY_IN_POLISH(input_date DATE)
RETURNS VARCHAR(20)
BEGIN
    DECLARE day_name VARCHAR(20);

    CASE DAYOFWEEK(input_date)
        WHEN 1 THEN SET day_name = 'Niedziela';
        WHEN 2 THEN SET day_name = 'Poniedziałek';
        WHEN 3 THEN SET day_name = 'Wtorek';
        WHEN 4 THEN SET day_name = 'Środa';
        WHEN 5 THEN SET day_name = 'Czwartek';
        WHEN 6 THEN SET day_name = 'Piątek';
        WHEN 7 THEN SET day_name = 'Sobota';
    END CASE;

    RETURN day_name;
END@

SELECT A10.DAY_IN_POLISH(DATE('2025-01-01')) AS RESULT FROM SYSIBM.SYSDUMMY1@

-- 5. Napisać procedurę, która zwróci liczbę zatrudnionych w danym departamencie na danym stanowisku pracy
CREATE OR REPLACE PROCEDURE A10.GET_EMP_COUNT_BY_DEPT_AND_JOB(
    IN deptname VARCHAR(50),
    IN jobname VARCHAR(50),
    OUT emp_count INTEGER
)
BEGIN
    SELECT COUNT(*)
    INTO emp_count
    FROM A10.EMPLOYEES
    WHERE WORKDEPT = deptname
    AND JOB = jobname;
END@

-- 6. Napisać procedurę, która skasuje wszystkie widoki ze schematu np. A10
CREATE OR REPLACE PROCEDURE A10.DROP_ALL_VIEWS()
BEGIN
    FOR view_row AS
        SELECT TABNAME 
        FROM SYSCAT.TABLES 
        WHERE TABSCHEMA = 'A10' AND TYPE = 'V'
    DO
        EXECUTE IMMEDIATE 'DROP VIEW A10.' || view_row.TABNAME;
    END FOR;
END@

-- 7. Zdefiniować procedurę, która zwróci liczbę zatrudnionych wszystkich pracowników.
CREATE OR REPLACE PROCEDURE A10.GET_TOTAL_EMP_COUNT(OUT total_count INTEGER)
BEGIN
    SELECT COUNT(*) INTO total_count FROM A10.EMPLOYEES;
END@

-- 8. Zdefiniować procedurę, która zwróci liczbę departamentów bez pracowników.
CREATE OR REPLACE PROCEDURE A10.GET_DEPT_WITH_NO_EMP(OUT dept_count INTEGER)
BEGIN
    SELECT COUNT(*) 
    INTO dept_count
    FROM A10.DEPARTMENT_COPY D
    WHERE NOT EXISTS (
        SELECT 1 
        FROM A10.EMPLOYEES E 
        WHERE E.WORKDEPT = D.DEPTNO
    );
END@

-- 9. Zdefiniować procedurę, która zwróci liczbę zatrudnionych w danym departamencie podanym jako pierwszy parametr typu IN. 
-- Parametr drugi typu OUT zwróci liczbę zatrudnionych.
CREATE OR REPLACE PROCEDURE A10.GET_EMP_COUNT_IN_DEPT(
    IN workdept VARCHAR(50),
    OUT emp_count INTEGER
)
BEGIN
    SELECT COUNT(*) 
    INTO emp_count
    FROM A10.EMPLOYEES
    WHERE WORKDEPT = workdept;
END@