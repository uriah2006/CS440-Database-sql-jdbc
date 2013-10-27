spool HW9out.txt
/*
uriah sypolt
cs440
hw9 
*/
echo on
-- Whatsamatta University has heavily modified their schema, and their database 
-- is open for yourinspection under user wu.  Tables in the schema include 
-- DEPARTMENTS, CLASSES,ANDSTUDENTS.
-- Using the tables in the wu schema, create a script to create the following 
-- structure in your database:

-- 1. Create an object, classes_ty that contains attributes CRN varchar2(5), 
-- Department varchar2(8), and CourseTitle varchar2(25).
--drop type classes_ty;

create or replace type classes_ty as object
 (
  CRN  varchar2(5),
  department varchar2(8),
  courseTitle varchar2(25)
 );
/
--2. Create an object table, classes_ot with a single attribute of type 
--classes_ty.  Define appropriate constraints for this table.


create table classes_ot of classes_ty;
/

alter table classes_ot
  add constraint crn_pk primary key (CRN)
  deferrable initially immediate;
/

--3. Populate classes_ot, using sql or pl/sql, with all the information in the
--wu.classes table.
insert into classes_ot
  select * from wu.classes; 
/
--4. Create a nested table type classes_ref_ty which contains REFS to the 
--classes_ot table.

create type classes_ref_ty as table 
  of ref classes_ty;
/
--5. Create a table student_plus, along with appropriate constraints, that 
--contains the following attributes: student# varchar2(11), student_name 
--varchar2(10), major varchar2(8), advisor varchar2(10), and enrolled 
--classes_ref_ty.


create table student_plus
(
  Student#      varchar2(11),
  Student_name  varchar2(10),
  Major         varchar2(8),
  Advisor       varchar2(10),
  enrolled      classes_ref_ty)
  nested table enrolled store as classes_ty_ref_table;
/ 
  
--nested table enrolled store as classes_ref_ty_tab;


--6. Populate student_plus, using sql or pl/sql, directly from (and only from) 
--the wu.students and classes_ot tables.
begin                       --
 insert into student_plus 
  select student_id, name, dept, advisor,classes_ref_ty() from wu.students;
 for id in(select student_id from wu.students) loop
  insert into table(
    select enrolled 
      from student_plus 
      where student# = id.student_id) 
    select ref(ot) 
      from classes_ot ot 
      where crn 
    in (select c.column_value 
      from wu.students ot, table(ot.classes) c 
      where id.student_id = ot.student_id);
 end loop; 
end;
/
  

--Since you did such a great job with this conversion, you are asked to 
--administer the new database.  Using ONLY Tables Student_Plus and Classes_OT, 
--perform the following operations with SQL and/or PL/SQL:

--7. List the names of all students who are enrolled in classes with CRN 45673
--or CRN 34228.

select distinct student_name from student_plus,table (enrolled)
  where deref(column_value).CRN in (45673,34228);
/

--8. List the course titles of all courses in which student Sherman is enrolled.

select deref(column_value).courseTitle from student_plus ,table (enrolled)
  where student_name = 'Sherman';
/  
--9. List the names of students who are advised by VanScoy.

select student_name from student_plus 
where advisor = 'VanScoy';
/
--10. List the number of students who are enrolled in Linear Algebra.

select  count(student#) from student_plus, table (enrolled)
where deref(column_value).COURSETITLE = 'LINEAR ALGEBRA';
/
--11. Modify student Adams major to PHYSICS.

update student_plus set MAJOR = 'PHYSICS'
where STUDENT_NAME='Adams';
/
--12. Write a procedure, AddClass, that is passed a student number and a CRN.
--The procedure adds the class to the student's classes.

create or replace procedure AddClass(
  STUD in varchar2,
  CRN_me in number
)
is
begin
  insert into table (select enrolled from student_plus where student# = STUD )select ref(me) from classes_ot me 
  where crn = CRN_me;
end;
/
--13. Use procedure AddClass to add CRN 31245 to Hood's list of classes.

declare
stud_num varchar2(11);
begin
select STUDENT# into stud_num from STUDENT_PLUS where STUDENT_NAME = 'Hood';
  addclass(stud_num,31245);
end;
/
--14. List the CRNs for Hood's classes.

select deref(column_value).CRN from student_plus ,table (enrolled)
  where student_name = 'Hood';
/  
--15. Write a procedure, DeleteClass, that is passed a student number and a CRN.
--The procedure deletes the specified class from the student's list of classes.
--If the student is not enrolled in that class, raise the error code 20200 and 
--the message 'Student not enrolled in that class'.
--16. Remove CRN 34129 from Sherman's list of classes. not going to happen
--17. List the CRNs for Sherman's classes.

select deref(column_value).CRN from student_plus ,table (enrolled)
  where student_name = 'Sherman';
/  
--18. List the names of students who are not enrolled in any classes.

select STUDENT_NAME from (
  select count(deref(column_value).CRN) as num , STUDENT_NAME from  student_plus,table (enrolled)) 
  where num = 0;
/  
--Set server output & echo on, and run your script to do all 18 steps. Spool 
--your output to a file, and submit a printed copy of the output file.
spool off