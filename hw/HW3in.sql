/*
	uriah sypolt
	CS 440
	Assignment 2
	January 28, 2013
	
	For this assignment, we shall appeal to the Company database with schemas:

	dept(deptno, dname, loc)
	emp(empno, ename, job, mgr, hiredate, sal, comm, deptno)
	bonus(ename, job, sal, comm)
	salgrade(grade, losal, hisal)

and the supplier parts database with schemas:

	s(s#, sname, status, city)
	p(p#, pname, color, weight, city)
	sp(s#, p#, qty)

	
*/
--1. Modify the record of employee Scott so that Scott now has the same manager as the employee Turner.  Rollback your modifications.
update emp 
	SET mgr=(select mgr from emp where ename='TURNER')
	WHERE ENAME='SCOTT';
ROLLBACK;

-- 2. Create a new department called “PR” and move all employees from Research into this new department.  Rollback your modifications.
INSERT INTO DEPT VALUES (50,'PR','SILENTHILL');
update EMP 
	SET DEPTNO=(select deptno from dept where upper (dname) ='PR' )
	WHERE DEPTNO=(select deptno from dept where upper (dname) ='Research' );
ROLLBACK; 

--3. List all employees who do not have the same manager as Martin.
SELECT ename
	FROM EMP
	WHERE MGR != (select mgr from emp where ename='MARTIN');
	
--4. List all supplier names, and, if the supplier supplies parts,  list names of all parts supplied by that supplier;  display each supplier name at most one time. 

BREAK ON SNAME;
SELECT SNAME,pname
	FROM S
	left JOIN SP USING(S#)
	left JOIN P USING(p#)
	order by sname,pname;
	
--5. List part names of all parts (except staplers)  supplied by suppliers who supply staplers.

SELECT distinct PNAME 
	FROM P
	JOIN SP USING (P#)
	WHERE s# = any (select s# 
					from sp
					join p using (p#)
					where pname='stapler'
					and pname != 'stapler')

--6. List part names of all parts that are not currently supplied in Bonn.
--
SELECT PNAME 
	FROM P
	WHERE city != 'Bonn';

--7. List supplier names of suppliers who supply parts made in three or more different cities.

select pname 
	from p
	minus (select pname 
			from p 
			join sp using (p#) 
			join s using (s#) 
			where upper (s.city)= 'BONN';)
	
				
--8. List each department and, if it has employees, the average salary of the department.
select dname, avg (sal)
	from dept 
	left join emp using (deptno)
	group by dname;

--9. List department names of departments having no employees.
 select dname 
	from dept 
	left join emp using (deptno)
	minus (select dname 
			from dept
			right join emp using (deptno));
			
--10. List department names, the highest paid employee in the department, and his salar
select dname, ename, sal 
	from dept
	join emp on emp.deptno = dept.deptno
	where sal in (select max (sal) 
					from emp
					where deptno= dept.deptno);