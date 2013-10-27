spool HW8out.txt
set echo on
set serveroutput on format wrapped size 1000000
set line 140

 /*
 uriah sypolt
 cs440
 assignment 8
 4/5/2013
 */
--1. Create a PLSQL function called Likers that, receiving a CRN as a parameter, will return a varying array of the student names of all 
--students that like the student represented by the parameter.  Note that you will be responsible for creating an appropriate varying 
--array for this purpose.  If no one likes the student, the function should return null.

create or replace type return_array as varying array(100) of varchar2(30);
/

create or replace function Likers(p_crn Likes.CRN2%type)
return return_array as

v_likes return_array := return_array();

begin

	for rec in (select name from wvu where crn in (select crn1 from likes where crn2 = p_crn)) loop
		v_likes.extend;
		v_likes(v_likes.count) := rec.name;
	end loop;
	if (v_likes.count = 0) then
		return null;
	else
		return v_likes;
	end if;
end likers;
/
show errors


--2. Create a PLSQL procedure called Hermitify received a CRN as a parameter and removes all Friend/Likes references to that individual.
create or replace procedure Hermitify (p_crn friend.crn1%type)
as
begin
delete from Friend where crn1 = p_crn or crn2 = p_crn;
delete from Likes where crn1 = p_crn or crn2 = p_crn;
end;
/
show errors


--3. Create a trigger so that new students like all students in their grade.
create or replace trigger like_all                       
for insert on wvu
compound trigger

 v_likes return_array := return_array();

after each row is
begin
	v_likes.extend;
	v_likes(v_likes.count) := :new.name;
end after each row;

after statement is
v_crn number;
begin
for i in 1..v_likes.count loop
    select crn into v_crn from wvu where name = v_likes(i);
    for f_crn in (select crn from wvu where grade = (select grade from wvu where crn = v_crn)) loop
    	insert into likes values (v_crn, f_crn.crn);
    end loop;
end loop;
end after statement;
end like_all;
/
show errors


--4. Create a trigger so that new students who either have a null grade or no grade specified are automatically listed as Freshmen.

create or replace trigger no_grade
before update of grade
on wvu
for each row

when(new.grade is null)

begin
	:new.grade := 'FR';
end no_grade;
/
show errors

--5. Create a trigger so that symmetry is maintained in the Friend table (so if A is a friend of B, B must also be a friend of A).

create or replace trigger bal_friend
after update on friend
begin
	insert into friend select crn1, crn2 from friend where (crn2, crn1) not in
	(select crn1, crn2 from friend);
end bal_friend;
/
show errors

--6. Create a trigger so that if a student is advanced one year (say from Freshman to Sophomore) then so are all of his friends.
create package school_year as
	can_recur number := 1 ;
end;
/

create or replace trigger new_school_year
after update on wvu
compound trigger
	vlik vliker :=vliker();
after each row is 
begin
	if school_year.can_recur =1 then
		vlik.extend;
		vlik(vlike.count) := :old.name;
	end if;
end after each ro;
after statement is 
begin
	if school_year.can_recur =1 then
		school_year.can_recur :=1;
		for i in 1..lik.count loop
			for x in (select crn2 from freind where crn1 = (select crn from wvu where name = vlik(1)))) loop
				update wvu set grade = (select abbrev from year where position =(select position + 1 from year))
			end loop;
		end loop;
		vlik.delete;
		school_year.can_recur := 1
	end if
	exception
		when others then 
			school_year.can_recur := 1;
			raise;
	end after statement;
	end trigger6;
	
/
show errors

--7. Create a trigger so that if a student is advanced to graduate student, the student is automatically deleted from the database.

create or replace trigger get_out
after insert or update of grade on wvu
begin
	delete from likes where cn1 in (select crn from wvu where grade = 'GR') or crn2 in (select crn from wvu where grade = 'GR');
	delete from friend where cn1 in (select crn from wvu where grade = 'GR') or crn2 in (select crn from wvu where grade = 'GR');
	delete from wvu where grade ='GR';
end;
/
show errors

--8. Write a trigger to enforce the following behavior: If A liked B but is updated to A liking C instead, and B and C were friends, make
--B and C no longer friends.
create or replace trigger triangle
before update on crn2 of likes
for each row
begin
	if : new.crn = :old.crn1 then
		delete from friend where (crn1 = :old.crn2 and crn2 = :new.crn2) or (crn2 = :old.crn2 and crn1 = :new .crn2);
end triangle;
/
show errors

spool off