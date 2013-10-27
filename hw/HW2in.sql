/*
	uriah sypolt
	CS 440
	Assignment 2
	January 28, 2013
*/

--1 Alter the dept table to have the following deferrable (initially immediate) 	constraints:
--	a.	deptno is the primary key
--	b.	dname is unique and not null
--a
alter table dept add constraint DEPTNO_PRIME primary key (deptno)deferrable initially immediate;

--b
alter table dept add constraint dnameNotNull not null deferrable initially immediate;
alter table dept add constraint dnameUniqueName unique (dname)deferrable initially immediate;

-- 2.	Alter the emp table to have the following deferrable (initially immediate) 	constraints:
--	a.	empno is the primary key
--	b.	ename is unique and not null
--	c.	mgr references the empno attribute in the table emp
--	d.	deptno references the deptno attribute in the table dept
--	e.	the sal attribute value should lie in the interval 500 to 10000
--a
alter table emp add constraint empnoPrime primary key (empno)deferrable initially immediate;

--b
alter table emp add constraint enameNotNull not null deferrable initially immediate;
alter table emp add constraint enameUniqueName unique (ename)deferrable initially immediate;

--c
ALTER TABLE emp modify mgr constraint mgrToEmpno REFERENCES emp(empno)deferrable initially immediate;

--d
ALTER TABLE dept modify deptno constraint deptnoToDeptno REFERENCES dept(deptno)deferrable initially immediate;

--e 
alter table emp modify sal constraint salInt check (sal between 500 and 10000 )deferrable initially immediate;

--3.	Alter the table s to have the following deferrable (initially immediate) 	constraints:
--	a.	s# is the primary key
--	b.	sname is unique and not null
--a
alter table s add constraint sPrime  primary key (s#)deferrable initially immediate;

--b
alter table s add constraint snameNotNull not null deferrable initially immediate;
alter table s add constraint snameUniqueName unique (sname)deferrable initially immediate;

--4.	Alter the table p to have the following deferrable (initially immediate) 	constraints:
--	a.	p# is the primary key
--	b.	pname is unique and not null
--a
alter table p add constraint pPrime primary key (p#)deferrable initially immediate;

--b
alter table p add constraint pnameNotNull check ( pname is not null)deferrable initially immediate;
alter table p add constraint pnameUniqueName unique (pname)deferrable initially immediate;

--5.	Alter the table sp to have the following deferrable (initially immediate) 	constraints:
--	a.	the pair s# and p# is the primary key
--	b.	qty is either null or non-negative
--	c.	s# references the s# attribute of the table s and p# references the p# 			attribute of the	p table.
--a
alter table sp add constraint sAndpPrime primary key (s#,p#)deferrable initially immediate;

--b
alter table sp add constraint qtyNotNeg check( qty is null or qty >= 0 )deferrable initially immediate;

--c

ALTER TABLE sp modify s# constraint s#Tos# REFERENCES s(s#)deferrable initially immediate;
ALTER TABLE sp modify p# constraint p#noToP# REFERENCES p(p#)deferrable initially immediate;

--6 Create an index on the deptno attribute of emp

CREATE INDEX deptEmp ON emp(deptno);

--7 Two hiredate values in the emp table are incorrect; identify the difficulty and 	correct it (hint: they are one year too large). You might want to use the 	add_months function with the prototype:
--		add_months(date, #months)
--	where the #months value can be either positive or negative.
--	Commit your results.

update emp set hiredate = add_months('13-jul-13', -12)where hiredate= '13-jul-13';

--8 List all indexes with table name and index name.
SELECT table_name, index_name FROM user_indexes ;

--9 List all constraints with table name and constraint name
SELECT table_name, constraint_name FROM user_constraints;
