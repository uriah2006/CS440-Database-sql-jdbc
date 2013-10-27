 /*
 uriah sypolt
 cs440
 assignment 7
 march 15 2013
 */
 
 drop trigger to_bonus;
 drop trigger sal_cap;
 drop trigger heavy_item;
 drop trigger 
 
/* 1. We wish that commissions provided to employees (by updates or insertions into the emp table) 
are also entered into the bonus table.  The employee information is	added to Bonus, unless it 
already is present, at which time only the commission 	column is updated.  However, the company 
has a peculiar rule that commissions 	granted outside of working hours (8AM to 5PM) are NOT 
reflected in the Bonus 	table.  Write a trigger to implement this policy.
 */	
create or replace trigger to_bonus
	after insert or update of comm
	on emp
	for each row
	begin
	if to_number(to_char(sysdate, 'HH24')) between 8 and 17 then
		if (inserting) then
			insert into bonus values(:new.ENAME, :new.JOB, :new.SAL, :new.COMM);
		else--updating
			update bonus
			set comm = :new.comm
            where ename = :new.ename;
        end if;
	end if;
end to_bonus; -- to_bonus
/

/* 	
2. In an effort to reduce long-term debt, our company has decided to cap salary increases. Any 
salary increase over the cap is to be regarded as a commission and hence the company does not incur 
additional long-term salary commitment.

	The salary caps are based on job classification; the caps are:

		Analyst			$4,000	
		Clerk			$1,500
		Manager			$3,500
		Salesman		$2,000

	There is no cap for the president.
done
	The first business rule to be instituted is that any salary modification that exceeds 	the cap,
	the difference between the new salary and the cap is to be regarded as a 	commission and added
	to the current commission.
****
	A second business rule that will be instituted will prevent the circumvention of 	the salary 
	cap. Employees may not change jobs and thereby obtain a new position 	with a higher salary than
	allowed at their previous position (we’re a tough 	company!)  This only applies when the 
	employee's new job is different than their 	old job AND their new salary exceeds  what they could
	have made at their old 	job.
doneish
	Write a single trigger that will accomplish these two business rules. One method 	for creating 
	user-defined errors is to call the procedure raise_application_error 	with parameters: error_number
	and message where error numbers in the range 	from –20000 to –20999 are reserved for user defined 
	errors. For example:

		raise_application_error(-20101, 'Salary is missing'); 

	If an attempt to change jobs is encountered, cause the error with error number 
	–20100 to occur with error message ‘Job modification not permitted.’  (NOTE:  	RAISING AN EXCEPTION
	AND HANDLING AN EXCEPTION ARE 	NOT 	THE SAME.  YOUR TRIGGER SHOULD RAISE AN EXCEPTION 	ONLY.)
 */
create or replace trigger sal_cap
before insert or update of sal
on emp
for each row
	begin
	if not(:new.job = :old.job) then
	  RAISE_APPLICATION_ERROR(-20100, 'Job modification not permitted.');
	end if;
	
	if(initcap(:new.job) = 'Analyst' and :new.sal > 4000) and (initcap(:new.job) = 'Analyst' and :new.sal < 4000)then
		:new.comm := :old.comm + (:new.sal - 4000);
		:new.sal := 4000;
	elsif(initcap(:new.job) = 'Clerk' and :new.sal > 1500) and (initcap(:new.job) = 'Clerk' and :new.sal < 1500)then
		:new.comm := :old.comm + (:new.sal - 1500);
		:new.sal := 1500;
	elsif(initcap(:new.job) = 'Manager' and :new.sal > 3500) and (initcap(:new.job) = 'Manager' and :new.sal < 3500) then
		:new.comm := :old.comm + (:new.sal - 3500);
		:new.sal := 3500;
	elsif(initcap(:new.job) = 'Salesman' and :new.sal > 2000) and (initcap(:new.job) = 'Salesman' and :new.sal < 2000) then
		:new.comm := :old.comm + (:new.sal - 2000);
		:new.sal := 2000;
    end if;
end sal_cap;
/
 
 
/* 3.	Write a before row trigger on the p table that implements the business rule 	that if a part's
 weight in an insert or update exceeds 	10 units, the color of the part 	must be RED to flag it as a 
 "heavy" item.  This should only be applied to changes 	and additions: this does NOT apply to parts and
 weights currently in the database.
 */
create or replace trigger heavy_item
before insert or update of weight
on p
for each row
begin
if(:new.weight > 10) then
        :new.color := 'RED';
	end if;
end heavy_item;
/
 
 
 
 
/* 4.	Write an after row trigger on the p table that implements the business rule that if a 	part's
 weight in an insert or update is less than 8 units, the color of the part must 	be BLUE to flag it
 as a "light" item. This should only be applied to changes 	and additions: this does NOT apply to parts 
 and weights currently in the database.
 */
 
 CREATE OR REPLACE TRIGGER num4
  FOR insert or update of weight
  ON p
  COMPOUND TRIGGER
  type ass_name is table of p%rowtype index by binary_integer
  p_ass_name ass_name
  c number:=0
  after each row 
  is
  begin
   c:= c+1;
	if (:new.weight< 8) then
	 p_ass_name(c).color = 'BLUE';
	 p_ass_name(c).p# := :new.p#;
  end after each row;
  after	statement is
  begin
	for d in p_ass_name.first .. p_ass_name.last 
	loop
	update p set color := p_ass_name(d).color where p.p#=p_ass_name(d).p#
	end loop;
 end after statement;
END num4;
/

/* Submit a listing of your trigger source code. Also, make sure your emp, bonus, s, p and sp tables
 have the original set of data.  Recognize that I will likely test your triggers in your databases.
 */
