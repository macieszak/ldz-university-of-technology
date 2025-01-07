SET CURRENT SCHEMA A10@
VALUES CURRENT SCHEMA@
SELECT SCHEMANAME FROM SYSCAT.SCHEMATA WHERE DEFINER = 'DB2ADMIN'@

create table A10.PERSONS (IB  int not null primary key, NAME varchar(20), SALARY decimal(16,2))@

-- 1. Zdefiniować autonumerację (z wykorzystaniem wyzwalacza) 
-- pola ID na podstawie sekwencji zewnętrznej wcześniej utworzonej o nazwie SEQ1 (wyzwalacz Before/Insert)
CREATE SEQUENCE A10.SEQ1
START WITH 1
INCREMENT BY 1
NO CYCLE@ 

CREATE TRIGGER A10.BI_PERSONS_ID
BEFORE INSERT ON A10.PERSONS
REFERENCING NEW AS NEWROW
FOR EACH ROW
BEGIN
    SET NEWROW.IB = NEXT VALUE FOR A10.SEQ1;
END@

--dane testowe
INSERT INTO A10.PERSONS (NAME, SALARY) VALUES ('John Doe', 5000)@
INSERT INTO A10.PERSONS (NAME, SALARY) VALUES ('Kevin Eod', 5000)@
SELECT * FROM A10.PERSONS@

-- 2. Zdefiniować wyzwalacz gdzie w polu NAME zamieni wszystkie znaki na duże litery  (wyzwalacz)
CREATE TRIGGER A10.PERSONS_NAME_UPPER
BEFORE INSERT ON A10.PERSONS
REFERENCING NEW AS NEWROW
FOR EACH ROW
BEGIN
	SET NEWROW.NAME = UPPER(NEWROW.NAME);
END@

INSERT INTO A10.PERSONS (NAME, SALARY) VALUES ('Oscar Doe', 5000)@
SELECT * FROM A10.PERSONS@

-- 3. Zdefiniować wyzwalacz, który po skasowaniu lub zmodyfikowaniu rekordu z tabeli A10.PERSONS przekopiuje dane do tabeli 
--A10.PERSONS_HIST (tabelę należy wcześniej utworzyć) oraz dodatkowymi kolumnami, w tym nazwa użytkownika, data wykonania, 
--czas wykonania oraz typ operacji (słownie np. delete, update).
CREATE TABLE A10.PERSONS_HIST (
   IB INT,
   NAME VARCHAR(20),
   SALARY DECIMAL(16,2),
   USERNAME VARCHAR(128),
   OPERATION_DATE DATE,
   OPERATION_TIME TIME,
   OPERATION_TYPE VARCHAR(6)
)@

CREATE TRIGGER A10.AUDIT_PERSONS
AFTER DELETE OR UPDATE ON A10.PERSONS
REFERENCING OLD AS OLDROW
FOR EACH ROW
BEGIN
   INSERT INTO A10.PERSONS_HIST (
       IB, 
       NAME, 
       SALARY,
       USERNAME,
       OPERATION_DATE,
       OPERATION_TIME,
       OPERATION_TYPE
   )
   VALUES (
       OLDROW.IB,
       OLDROW.NAME,
       OLDROW.SALARY,
       CURRENT_USER,
       CURRENT_DATE,
       CURRENT_TIME,
       CASE 
           WHEN DELETING THEN 'DELETE'
           WHEN UPDATING THEN 'UPDATE'
       END
   );
END@

INSERT INTO A10.PERSONS (IB, NAME, SALARY) VALUES 
(1, 'John Smith', 5000.00),
(2, 'Anna Brown', 6000.00),
(3, 'Mike Wilson', 4500.00)@

UPDATE A10.PERSONS 
SET SALARY = 5500.00 
WHERE IB = 1@

DELETE FROM A10.PERSONS 
WHERE IB = 2@

SELECT * FROM A10.PERSONS_HIST@

-- 4. Utworzyć widok A10.PPERSONS_VIEW na tej tabeli A10.PPERSONS.
--    Definujemy wyzwalacz typu INSTEAD OF, który zwróci błąd z informacją 'Za pomocą danego widoku nie można wstawiać danych' 
--    oraz wyzwalacz typu INSTEAD OF, który przy modyfikacji widoku wykonana poprawną operację modyfikacji. 
CREATE VIEW A10.PERSONS_VIEW  AS 
   SELECT * FROM A10.PERSONS@

CREATE TRIGGER A10.INSTEAD_OF_INSERT_VIEW
INSTEAD OF INSERT ON A10.PERSONS_VIEW
REFERENCING NEW AS NEWROW
FOR EACH ROW
BEGIN
   SIGNAL SQLSTATE '70001' 
   SET MESSAGE_TEXT = 'Za pomocą danego widoku nie można wstawiać danych';
END@

CREATE TRIGGER A10.INSTEAD_OF_UPDATE_VIEW
INSTEAD OF UPDATE ON A10.PERSONS_VIEW
REFERENCING NEW AS NEWROW OLD AS OLDROW
FOR EACH ROW
BEGIN
   UPDATE A10.PERSONS
   SET IB = NEWROW.IB,
       NAME = NEWROW.NAME,
       SALARY = NEWROW.SALARY
   WHERE IB = OLDROW.IB;
END@

INSERT INTO A10.PERSONS VALUES 
(1, 'John Smith', 5000.00),
(2, 'Anna Brown', 6000.00)@

INSERT INTO A10.PERSONS_VIEW VALUES (3, 'Mike Wilson', 4500.00)@

UPDATE A10.PERSONS_VIEW 
SET SALARY = 5500.00 
WHERE NAME = 'John Doe'@

SELECT * FROM A10.PERSONS_VIEW@
-- 5. Zdefiniować wyzwalacz na tabeli EMPLOYEES (kopiujemy tabele ze schematu DB2ADMIN do schematu A10), 
-- który sprawdzi czy pole HIREDATE jest mniejsze lub równe dacie systemowej +-10 dni przy wstawianiu nowego pracownika lub 
-- jego modyfikacji. Jeśli nie, zwrócony zostanie komunikat o błędzie, a transakcja zostanie wycofana.
CREATE TABLE A10.EMPLOYEES LIKE DB2ADMIN.EMPLOYEE@
INSERT INTO A10.EMPLOYEES SELECT * FROM DB2ADMIN.EMPLOYEE@

SELECT * FROM A10.EMPLOYEES@

CREATE TRIGGER A10.CHECK_HIREDATE
BEFORE INSERT OR UPDATE OF HIREDATE ON A10.EMPLOYEES
REFERENCING NEW AS NEWROW
FOR EACH ROW
WHEN (NEWROW.HIREDATE > CURRENT DATE + 10 DAYS OR 
      NEWROW.HIREDATE < CURRENT DATE - 10 DAYS)
BEGIN
    SIGNAL SQLSTATE '70002'
    SET MESSAGE_TEXT = 'Data zatrudnienia musi być w zakresie +-10 dni od daty bieżącej';
END@

INSERT INTO A10.EMPLOYEES (EMPNO, LASTNAME, HIREDATE)
VALUES (999, 'TEST', '2025-12-31')@

-- 6. Zdefiniować wyzwalacz na tabeli EMPLOYEES (kopiujemy tabele ze schematu DB2ADMIN do 
-- schematu A10 jeśli wcześniej tego nie zrobiliśmy), który reaguje na pensję mniejszą od zera 
-- i wtedy zmienia jej wartość na 0.
CREATE TRIGGER A10.CHECK_NEGATIVE_SALARY
BEFORE INSERT OR UPDATE ON A10.EMPLOYEES
REFERENCING NEW AS NEWROW
FOR EACH ROW
WHEN (NEWROW.SALARY < 0)
BEGIN
    SET NEWROW.SALARY = 0;
END@

-- 7. Zdefiniować wyzwalacz na tabeli EMPLOYEES (kopiujemy tabele ze schematu DB2ADMIN do schematu A10 jeśli wcześniej tego nie zrobiliśmy),
-- który zapewni, że żaden pracownik nie otrzyma podwyżki większej niż 10%. Jeśli wstawiamy nowy rekord to nie sprawdzamy wielkości 
-- podwyzki. Dodatkowo zmiana taka ma być zarejestrowana w bazie danych w tabeli REJESTR_ZMIAN z polami (Nazwisko_pracownika, data, 
-- pensja_stara, pensja_nowa, akcja). Akcja podaje informację słowną ('wstawiono_rekord' lub 'Zmodyfikowano rekord') 
-- w zależności czy pracownik nowy czy już jest w bazie i jest modyfikowana jego pensja (jeden wyzwalacz działa na polecenie 
-- INSERT i UPDATE na polu SALARY). W przypadku głównego szefa 'PRESIDENT' ta zasada nie działa czy wyzwalacz nie uruchamia się 
-- (klauzla WHEN)
CREATE TABLE A10.REJESTR_ZMIAN (
    NAZWISKO_PRACOWNIKA VARCHAR(20),
    DATA DATE,
    PENSJA_STARA DECIMAL(9,2),
    PENSJA_NOWA DECIMAL(9,2),
    AKCJA VARCHAR(20)
)@

CREATE TRIGGER A10.CHECK_SALARY_INCREASE
BEFORE INSERT OR UPDATE OF SALARY ON A10.EMPLOYEES
REFERENCING NEW AS NEWROW OLD AS OLDROW
FOR EACH ROW
WHEN (NEWROW.JOB <> 'PRESIDENT')
BEGIN
    IF UPDATING AND (NEWROW.SALARY > OLDROW.SALARY * 1.1) THEN
        SIGNAL SQLSTATE '70003'
        SET MESSAGE_TEXT = 'Podwyżka nie może przekroczyć 10%';
    END IF;
    
    INSERT INTO A10.REJESTR_ZMIAN VALUES (
        NEWROW.LASTNAME,
        CURRENT DATE,
        CASE WHEN UPDATING THEN OLDROW.SALARY ELSE NULL END,
        NEWROW.SALARY,
        CASE WHEN UPDATING THEN 'Zmodyfikowano rekord' 
             ELSE 'Wstawiono rekord' END
    );
END@

UPDATE A10.EMPLOYEES 
SET SALARY = SALARY * 1.2 
WHERE EMPNO = 000010@

-- 8. Zdefiniuj wyzwalacz na tabeli DEPARTMENTS (kopiujemy tabele ze schematu DB2ADMIN do schematu A10), 
-- który sprawdzi czy dana nazwa departamentu nie powtarza się w bazie danych (nie używamy ograniczenia UNIQUE). 
-- Jeśli tak to zrócony jest błąd a transakcja nie zostanie wykonana.
CREATE TABLE A10.DEPARTMENT_COPY LIKE DB2ADMIN.DEPARTMENT@
INSERT INTO A10.DEPARTMENT_COPY SELECT * FROM DB2ADMIN.DEPARTMENT@

SELECT * FROM A10.DEPARTMENT_COPY@

CREATE OR REPLACE TRIGGER A10.CHECK_UNIQUE_DEPT_NAME
BEFORE INSERT OR UPDATE ON A10.DEPARTMENT_COPY
REFERENCING NEW AS NEWROW
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM A10.DEPARTMENT_COPY WHERE DEPTNAME = NEWROW.DEPTNAME) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nazwa departamentu musi być unikalna!';
    END IF;
END
@

-- 9. Wymaganie biznesowe (zdefiniuj wyzwalacz): Żaden dział (DEPARTMENTS) nie może mieć więcej niż 50 pracowników (EMPLOYEES).
CREATE OR REPLACE TRIGGER A10.CHECK_EMP_COUNT
BEFORE INSERT OR UPDATE ON A10.EMPLOYEES
REFERENCING NEW AS NEWROW
FOR EACH ROW
BEGIN
    DECLARE emp_count INT;
    SET emp_count = (SELECT COUNT(*) FROM A10.EMPLOYEES WHERE WORKDEPT = NEWROW.WORKDEPT);

    IF emp_count >= 50 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dział nie może mieć więcej niż 50 pracowników!';
    END IF;
END
@

-- 10. Wymaganie biznesowe  (zdefiniuj wyzwalacz): Data zatrudnienia pracownika (EMPLOYEES), 
-- nie może być późniejsza niż dzisiaj i wczesniejsza niż miesiąc 30 dni wcześniej.
CREATE OR REPLACE TRIGGER A10.CHECK_HIRE_DATE
BEFORE INSERT OR UPDATE ON A10.EMPLOYEES
REFERENCING NEW AS NEWROW
FOR EACH ROW
BEGIN
    IF NEWROW.HIREDATE > CURRENT DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Data zatrudnienia nie może być w przyszłości!';
    END IF;

    IF NEWROW.HIREDATE < CURRENT DATE - 30 DAYS THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Data zatrudnienia nie może być starsza niż 30 dni!';
    END IF;
END
@

-- 11. Czy można utworzyć dwa wyzwalacze tego samego typu na danej tabeli, gdzie jeden dodaje do pensji 10 jednostek, 
-- a drugi zabiera z pensji 5 jednostek? Podaj przykład.

-- Wyzwalacz zwiększający pensję o 10 jednostek
CREATE OR REPLACE TRIGGER A10.ADD_SALARY
BEFORE INSERT OR UPDATE ON A10.EMPLOYEES
REFERENCING NEW AS NEWROW
FOR EACH ROW
BEGIN
    SET NEWROW.SALARY = NEWROW.SALARY + 10;
END
@

-- Wyzwalacz zmniejszający pensję o 5 jednostek
CREATE OR REPLACE TRIGGER A10.SUBTRACT_SALARY
BEFORE INSERT OR UPDATE ON A10.EMPLOYEES
REFERENCING NEW AS NEWROW
FOR EACH ROW
BEGIN
    SET NEWROW.SALARY = NEWROW.SALARY - 5;
END
@

--12. Czy można utworzyć dwa wyzwalacze na jednym widoku tego samego typu (np. reagujące na polecenie INSERT)? Podaj przykład.

-- w DB2 nie można utworzyć dwóch wyzwalaczy tego samego typu na jednym widoku