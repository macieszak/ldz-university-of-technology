SET CURRENT SCHEMA A10;
VALUES CURRENT SCHEMA;
SELECT SCHEMANAME FROM SYSCAT.SCHEMATA WHERE DEFINER = 'DB2ADMIN';

select * from A10.Voivodeships;
select * from A10.Cities;
select * from A10.Customers;

DROP TABLE A10.Voivodeships;
DROP TABLE A10.Customers;
DROP TABLE A10.Cities;

--1. Tabela Voivodeships (za≥oŅenia)
--------------------------------------------------------------------------------
--VoivodeshipID 	INT NOT NULL autonumercja -- Primary Key
--Name 		VARCHAR(30) NOT NULL 
--Active 		BIT(0,1) NOT NULL Default 1 (nie ma typu bit)

CREATE TABLE A10.Voivodeships (
    VoivodeshipID INT NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Name VARCHAR(30) NOT NULL,
    Active CHAR(1) NOT NULL DEFAULT '1',
    CONSTRAINT chk_active CHECK (Active IN ('0', '1'))
);

--2. Tabela Cities (za≥oŅenia)
--------------------------------------------------------------------------------
--CityID 		INT NOT NULL autonumercja -- PK
--Name 		VARCHAR(30) NOT NULL
--VoivodeshipID 	INT Foreign Key (FK - tabela Voivodeships kolumna VoivodeshipID z opcjĻ ON DELETE CASCADE)
CREATE TABLE A10.Cities (
    CityID INT NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Name VARCHAR(30) NOT NULL,
    VoivodeshipID INT NOT NULL,
    CONSTRAINT fk_voivodeship FOREIGN KEY (VoivodeshipID) 
        REFERENCES A10.Voivodeships (VoivodeshipID) 
        ON DELETE CASCADE
);

--3. tabela Customers (za≥oŅenia)
--------------------------------------------------------------------------------
--CustomerID 	INT  NOT NULL  autonumeracja-- PK
--LastName 	VARCHAR(25) NOT NULL 
--FirstName 	VARCHAR(20) NOT NULL 
--PESEL 		CHAR(11) UNIQUE (ile rekordůw moŅna do≥oŅyś z wart. NULL i czy wogůle czy NULL jest dopuszczalna)
--BirthDate 	DATE (lub DATETIME) NULL 
--HireDate 	DATE (lub DATETIME) DEFAULT bieŅĻca_data
--Salary 		MONEY default 0 + CHECK Salary >= 0) NOT NULL (typ MONEY nie istnieje w DB2)
--StreetAddress 	VARCHAR( ) NULL
--StreetNumber 	VARCHAR( ) NULL
--FlatNumber 	VARCHAR( ) NULL
--CityID 		INT Foreign Key (FK - tabela Cities kolumna CityID z opcjĻ ON DELETE SET NULL)
--CHECK BirthDate < HireDate
CREATE TABLE A10.Customers (
    CustomerID INT NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    LastName VARCHAR(25) NOT NULL,
    FirstName VARCHAR(20) NOT NULL,
    PESEL CHAR(11) NOT NULL UNIQUE,
    BirthDate DATE,
    HireDate DATE DEFAULT CURRENT_DATE,
    Salary DECIMAL(15, 2) DEFAULT 0 CHECK (Salary >= 0) NOT NULL,
    StreetAddress VARCHAR(255),
    StreetNumber VARCHAR(50),
    FlatNumber VARCHAR(50),
    CityID INT,
    CONSTRAINT fk_city FOREIGN KEY (CityID) REFERENCES A10.Cities (CityID) ON DELETE SET NULL,
    CHECK (BirthDate < HireDate)
);

--4. Wstawiś po 5-10 poprawnych rekordůw do tabel.
INSERT INTO A10.Voivodeships (Name, Active) VALUES
('Mazowieckie', '1'),
('ĆlĻskie', '1'),
('Wielkopolskie', '1'),
('Pomorskie', '1'),
('Ma≥opolskie', '1');

INSERT INTO A10.Cities (Name, VoivodeshipID) VALUES
('Warszawa', 1),
('Krakůw', 5),
('Wroc≥aw', 3),
('GdaŮsk', 4),
('Katowice', 2),
('PoznaŮ', 3),
('£ůdü', 1),
('Szczecin', 4),
('Lublin', 1),
('Bielsko-Bia≥a', 2);

INSERT INTO A10.Customers (LastName, FirstName, PESEL, BirthDate, HireDate, Salary, StreetAddress, StreetNumber, FlatNumber, CityID) VALUES
('Nowak', 'Jan', '12345678901', '1985-05-15', '2020-01-01', 3500.00, 'ul. Kwiatowa 5', '10', '1', 1),
('Kowalski', 'Anna', '23456789012', '1990-07-22', '2021-02-20', 4200.00, 'ul. S≥oneczna 10', '15', '3', 2),
('Wiúniewski', 'Marek', '34567890123', '1982-03-10', '2018-11-11', 3000.00, 'ul. Wiosenna 7', '8', '4', 3),
('Jankowski', 'Ewa', '45678901234', '1975-08-25', '2015-05-30', 5500.00, 'ul. Leúna 3', '12', '5', 4),
('ZieliŮski', 'Krzysztof', '56789012345', '1995-12-30', '2022-05-15', 4200.00, 'ul. Stawowa 9', '20', '2', 5),
('Wůjcik', 'Katarzyna', '67890123456', '1988-11-11', '2019-04-10', 3700.00, 'ul. PiÍciomorgowa 6', '9', '2', 6),
('SzymaŮski', 'Adam', '78901234567', '2000-02-25', '2022-06-01', 4100.00, 'ul. Cicha 4', '18', '3', 7),
('DĻbrowski', 'Piotr', '89012345678', '1980-09-30', '2017-03-25', 4700.00, 'ul. Zimowa 2', '16', '6', 8),
('Kaczmarek', 'Agnieszka', '90123456789', '1992-01-14', '2020-09-01', 4600.00, 'ul. Gůrska 8', '13', '7', 9),
('Kubiak', 'Patryk', '01234567890', '1984-06-05', '2016-12-18', 5000.00, 'ul. Ćwierkowa 1', '5', '8', 10);

--5. Do≥oŅyś do tabeli Voivodeships pole Country VARCHAR(50) NULL
ALTER TABLE A10.Voivodeships 
ADD COLUMN Country VARCHAR(50) NULL;

--6. Dodaś rekordy wype≥niś danymi w kolumnie Country (powyŅej 10 znakůw)
UPDATE A10.Voivodeships
SET Country = 'Polska'
WHERE VoivodeshipID = 1;

UPDATE A10.Voivodeships
SET Country = 'Polska'
WHERE VoivodeshipID = 2;

UPDATE A10.Voivodeships
SET Country = 'Polska'
WHERE VoivodeshipID = 3;

UPDATE A10.Voivodeships
SET Country = 'Polska'
WHERE VoivodeshipID = 4;

UPDATE A10.Voivodeships
SET Country = 'Polska'
WHERE VoivodeshipID = 5;

--7. Zmienić NULL na NOT NULL w kolumnie Country
ALTER TABLE A10.Voivodeships
ALTER COLUMN Country SET NOT NULL;

--8. Zmieniś typ danych Country na VARCHAR(5) -- istniejĻce dane nie spe≥niajĻ tej liczby znakůw
UPDATE A10.Voivodeships
SET Country = 'PL'
WHERE Active = '1';

ALTER TABLE A10.Voivodeships
ALTER COLUMN Country SET DATA TYPE VARCHAR(5);

--9. Zmieniś typ danych Country na VARCHAR(35)
ALTER TABLE A10.Voivodeships
ALTER COLUMN Country SET DATA TYPE VARCHAR(35);

--10. Zmieniś nazwÍ kolumny Active na ActiveVoivodeship

--nie dzia≥a, b≥Ļd: Wykonanie instrukcji nie powiod≥o siÍ, poniewaŅ co najmniej jeden obiekt jest zaleŅny od obiektu docelowego.  
--Typ obiektu docelowego: "COLUMN". Nazwa obiektu, ktůry jest zaleŅny od obiektu docelowego: "CHK_ACTIVE". 
--Typ obiektu, ktůry jest zaleŅny od obiektu docelowego: "CHECK CONSTRAINT".. SQLCODE=-478, SQLSTATE=42893, DRIVER=3.72.44
ALTER TABLE A10.Voivodeships
RENAME COLUMN Active TO ActiveVoivodeship;

--naleŅy:
--usunĻś ograniczenie CHECK
ALTER TABLE A10.Voivodeships
DROP CONSTRAINT CHK_ACTIVE;
--zmieniś nazwÍ
ALTER TABLE A10.Voivodeships
RENAME COLUMN Active TO ActiveVoivodeship;
--ponownie dodaś ograniczenie
ALTER TABLE A10.Voivodeships
ADD CONSTRAINT CHK_ACTIVE CHECK (ActiveVoivodeship IN ('0', '1'));

--11. Zdefiniowaś dowolny widok o nazwie View1 na trzech tabelach Customers, Cities, Voivodeships i wykonaś 
--przyk≥adowe zapytanie wykorzystujĻc dany widok
CREATE VIEW A10.View1 AS
SELECT c.CustomerID, c.LastName, c.FirstName, v.Name AS Voivodeship, ci.Name AS City
FROM A10.Customers c
JOIN A10.Cities ci ON c.CityID = ci.CityID
JOIN A10.Voivodeships v ON ci.VoivodeshipID = v.VoivodeshipID;

SELECT * FROM A10.View1;

--12. Sprawdziś jaki jest efekt skasowania z tabeli Voivodeships jednego z rekordůw 
--(sprawdzamy jeúli wystÍpuje sytuacja gdzie istniejĻ powiĻzane rekordy w tabeli Cities i dalej to samo w tabeli Customers)
DELETE FROM A10.Voivodeships WHERE VoivodeshipID = 1;

SELECT * FROM A10.Cities WHERE VoivodeshipID = 1;
SELECT * FROM A10.Customers WHERE CityID IS NULL;

--13. Zdefiniowaś kolumnÍ Age w tabeli Customers, ktůra bÍdzie automatycznie wype≥niania o aktualny wiek danego klienta.
ALTER TABLE A10.Customers
ADD COLUMN Age INT;

UPDATE A10.Customers
SET Age = FLOOR(DAYS(CURRENT_DATE) / 365.25) - FLOOR(DAYS(BirthDate) / 365.25);

--14. Kasujemy wszystkie obiekty ze schematu A10 oraz sam schemat A10.
DROP TABLE A10.Customers;
DROP TABLE A10.Cities;
DROP TABLE A10.Voivodeships;
DROP VIEW A10.VIEW1;
DROP SCHEMA A10 RESTRICT;
