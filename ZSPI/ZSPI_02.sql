--26. Podaj nazwę działu, numer działu, średnie zarobki w dziale oraz ilu pracowników w dziale pracuje.
SELECT d.DEPTNAME, d.DEPTNO, AVG(e.SALARY) AS AVG_SALARY, COUNT(1) AS EMP_NUMBER
FROM DEPARTMENT d
         LEFT JOIN EMPLOYEE e ON d.DEPTNO = e.WORKDEPT
GROUP BY d.DEPTNAME, d.DEPTNO;

--27. Podaj nazwy działów, dla których pierwsza litera to A drugi znak to % trzeci znak to +
SELECT DEPTNAME
FROM DEPARTMENT
WHERE SUBSTR(DEPTNAME, 1, 1) = 'A'
  AND SUBSTR(DEPTNAME, 2, 1) = '%'
  AND SUBSTR(DEPTNAME, 3, 1) = '+';

--28. Wyświetlić miesięcznie pensję pracownika zaokrąglonych do liczby całkowitej.
SELECT FIRSTNME, LASTNAME, INT(SALARY/12) AS MONTH_SALARY
FROM EMPLOYEE;
--LUB
SELECT FIRSTNME, LASTNAME, ROUND(SALARY/12) AS MONTH_SALARY
FROM EMPLOYEE;

--29. Podaj nazwisko pracownika oraz 3 pierwsze litery nazwiska pracownika (funkcja CAST)
SELECT LASTNAME, CAST(SUBSTR(LASTNAME, 1, 3) AS CHAR(3)) AS FIRST_3_LETTERS
FROM EMPLOYEE;
--LUB
SELECT LASTNAME, SUBSTR(LASTNAME, 1, 3) AS FIRST_3_LETTERS
FROM EMPLOYEE;

--30. Podaj nazwisko pracownika, który pracuje na stanowisku MANAGER i jest kobietą (Operator porównania par zbiorów w IN)
SELECT LASTNAME
FROM EMPLOYEE
WHERE JOB IN ('MANAGER') AND SEX IN ('F');
--LUB
SELECT LASTNAME
FROM EMPLOYEE
WHERE JOB = 'MANAGER' AND SEX = 'F';

--31. Podaj nazwę projektu i ilu pracowników realizuje dany projekt.
SELECT p.PROJNAME, COUNT(e.EMPNO)
FROM PROJECT p
         JOIN EMPPROJACT e ON p.PROJNO = e.PROJNO
GROUP BY p.PROJNAME;

--32. Podaj nazwę projektu i jego szefów.
SELECT p.PROJNAME, e.FIRSTNME, e.LASTNAME
FROM PROJECT p
         JOIN EMPLOYEE e ON p.RESPEMP = e.EMPNO;

--33. Podaj najlepiej zarabiające osoby na każdym ze stanowisk pracy.
select e.job, e.firstnme, e.lastname, e.salary
from employee e
where e.salary = (
    select max(salary)
    from employee
    where job = e.job
)
order by e.job;

--34. W jakim departamencie jakie są realizowane projekty.
select d.deptno, d.deptname, p.projno, p.projname
from department d
         join project p
              on d.deptno = p.deptno
order by d.deptname;

--35. Podaj czas realizacji projektów.
select
    projno,
    projname,
    prstdate as start_date,
    prendate as end_date,
    ((YEAR(prendate) - YEAR(prstdate)) * 12) + (MONTH(prendate) - MONTH(prstdate)) AS proj_duration_in_month
from project;

--36. Podaj projekt i podprojekty realizowane w każdym z nich.
select * from project;
select major.projno as main_project_id, major.projname as main_poject_name, subpr.projno as subproject_id, subpr.projname as subproject_name
from project major
         left join project subpr
                   on major.projno = subpr.majproj
order by major.projno;

--37. Znaleźć pracownika zarabiającego najwięcej na każdym stanowisku pracy.
select e.job, e.firstnme, e.lastname, e.salary
from employee e
where e.salary = (
    select max(salary)
    from employee
    where job = e.job
)
order by e.job;

--38. Znaleźć pracownika zarabiającego najwięcej na każdym stanowisku pracy w każdym departamencie.
select * from department;
select * from employee;

select d.deptno as department_id, d.deptname as department_name, e.job as job, e.firstnme, e.lastname, e.salary
from department d
         join employee e
              on d.deptno = e.workdept
where e.salary = (
    select max(salary)
    from employee
    where job = e.job and workdept = e.workdept
)
ORDER BY d.deptname;

--39. Znaleźć po trzech pracowników zarabiających najwięcej na każdym stanowisku pracy.
SELECT ranked_employees.job,
       ranked_employees.firstnme,
       ranked_employees.lastname,
       ranked_employees.salary
FROM (
         SELECT e.job,
                e.firstnme,
                e.lastname,
                e.salary,
                ROW_NUMBER() OVER (PARTITION BY e.job ORDER BY e.salary DESC) AS rank
         FROM employee e
     ) AS ranked_employees
WHERE ranked_employees.rank <= 3
ORDER BY ranked_employees.job, ranked_employees.rank;

--40. Mamy zapytanie: select * from (values ('A'),('Ć'),('ć'),('Ź'),('a')) temp1 (col1); posortuj względem alfabetu polskiego
SELECT col1
FROM (VALUES ('A'),('Ć'),('ć'),('Ź'),('a')) AS temp1 (col1)
ORDER BY col1;

--41. Znaleźć osoby, które zarabiają mniej niż wynosi średnia w ich zawodach
select e.job, e.firstnme, e.lastname, e.salary
from employee e
where e.salary < (
    select avg(salary)
    from employee
    where job = e.job
)
order by e.job;

--42. Znaleźć departament, w którym nikt nie pracuje (wykorzystaj EXISTS, JOIN i klauzulę IN).
select d.deptno, d.deptname
from department d
where not exists (
    select 1
    from employee e
    where d.deptno = e.workdept
);

select d.deptno, d.deptname
from department d
where d.deptno not in (
    select e.workdept
    from employee e
    where e.workdept = d.deptno
);

--43. Zamień ciąg znaków na format daty np. '04-29-2020' (do wykorzystania podczas wstawia danych do pola typu Date)
INSERT INTO PROJECT (PROJNO, PROJNAME, DEPTNO, RESPEMP, PRSTAFF, PRSTDATE, PRENDATE, MAJPROJ)
VALUES ('P10001', 'Test Project', 'D01', '000020', 5.00, DATE('2024-01-01'), DATE('2024-12-31'), NULL);

--44. Ile pełnych miesięcy upłynęło w okresie od pierwszej zatrudnionej osoby do ostatniej zatrudnionej osoby – podaj w pełnych miesiącach?
SELECT FLOOR(
               (YEAR(MAX(HIREDATE)) - YEAR(MIN(HIREDATE))) * 12 +
               (MONTH(MAX(HIREDATE)) - MONTH(MIN(HIREDATE)))
       ) AS full_months
FROM EMPLOYEE;

SELECT FLOOR(
               (YEAR(MAX(HIREDATE)) - YEAR(MIN(HIREDATE))) * 12 +
               (MONTH(MAX(HIREDATE)) - MONTH(MIN(HIREDATE)))
       )
FROM EMPLOYEE;

--45. Jaka jest data ostatniego dnia danego miesiąca?
SELECT LAST_DAY(DATE('2024-12-12')) AS LAST_DAY_OF_MONTH
FROM SYSIBM.SYSDUMMY1;

--46. Ile dni ma luty w 2024 roku?
SELECT DAY(LAST_DAY(DATE('2024-02-01'))) AS DAYS_IN_FEBRUARY
FROM SYSIBM.SYSDUMMY1;

--47. W jakim dniu tygodnia jest Sylwester tego roku (dzień tygodnia ma być w języku polskim)
SELECT DAYNAME(DATE('2024-12-31')) AS DZIEŃ_TYGODNIA
FROM SYSIBM.SYSDUMMY1;

--48. Dodaj 3 miesiące do bieżącej daty.
SELECT CURRENT DATE AS CURRENT_DATE, ADD_MONTHS(CURRENT DATE, 3) AS NEW_DATE
FROM SYSIBM.SYSDUMMY1;

--49. Do aktualnej daty dodaj 3 dni i odejmij 1 godzinę.
SELECT CURRENT_TIMESTAMP + 3 DAYS - 1 HOUR AS NEW_DATE
FROM SYSIBM.SYSDUMMY1;

--50. Znaleźć, ile pracowników zostało zatrudnionych, w każdym roku i miesiącu, w którym funkcjonowała firma (wykorzystać operator ROLLUP i CUBE i za pomocą operatorów zbiorów UNION ALL, UNION, INTERSECT, MINUS zobaczyć czym różnią się dane wyniki zapytań).
--ROLLUP
SELECT YEAR(HIREDATE) AS HIRE_YEAR,
       MONTH(HIREDATE) AS HIRE_MONTH,
       COUNT(*) AS EMPLOYEE_COUNT
FROM EMPLOYEE
GROUP BY ROLLUP(YEAR(HIREDATE), MONTH(HIREDATE));

--CUBE
SELECT YEAR(HIREDATE) AS HIRE_YEAR,
       MONTH(HIREDATE) AS HIRE_MONTH,
       COUNT(*) AS EMPLOYEE_COUNT
FROM EMPLOYEE
GROUP BY CUBE(YEAR(HIREDATE), MONTH(HIREDATE));

--UNION ALL
SELECT YEAR(HIREDATE) AS HIRE_YEAR,
       MONTH(HIREDATE) AS HIRE_MONTH,
       COUNT(*) AS EMPLOYEE_COUNT
FROM EMPLOYEE
GROUP BY ROLLUP(YEAR(HIREDATE), MONTH(HIREDATE))
UNION ALL
SELECT YEAR(HIREDATE) AS HIRE_YEAR,
       MONTH(HIREDATE) AS HIRE_MONTH,
       COUNT(*) AS EMPLOYEE_COUNT
FROM EMPLOYEE
GROUP BY CUBE(YEAR(HIREDATE), MONTH(HIREDATE));

--UNION
SELECT YEAR(HIREDATE) AS HIRE_YEAR,
       MONTH(HIREDATE) AS HIRE_MONTH,
       COUNT(*) AS EMPLOYEE_COUNT
FROM EMPLOYEE
GROUP BY ROLLUP(YEAR(HIREDATE), MONTH(HIREDATE))
UNION
SELECT YEAR(HIREDATE) AS HIRE_YEAR,
       MONTH(HIREDATE) AS HIRE_MONTH,
       COUNT(*) AS EMPLOYEE_COUNT
FROM EMPLOYEE
GROUP BY CUBE(YEAR(HIREDATE), MONTH(HIREDATE));

--INTERSECT
SELECT YEAR(HIREDATE) AS HIRE_YEAR,
       MONTH(HIREDATE) AS HIRE_MONTH,
       COUNT(*) AS EMPLOYEE_COUNT
FROM EMPLOYEE
GROUP BY ROLLUP(YEAR(HIREDATE), MONTH(HIREDATE))
INTERSECT
SELECT YEAR(HIREDATE) AS HIRE_YEAR,
       MONTH(HIREDATE) AS HIRE_MONTH,
       COUNT(*) AS EMPLOYEE_COUNT
FROM EMPLOYEE
GROUP BY CUBE(YEAR(HIREDATE), MONTH(HIREDATE));

--MINUS
SELECT YEAR(HIREDATE) AS HIRE_YEAR,
       MONTH(HIREDATE) AS HIRE_MONTH,
       COUNT(*) AS EMPLOYEE_COUNT
FROM EMPLOYEE
GROUP BY CUBE(YEAR(HIREDATE), MONTH(HIREDATE))
    MINUS
SELECT YEAR(HIREDATE) AS HIRE_YEAR,
       MONTH(HIREDATE) AS HIRE_MONTH,
       COUNT(*) AS EMPLOYEE_COUNT
FROM EMPLOYEE
GROUP BY ROLLUP(YEAR(HIREDATE), MONTH(HIREDATE));

--51. Wykorzystaj składnię CASE to określenia jak wysoką mamy pensję przykładowo:
--salary < 10000 to mamy wyświetlany napis 'Niska pensja'
--salary between 10000 and 20000 to mamy wyświetlany napis 'Średnia pensja'
--salary >20000 to mamy wyświetlany napis 'Wysoka pensja'
--w innym przypadku mamy wyświetlany napis 'brak wartości'
SELECT salary,
       CASE
           WHEN salary < 10000 THEN 'Niska pensja'
           WHEN salary BETWEEN 10000 AND 20000 THEN 'Średnia pensja'
           WHEN salary > 20000 THEN 'Wysoka pensja'
           ELSE 'Brak wartości'
           END AS salary_category
FROM employee;

--52. Mamy zapytanie: select * from (values ('Gdańsk'),('Zgierz'),('Kraków'),('Łódź')) temp1 (col1)
select *
from (values ('Gdańsk'),('Zgierz'),('Kraków'),('Łódź')) temp1 (col1);

select col1, length(col1)
FROM (VALUES ('Gdańsk'), ('Zgierz'), ('Kraków'), ('Łódź')) temp1 (col1);

--Znaleźć nazwy, które mają długość 6 znaków.
--Wybrać i wyświetlić tylko 3 znaki z danej kolumny.
SELECT LEFT(col1, 3) AS first_three_chars
FROM (VALUES ('Gdańsk'), ('Zgierz'), ('Kraków'), ('Łódź')) temp1 (col1)
WHERE LENGTH(col1) = 6; -- wyswietli tylko Zgi, ponieważ, Gdańsk, Kraków zawierają polskie znaki które nie są liczone jako 1

--53. Zaprezentuj średnie pensje pracowników względem ich grup zaszeregowania (kolumna EDLEVEL), podając dodatkowo na końcu (łączne jako podsumowanie) średnią dla wszystkich pracowników (klauzula ROLLUP)
SELECT edlevel,
       AVG(salary) AS avg_salary
FROM employee
GROUP BY edlevel
WITH ROLLUP
ORDER BY edlevel;

--54. Zaprezentuj średnie pensje pracowników względem ich grup zaszeregowania (kolumna EDLEVEL) oraz dla danych stanowisk pracy (JOB), podając dodatkowo na końcu łączne podsumowania (tzn. średnie na każdym poziomie grup zaszeregowania - klauzula ROLLUP)
SELECT edlevel, job, AVG(salary) AS avg_salary
FROM employee
GROUP BY ROLLUP(edlevel, job)
ORDER BY edlevel, job;