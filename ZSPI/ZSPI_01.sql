-- 1. Podaj nazwisko i imiona pracowników zaczynające się na literę od c do s.
SELECT LASTNAME, FIRSTNME
FROM EMPLOYEE
WHERE LASTNAME BETWEEN 'C' AND 'T'
ORDER BY LASTNAME ASC;
--OR
SELECT LASTNAME, FIRSTNME
FROM EMPLOYEE
WHERE LASTNAME >= 'C'
  AND LASTNAME <= 'T'
ORDER BY LASTNAME ASC;

--2. Podaj nazwisko i imiona pracowników zaczynające się na literę od c do s trzecia nie l.
SELECT LASTNAME, FIRSTNME
FROM EMPLOYEE
WHERE LEFT(LASTNAME, 1) BETWEEN 'C' AND 'S'
  AND SUBSTR(LASTNAME, 3, 1) <> 'L'
ORDER BY LASTNAME ASC;

-- 3. Podaj pracowników, których pensja jest > od 30 000 zł.
SELECT FIRSTNME, LASTNAME, SALARY
FROM EMPLOYEE
WHERE SALARY > 30000
ORDER BY SALARY ASC;

--4. Podaj pracowników, których pensja z dodaniem prowizji jest > od 50 000 zł i są kobietami.
SELECT FIRSTNME, LASTNAME, SALARY, COMM, SALARY + COMM AS TOTAL
FROM EMPLOYEE
WHERE SALARY + COMM > 50000
  AND SEX = 'F'
ORDER BY SALARY;

--5. Wyświetl pensję pracownika netto, policzyć 18% podatek i podaj pensję z podatkiem.
SELECT FIRSTNME, LASTNAME, SALARY, SALARY * 0.82 AS NET_SALARY
FROM EMPLOYEE;

--6. Podaj czas z zegara systemowego i datę zegara systemowego.
VALUES (CURRENT DATE, CURRENT TIME);

--7. Podaj, którzy z pracowników są w wieku z przedziału 30 do 50 lat.
SELECT FIRSTNME, LASTNAME, YEAR(CURRENT_DATE) - YEAR(BIRTHDATE) AS AGE
FROM EMPLOYEE
WHERE YEAR(CURRENT_DATE) - YEAR(BIRTHDATE) BETWEEN 30 AND 50
ORDER BY AGE ASC;

--8. Podaj, w jakim dziale pracuje pracownik.
SELECT e.FIRSTNME, e.LASTNAME, d.DEPTNAME
FROM EMPLOYEE e
         JOIN DEPARTMENT d
              ON e.WORKDEPT = d.DEPTNO;

--9. Podaj, w jakim dziale pracuje pracownik i uporządkuj malejąco po dziale i rosnąco po nazwisku.
SELECT e.FIRSTNME, e.LASTNAME, d.DEPTNAME
FROM EMPLOYEE e
         JOIN DEPARTMENT d
              ON e.WORKDEPT = d.DEPTNO
ORDER BY d.DEPTNAME DESC, e.LASTNAME ASC;

--10. Podaj, w jakim dziale pracuje pracownik i uporządkuj malejąco po dziale i rosnąco po nazwisku
-- ograniczając liczbę krotek do działów zaczynających się na literę a lub s.
SELECT e.FIRSTNME, e.LASTNAME, d.DEPTNAME
FROM EMPLOYEE e
         JOIN DEPARTMENT d
              ON e.WORKDEPT = d.DEPTNO
WHERE D.DEPTNAME LIKE 'A%'
   OR D.DEPTNAME LIKE 'S%'
ORDER BY d.DEPTNAME DESC, e.LASTNAME ASC;
--OR
SELECT e.FIRSTNME, e.LASTNAME, d.DEPTNAME
FROM EMPLOYEE e
         JOIN DEPARTMENT d
              ON e.WORKDEPT = d.DEPTNO
WHERE LEFT(d.DEPTNAME, 1) LIKE 'A'
   OR LEFT(d.DEPTNAME, 1) LIKE 'S'
ORDER BY d.DEPTNAME DESC, e.LASTNAME ASC;

--11. Czy jest dział firmy, w którym nikt nie pracuje.
SELECT DEPTNAME
FROM DEPARTMENT d
         LEFT JOIN EMPLOYEE e ON d.DEPTNO = e.WORKDEPT
WHERE e.EMPNO IS NULL;

--11a. Za pomocą EXISTS znaleźć departament, w którym nikt nie pracuje.
SELECT DEPTNAME
FROM DEPARTMENT d
WHERE NOT EXISTS (SELECT 1 FROM EMPLOYEE e WHERE e.WORKDEPT = d.DEPTNO);

--12. Podaj, w jakim dziale, jakiego mamy szefa.
SELECT d.DEPTNAME, e.FIRSTNME AS MANAGER_FIRSTNAME, e.LASTNAME AS MANAGER_LASTNAME
FROM DEPARTMENT d
         JOIN EMPLOYEE e ON d.MGRNO = e.EMPNO;

--12a. Podaj pracowników, którzy nie są szefami w żadnym z działów?
SELECT e.FIRSTNME, e.LASTNAME
FROM EMPLOYEE e
         LEFT JOIN DEPARTMENT D on e.EMPNO = d.MGRNO
WHERE d.DEPTNAME IS NULL;
--OR
SELECT FIRSTNME, LASTNAME
FROM EMPLOYEE E
WHERE E.EMPNO NOT IN (SELECT MGRNO FROM DEPARTMENT WHERE MGRNO IS NOT NULL);

--13. Podaj nazwę departamentu z departamentu nadrzędnego. Wyświetli wszystkie departamenty.
SELECT d1.DEPTNO AS "ID", d1.DEPTNAME AS "DEPARTMENT", d2.ADMRDEPT AS "ADMIN ID", d2.DEPTNAME AS "ADMIN DEPARTMENT"
FROM DEPARTMENT d1
         JOIN DEPARTMENT d2
              ON d1.ADMRDEPT = d2.DEPTNO;
--OR
SELECT D1.DEPTNAME AS DEPARTMENT, D2.DEPTNAME AS ADMIN_DEPARTMENT
FROM DEPARTMENT D1
         LEFT JOIN DEPARTMENT D2 ON D1.ADMRDEPT = D2.DEPTNO;

--13.2 Wyświetl pary pracowników pracujących na tym samym stanowisku.
SELECT E1.FIRSTNME AS EMP1_FIRSTNAME,
       E1.LASTNAME AS EMP1_LASTNAME,
       E2.FIRSTNME AS EMP2_FIRSTNAME,
       E2.LASTNAME AS EMP2_LASTNAME,
       E1.JOB
FROM EMPLOYEE E1
         JOIN EMPLOYEE E2 ON E1.JOB = E2.JOB AND E1.EMPNO < E2.EMPNO;

--14. Wyświetl pracowników i obok podaj, kto jest szefem (szefa danego departamentu)
SELECT e1.FIRSTNME, e1.LASTNAME, e2.FIRSTNME AS "BOSS FIRSTNAME", e2.LASTNAME AS "BOSS LASTNAME", d.DEPTNAME
FROM EMPLOYEE e1
         JOIN DEPARTMENT d ON e1.WORKDEPT = d.DEPTNO
         JOIN EMPLOYEE e2 ON d.MGRNO = e2.EMPNO;

--15. Zliczyć ilu pracowników pracuje w danym dziale.
SELECT d.DEPTNAME, COUNT(e.EMPNO) AS EMP_COUNT
FROM DEPARTMENT d
         JOIN EMPLOYEE e ON d.DEPTNO = e.WORKDEPT
GROUP BY d.DEPTNAME;

--15a. Zliczyć ile jest kobiet pracowników.
SELECT COUNT(*) AS FEMALE_COUNT
FROM EMPLOYEE
WHERE SEX = 'F';

--15b. Podaj, jako jeden zestaw rekordów ile jest kobiet pracowników oraz ile jest mężczyzn pracowników.
SELECT SEX, COUNT(*) AS COUNT
FROM EMPLOYEE
GROUP BY SEX;

--16. Podaj, jaki pracownik ma pensję większą od średniej pensji liczonej ze wszystkich pracowników?
SELECT FIRSTNME, LASTNAME, SALARY
FROM EMPLOYEE
WHERE SALARY > (SELECT AVG(SALARY) FROM EMPLOYEE);

--17. Podaj, jaki pracownik pracuje w departamencie na literę od c do p.
SELECT e.FIRSTNME, e.LASTNAME, d.DEPTNAME
FROM EMPLOYEE e
         JOIN DEPARTMENT d ON e.WORKDEPT = d.DEPTNO
WHERE LEFT(d.DEPTNAME, 1) BETWEEN 'C' AND 'P'
ORDER BY d.DEPTNAME;

--18. Wybrać wszystkich pracowników, którzy zarabiają więcej niż ktokolwiek w departamencie A00.
SELECT e.FIRSTNME, e.LASTNAME, e.SALARY
FROM EMPLOYEE e
         JOIN DEPARTMENT d ON e.WORKDEPT = d.DEPTNO
WHERE e.SALARY > (SELECT MIN(e2.SALARY) FROM EMPLOYEE e2 WHERE e2.WORKDEPT = 'A00');

--19. Wybrać wszystkich pracowników, którzy zarabiają więcej od wszystkich w departamencie A00.
SELECT FIRSTNME, LASTNAME, SALARY
FROM EMPLOYEE
WHERE SALARY > ALL (SELECT SALARY FROM EMPLOYEE WHERE WORKDEPT = 'A00');
--OR
SELECT FIRSTNME, LASTNAME, SALARY
FROM EMPLOYEE
WHERE SALARY > (SELECT MAX(SALARY) FROM EMPLOYEE WHERE WORKDEPT = 'A00');

--20. Wybrać zawody, w których średnia płaca jest większa niż średnia płaca na stanowisku manager.
SELECT JOB, AVG(SALARY) AS AVG_SALARY
FROM EMPLOYEE
GROUP BY JOB
HAVING AVG(SALARY) > (SELECT AVG(SALARY) FROM EMPLOYEE WHERE JOB = 'MANAGER');

--21. Wybrać stanowisko, na którym są najniższe średnie zarobki.
SELECT JOB, AVG(SALARY) AS AVG_SALARY
FROM EMPLOYEE
GROUP BY JOB
ORDER BY AVG(SALARY) ASC
    FETCH FIRST 1 ROW ONLY;

--22. Znaleźć osoby, które zarabiają mniej niż średnia w ich zawodach.
SELECT e.FIRSTNME, e.LASTNAME, e.SALARY
FROM EMPLOYEE e
WHERE e.SALARY < (SELECT AVG(e2.SALARY) FROM EMPLOYEE e2 WHERE e.JOB = e2.JOB);

--23. Podaj, jaka jest suma zarobków w danych działach, w których pracują pracownicy
-- o nazwisku zaczynającym się od litery a do g, dla których to działów suma zarobków jest > 100000.
SELECT d.DEPTNAME, SUM(e.SALARY) AS SUM_SALARY_BY_DEPT
FROM DEPARTMENT d
         JOIN EMPLOYEE e ON d.DEPTNO = e.WORKDEPT
WHERE LEFT(e.LASTNAME, 1) BETWEEN 'A' AND 'G'
GROUP BY d.DEPTNAME
HAVING SUM(e.SALARY) > 100000;

--24. W jakim dziale mamy sumę miesięcznych zarobków > 10000, jednocześnie w którym pracuje więcej niż 2 pracowników?
SELECT d.DEPTNAME, SUM(e.SALARY / 12) AS SUM_SALARY_BY_DEPT, COUNT(e.EMPNO) AS EMP_COUNT
FROM DEPARTMENT d
         JOIN EMPLOYEE e ON d.DEPTNO = e.WORKDEPT
GROUP BY d.DEPTNAME
HAVING SUM(e.SALARY / 12) > 10000
   AND COUNT(e.EMPNO) > 2;

--25. Czy jest taki dział, w którym miesięczna suma zarobków jest > od średniej
-- miesięcznej sumy zarobków ze wszystkich działów??
SELECT e.WORKDEPT AS DEPARTMENT_ID, SUM(e.SALARY) / 12 AS MONTHLY_SALARY_SUM
FROM EMPLOYEE e
GROUP BY e.WORKDEPT
HAVING (SUM(e.SALARY) / 12) > (SELECT AVG(DEPT_SALARY)
                               FROM (SELECT WORKDEPT, SUM(SALARY) / 12 AS DEPT_SALARY
                                     FROM EMPLOYEE
                                     GROUP BY WORKDEPT));

--25a. Jak wyżej, ale miesięczna suma zarobków ma być konwertowana (obcinana) do liczby całkowitej.
SELECT D1.WORKDEPT AS DEPTNO, INT(SUM(D1.SALARY) / 12) AS MONTHLY_SALARY_SUM
FROM EMPLOYEE D1
GROUP BY D1.WORKDEPT
HAVING INT(SUM(D1.SALARY) / 12) > (SELECT AVG(INT(DEPT_SALARY))
                                   FROM (SELECT WORKDEPT, INT(SUM(SALARY) / 12) AS DEPT_SALARY
                                         FROM EMPLOYEE
                                         GROUP BY WORKDEPT) AS DEPT_AVERAGE);

--25b. Jak wyżej, ale miesięczna suma zarobków ma być konwertowana do liczby całkowitej a dział do 3 znaków.
SELECT SUBSTR(D.DEPTNAME, 1, 3) AS SHORT_DEPTNAME,
       INT(SUM(E.SALARY) / 12)  AS MONTHLY_SALARY_SUM
FROM EMPLOYEE E
         JOIN DEPARTMENT D ON E.WORKDEPT = D.DEPTNO
GROUP BY SUBSTR(D.DEPTNAME, 1, 3)
HAVING INT(SUM(E.SALARY) / 12) > (SELECT AVG(INT(DEPT_SALARY))
                                  FROM (SELECT SUBSTR(WORKDEPT, 1, 3) AS DEPTNO, INT(SUM(SALARY) / 12) AS DEPT_SALARY
                                        FROM EMPLOYEE
                                        GROUP BY SUBSTR(WORKDEPT, 1, 3)) AS DEPT_AVERAGE);