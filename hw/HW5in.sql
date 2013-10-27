/*
	uriah  sypolt
	CS 440
	Assignment 5
	February 15, 2013
*/

set echo on

--1.	a)  List part names of all parts supplied by suppliers s1, s2, or s4.

select pname 
	from p 
	where p# in(select p# 
		from sp
		where s# = 's1'
		or
		s# = 's2'
		or
		s# = 's4'
);

--  	b)  List part names of all parts supplied by all three (s1, s2, and s4).

select pname 
	from p 
	where p# in ('s1','s2','s4')
	group by pname
	having count(*)=3
;


--2.	List supplier names of suppliers who do not supply every red part.
select sname
	from s s1
	where sname not in (select distinct sname 
		from p
		join sp on sp.p#=p.p#
		join s on sp.s#=s.s#
		where color = 'red'
		)
	)
;

--3.	List supplier names of suppliers who don’t supply part p5 but who do supply part p4.
select sname 
from s 
where s# in
(select s# from sp where p# = 'p4'
minus
select s# from sp where p# = 'p5');

--4.	List supplier names of suppliers who supply the second highest quantity (for a single part).
-- testing 

select  sname from s natral join sp 
	where qty > (select max (qty from sp where qty !=(select max (qty)from sp)));

--5.	List supplier names of suppliers who do supply at least 2 distinct parts but do not supply part p3.

select sname 
	from s 
	where s# in(select s# 
		from (select distinct s#, count(s#) 
			over (partition by s#) as cnt 
			from (select s# 
				from sp 
				where p# != 'p3'
			)
		)
	where cnt > 1);

--6.	For suppliers that supply at least 3 parts, list the supplier name and the top 3 (by qty) parts name, 
--in order of highest to lowest quantity (so each row will have the name of a supplier and three parts). 

with x as (select sname, pname, rank() over (partition by s# order by qty desc) rank 
from s
join sp using (s#)
join p using (p#)
order by s#, qty desc)
select j.sname, a.pname,b.pname,c.pname 
from (select sname from s natural join sp group by sname having count (*)>=3) j
join x a on a. sname = j.sname and x.rank = 1
join x b on b. sname = j.sname and x.rank = 2
join x c on c. sname = j.sname and x.rank = 3
;

--7.	List supplier names with minimum quantity supplied if that supplier supplies at least one part whose 
--qty exceeds the maximum quantity of part p2.

select name ,min(qty)
	from s
	join sp using (s#)
	where s# in (select s# 
		from s 
		where qty > (select max(qty) 
			from sp 
			where p#='p2'
		)
	)
group by sname;
	
--8. List the names of all suppliers, the names of parts they supply, the quantity supplied, the max quantity 
--that the supplier supplies of any part and the maximum  quantity of that part supplied by any supplier.

select sname, pname, qty, max(qty)
	over(partition by s#) part_over_s#, max(qty)
	over(partition by p#) part_over_p#
	from s
	join sp using(s#) 
	join p using(p#);

--9. List the names of all supervisors of the employee Adams and the supervisors’ level above Adams.  Do not
-- list any analyst if one should be a supervisor of Adams.

select ename, level - 1 'level'
	from emp 
	where ename != 'ADAMS' and job != 'ANALYST'
	start  with  ename + ' ADAMS'
	connect by prior mgr = empno;


--10. List the company management hierarchy with employee name, supervisor name, employee’s level below the 
--president; do not print any employee who is a clerk. Indent each subsequent employee 3 spaces as the list 
--moves down the company hierarchy.
select lpad (' ',3*(level-1))||ename as name, (select ename from emp where empno = x.mgr) as "manager", level -1 as "level"
	from emp x 
	where job != 'CLERK'
	start with mgr is null 
	connect by prior empno = mgr;
	col name format a20
 
 
 
 
 
 
 
 
 
 
 
 
 

