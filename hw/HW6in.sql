set echo on
set serveroutput on format wrapped size 1000000
set line 140

 /*
 uriah sypolt
 cs440
 assignment 6
 march 4 2013
 */
create or replace procedure Salary_Report
as  		
		total_avg  number;
		total_sal  number;
	BEGIN
		dbms_output.put_line (lpad (To_CHAR (SYSDATE,'DAY, MONTH DD, YYYY'),
			70+(length(To_CHAR (SYSDATE,'DAY, MONTH DD, YYYY')))/2,
			' '));
		dbms_output.put_line (lpad ('Regal Lager',70+(length('Regal Lager')/2),' '));
		dbms_output.new_line;
		dbms_output.put_line (lpad(('More than a Great Brew - a Palindrome'),
			70+37/2,
			(' ')));
		dbms_output.new_line;
		dbms_output.new_line;
		dbms_output.put_line (lpad (('Departmental Salary Report'),
			(70+26/2),
			(' ')));
		dbms_output.new_line;
		for dname_list in (select dname from dept) loop
			
			dbms_output.put_line (lpad ('DEPARTMENT:' || TO_CHAR (dname_list.dname),
				70+(length('DEPARTMENT:' || TO_CHAR (dname_list.dname)))/2,
				' '));
			
			for ename_sal_list in(select ename, sal, dname from emp join dept using (deptno) where dname = dname_list.dname) loop
				
				dbms_output.put_line (lpad (TO_CHAR (ename_sal_list.ename) || ' : '|| TO_CHAR (ename_sal_list.sal,'$999,999.99'),
					(70+length (TO_CHAR (ename_sal_list.ename) || ' : '|| TO_CHAR (ename_sal_list.sal,'$999,999.99'))/2),
					(' ')));
						
			end loop;
			
			select sum(sal) into total_sal from emp join dept using (deptno) where dname = dname_list.dname;
			select avg(sal) into total_avg from emp join dept using (deptno) where dname = dname_list.dname;
			
			dbms_output.put_line (lpad ('Total '||TO_CHAR(dname_list.dname)||' salary: ' || TO_CHAR(total_sal,'$999,999.99'),
				(70+length ('Total '||TO_CHAR(dname_list.dname)||' salary: ' || TO_CHAR(total_sal,'$999,999.99'))/2),
				(' ')));
			dbms_output.put_line (lpad ('Average '||TO_CHAR(dname_list.dname)||' salary: ' || TO_CHAR(total_avg,'$999,999.99'),
				(70+length ('Average '||TO_CHAR(dname_list.dname)||' salary: ' || TO_CHAR(total_avg,'$999,999.99'))/2),
				(' ')));
			dbms_output.new_line;
			
		end loop;
		select sum(sal) into total_sal from emp;
		select avg(sal) into total_avg from emp;
		
		dbms_output.put_line (lpad ('Total Regal Lager salary: ' || TO_CHAR(total_sal,'$999,999.99'),
			70+length('Total Regal Lager salary:' || TO_CHAR(total_sal,'$999,999.99'))/2,
			' '));
		
		dbms_output.put_line (lpad ('Average Regal Lager salary:' || TO_CHAR(total_avg,'$999,999.99'),
			70+length ('Average Regal Lager salary:' || TO_CHAR(total_avg,'$999,999.99'))/2,
			' '));
		dbms_output.new_line;
		
		dbms_output.put_line (lpad ('End of Report',
			70+length ('End of Report')/2,
			' '));
		
	END;
/
exec Salary_Report;
grant execute on Salary_Report to ramorehead;
grant select on emp to ramorehead;
grant select on dept to ramorehead;