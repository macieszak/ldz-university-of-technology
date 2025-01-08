CREATE TABLE A10.DEPARTMENTS LIKE DEPARTMENT@
INSERT INTO A10.DEPARTMENTS SELECT * FROM DEPARTMENT@

CREATE TABLE A10.EMPLOYEES LIKE EMPLOYEE@
INSERT INTO A10.EMPLOYEES SELECT * FROM EMPLOYEE@

--1. Definiujemy przykładowy widok na dwóch tabelach (np. tabela EMPLOYEE i DEPTARTMENT). 
-- Czy możemy za pomocą tego widoku dodać nowy rekord do tabeli Department lub Employee? Jak to zrealizować?
CREATE VIEW A10.EMP_DEPT_VIEW AS
SELECT E.EMPNO, E.LASTNAME, E.SALARY, D.DEPTNO, D.DEPTNAME
FROM A10.EMPLOYEES E
JOIN A10.DEPARTMENTS D ON E.WORKDEPT = D.DEPTNO@

CREATE TRIGGER A10.INSERT_EMP_DEPT
INSTEAD OF INSERT ON A10.EMP_DEPT_VIEW
REFERENCING NEW AS NEWROW
FOR EACH ROW
BEGIN
    -- Wstawiamy dane do DEPARTMENTS
    INSERT INTO A10.DEPARTMENTS (DEPTNO, DEPTNAME)
    VALUES (NEWROW.DEPTNO, NEWROW.DEPTNAME);
    
    -- Wstawiamy dane do EMPLOYEES
    INSERT INTO A10.EMPLOYEES (EMPNO, LASTNAME, SALARY, WORKDEPT)
    VALUES (NEWROW.EMPNO, NEWROW.LASTNAME, NEWROW.SALARY, NEWROW.DEPTNO);
END@

--2. Definiujemy przykładowe dwa widoki na bazie SAMPLE na pojedynczej tabeli obrazujące przykład wykorzystania WITH LOCAL CHECK OPTION oraz WITH CASCADED CHECK OPTION.
-- i sprawdzamy jakie dane można dodać za pomocą widoku view1 i view2.
-- np. CREATE TABLE tab1 (c1 INTEGER, c2 CHAR(5));
--     CREATE VIEW view1 AS SELECT c1, c2 FROM tab1 WHERE c1 < 100 WITH LOCAL CHECK OPTION;
--     CREATE VIEW view2 AS SELECT c1, c2 FROM view1 WITH CASCADED CHECK OPTION;
CREATE TABLE tab1 (c1 INTEGER, c2 CHAR(5))@
CREATE VIEW A10.view1 AS SELECT c1, c2 FROM tab1 WHERE c1 < 100 WITH LOCAL CHECK OPTION@
CREATE VIEW A10.view2 AS SELECT c1, c2 FROM view1 WITH CASCADED CHECK OPTION@

-- Testowanie:
-- To zadziała w VIEW1
INSERT INTO A10.VIEW1 VALUES (50, 'TEST')@

-- To nie zadziała w VIEW1 (c1 >= 100)
INSERT INTO A10.VIEW1 VALUES (150, 'TEST')@

-- To zadziała w VIEW2
INSERT INTO A10.VIEW2 VALUES (50, 'TEST')@

-- To nie zadziała w VIEW2 (sprawdza warunki wszystkich bazowych widoków)
INSERT INTO A10.VIEW2 VALUES (150, 'TEST')@

--3. Tworzymy alias do tabeli DEPTARTMENT w schemacie DB2ADMIN o nazwie DEPT1. Podać przykład wykorzystania aliasu.
CREATE ALIAS A10.DEPT1 FOR DB2ADMIN.DEPARTMENT@

select * from department@

-- Przykłady użycia aliasu:
-- Wybieranie danych
SELECT * FROM A10.DEPT1@

-- Wstawianie danych przez alias
INSERT INTO A10.DEPT1 VALUES ('X11', 'NEW DEPT', null, 'A00', null)@

-- Łączenie z inną tabelą przez alias
SELECT E.LASTNAME, D.DEPTNAME
FROM A10.EMPLOYEES E
JOIN A10.DEPT1 D ON E.WORKDEPT = D.DEPTNO@

--4. Definiujemy własny typ danych użytkownika GRADES do przechowywania ocen. Tworzymy tabelę z polem typu GRADES 
--   (np. CREATE TABLE STUDENT(ID INT IDENTITY PRIMARY KEY, NAME CHAR(20), GRADE GRADES NULL); 
--   Na podstawie kolumny ze zmienną OCENA definiujemy ograniczenie CHECK, aby oceny były 
--   tylko konkretne (np. 2.0, 3.0, 3.5, 4.0, 4.5, 5.0). 
--   Dalej wyszukujemy osoby z oceną 5.0. 
--   ! Tabelę, ograniczenie, typ danych użytkownika definiujemy w schemacie DB2ADMIN. 
CREATE TYPE DB2ADMIN.GRADES AS DECIMAL(2,1)@

CREATE TABLE DB2ADMIN.STUDENT (
    ID INT NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    NAME CHAR(20),
    GRADE DB2ADMIN.GRADES
)@

ALTER TABLE DB2ADMIN.STUDENT 
ADD CONSTRAINT CHK_GRADE 
CHECK (GRADE IN (CAST(2.0 AS DB2ADMIN.GRADES), 
                 CAST(3.0 AS DB2ADMIN.GRADES), 
                 CAST(3.5 AS DB2ADMIN.GRADES), 
                 CAST(4.0 AS DB2ADMIN.GRADES), 
                 CAST(4.5 AS DB2ADMIN.GRADES), 
                 CAST(5.0 AS DB2ADMIN.GRADES)))@

-- Test danych
INSERT INTO DB2ADMIN.STUDENT (NAME, GRADE) VALUES
('Jan Kowalski', 5.0),
('Anna Nowak', 4.5),
('Piotr Wiśniewski', 5.0)@

-- Wyszukiwanie osób z oceną 5.0
SELECT * FROM DB2ADMIN.STUDENT 
WHERE GRADE = CAST(5.0 AS DB2ADMIN.GRADES)@


-- 5. Definiujemy dwa własne typy danych użytkownika z walutą obcą np. Euro i Dollar. 
-- Wstaw przykładowe dane i wykonaj zapytanie porównujące wartości z kolumny Euro i Dollar.
CREATE TYPE DB2ADMIN.EURO AS DECIMAL(10,2)@
CREATE TYPE DB2ADMIN.DOLLAR AS DECIMAL(10,2)@

CREATE TABLE DB2ADMIN.PRICES (
    ID INT NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    PRODUCT_NAME VARCHAR(50),
    PRICE_EUR DB2ADMIN.EURO,
    PRICE_USD DB2ADMIN.DOLLAR
)@

-- Przykładowe dane
INSERT INTO DB2ADMIN.PRICES (PRODUCT_NAME, PRICE_EUR, PRICE_USD) VALUES
('Product A', CAST(100.00 AS DB2ADMIN.EURO), CAST(110.00 AS DB2ADMIN.DOLLAR)),
('Product B', CAST(200.00 AS DB2ADMIN.EURO), CAST(220.00 AS DB2ADMIN.DOLLAR))@

-- Porównanie walut
SELECT PRODUCT_NAME, 
      PRICE_EUR AS "Cena w EUR", 
      PRICE_USD AS "Cena w USD",
      (CAST(PRICE_USD AS DECIMAL(10,2)) - CAST(PRICE_EUR AS DECIMAL(10,2))) AS "Różnica USD-EUR"
FROM DB2ADMIN.PRICES@

-- 6. Wykorzystujemy polecenia systemowe EXPORT TO ... oraz IMPORT FROM ... do zapisania danych w pliku na dysku, 
--    a następnie wstawienia danych 
--    do przykładowej tabeli Tab1 o strukturze jak tabela DEPARTMENT (np. pobieramy dane z tabeli DEPARTMENT do pliku). 
--    Możemy wykorzystać Data Studio do utworzenia podanych poleceń.
-- Tworzenie tabeli Tab1 z tą samą strukturą co DEPARTMENT
CREATE TABLE Tab1 AS (
    SELECT * FROM DEPARTMENT
) DEFINITION ONLY@

-- w oknie db2 admin:
-- db2 "EXPORT TO 'C:\Users\db2admin\Desktop\ZSPI\department_data.ixf' OF ixf MESSAGES 'C:\Users\db2admin\Desktop\ZSPI\export_log.txt' SELECT * FROM DEPARTMENT"

--7. Wykorzystaj mechanizm wersjonowania danych w tabeli za pomocą temporal table (System Period Management). 
--   Utwórz tabelę o nazwie EmployeeTemporal w schemacie A10, która będzie przechowywać dane o pracownikach 
--   (może być podobna jak tabela Employee).
--   Skonfiguruj tabelę jako temporal table, aby system automatycznie przechowywał historię zmian w danych.
--   Dodaj, zmodyfikuj i usuń kilka rekordów w tabeli, aby wygenerować dane historyczne (czekamy 2-3 sekundy między operacjami).
--   Napisz zapytanie, które zwróci:
--  - Wszystkie wersje rekordu dla konkretnego produktu.
--  - Dane z tabeli historycznej dla wybranego zakresu czasu.
--      - Aktualne dane.  
CREATE TABLE A10.EMPLOYEETEMPORAL (
    EMPLOYEEID INTEGER GENERATED BY DEFAULT AS IDENTITY,
    FIRSTNAME VARCHAR(50),
    LASTNAME VARCHAR(50),
    SALARY DECIMAL(10,2),
    DEPARTMENT VARCHAR(50),
    SYS_START TIMESTAMP(12) NOT NULL GENERATED ALWAYS AS ROW BEGIN,
    SYS_END TIMESTAMP(12) NOT NULL GENERATED ALWAYS AS ROW END,
    TRANS_ID TIMESTAMP(12) GENERATED ALWAYS AS TRANSACTION START ID,
    PERIOD FOR SYSTEM_TIME (SYS_START, SYS_END), 
    PRIMARY KEY (EMPLOYEEID)
)@

-- Tworzymy tabelę historyczną
CREATE TABLE A10.EMPLOYEETEMPORALHISTORY LIKE A10.EMPLOYEETEMPORAL@

-- Dodajemy wersjonowanie do tabeli
ALTER TABLE A10.EMPLOYEETEMPORAL
    ADD VERSIONING USE HISTORY TABLE 
    A10.EMPLOYEETEMPORALHISTORY@

-- Wstawienie początkowych danych
INSERT INTO A10.EMPLOYEETEMPORAL 
    (FIRSTNAME, LASTNAME, SALARY, DEPARTMENT)
VALUES 
    ('Jan', 'Kowalski', 5000.00, 'IT'),
    ('Anna', 'Nowak', 6000.00, 'HR')@

VALUES SLEEP(2)@

-- Modyfikacje danych
UPDATE A10.EMPLOYEETEMPORAL 
SET SALARY = 5500.00
WHERE FIRSTNAME = 'Jan'@

VALUES SLEEP(2)@

UPDATE A10.EMPLOYEETEMPORAL
SET DEPARTMENT = 'Development'
WHERE FIRSTNAME = 'Jan'@

VALUES SLEEP(2)@

-- Usunięcie pracownika
DELETE FROM A10.EMPLOYEETEMPORAL
WHERE FIRSTNAME = 'Anna'@

-- Zapytanie 1: Historia zmian dla konkretnego pracownika
SELECT FIRSTNAME, LASTNAME, SALARY, DEPARTMENT, 
       SYS_START, SYS_END
FROM A10.EMPLOYEETEMPORAL 
    FOR SYSTEM_TIME AS OF CURRENT TIMESTAMP
WHERE FIRSTNAME = 'Jan'@

-- Zapytanie 2: Dane historyczne z konkretnego momentu
SELECT FIRSTNAME, LASTNAME, SALARY, DEPARTMENT,
       SYS_START, SYS_END
FROM A10.EMPLOYEETEMPORAL 
    FOR SYSTEM_TIME AS OF CURRENT TIMESTAMP - 5 MINUTES@

-- Zapytanie 3: Aktualne dane
SELECT FIRSTNAME, LASTNAME, SALARY, DEPARTMENT,
       SYS_START, SYS_END
FROM A10.EMPLOYEETEMPORAL@