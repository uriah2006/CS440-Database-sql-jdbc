
/*
uriah sypolt
cs 440
assignment 4

Use the script holler.sql (ecampus) to create a set of tables for “Silicon Holler”. Create a script to
answer the following queries. Spool your queries and the output to a file, print and submit the results.
*/

--1. Find the names of all companies who are collaborators with a company that has a ceo named
--Gabriel.

Select name 
	from collaborators 
	inner join company on company.id = collaborators.c1 
	where collaborators.c2 in (select id -- finding company id where there ceo is gabriel
		from company 
		where ceo='Gabriel'
	)
;

--2. For each company that supplies to a company two or more levels of complexity lower than their
--own, list the name and fields of both the supplier and the purchaser.

select  a.name , a.field , b.name , b.field
	from company a
	join COMPLEXITY	ad   on a.field   = ad.field
	join SUPPLIERS supp  on a.id      = supp.SUPPLIER
	join company b       on b.id      = supp.PURCHASER
	join COMPLEXITY	bx   on b.field   = bx.field
	where ad.rank-2 >= bx.rank
;

--3. For each pair of companies that collaborate, list the names of both companies and both of their
--respective fields. List each pair only once with the pair alphabetical by name. Also the list
--should be alphabetized by the first name and then by the second.

select com1.name, com1.field, com2.name, com2.field
	from company com1 
	join collaborators col on com1.id = col.c1
	join company com2 on com2.id = col.c2
	where com1.name < com2.name                      -- making sure the smaller number is on the left thus del the duplcates
	order by com1.name, com2.name
;


--4. Find all companies who do not appear in the Suppliers table (as a company who supplies or
--purchases) and return their names and fields. Sort by field, then by name within each field.

select field , name 
	from company 
	where id not in (select SUPPLIER from SUPPLIERS)
	and id not in (select PURCHASER from SUPPLIERS)
	order by field , name
;


--5. For every situation where company A supplies company B, but we have no information about
--whom B supplies (that is, B does not appear as an Supplier in the Supplies table), return A and
--B's names and fields.

select compa.name, compb.name, compa.field, compb.field
	from company compa
	join suppliers sup on compa.id = sup.supplier
	join company compb on compb.id = sup.purchaser
	where compb.id not in (select supplier         -- finding id's in suppliers that are not the same as compb
		from suppliers
	)
;
	
--6. Find names and fields of companies who only collaborate with companies in the same field.
--Return the result sorted by field, then by name within each field.

select name, field 
	from company
	minus(select a.name, a.field
		from company a
		join COLLABORATORS ac on a.id = ac.c1
		join company b on b.id = ac.c2
		where a.field != b.field
	)
;

--7. For each company A who supplies a company B where the two do not collaborate, find if they
--have a collaborator C in common (who can introduce them!). For all such trios, return the name
--of A, B, and C.

with temp as (select * 
	from company 
	join collaborators on id = c1)
select a.name, b.name, comp.name
	from suppliers
	join temp a on supplier = a.id
	join temp b on purchaser = b.id
	join company comp on comp.id = a.c2 and comp.id = b.c2
	where (a.id, b.id) not in (select * from collaborators)
;

	
--8. Find the difference between the number of companies in the holler and the number of different
--ceo names.

select count(id) - count(distinct ceo)            --counting all the compaines and subtrating unique ceo's
	from company
;          

--9. Find the name and field of all companies who are buy from more than one supplier.

select name, field 
	from company
	where company.id in(select purchaser 
		from suppliers
		group by purchaser
		having (count(purchaser) > 1)
	)
;

--10. Find the name and field of the company(s) with the most collaborators.

select name, field
	from company
	where id in(select c1 
		from (select c1, count(c1)
			from collaborators
			group by c1
			having count (c1) in (select max (count( c1))
				from collaborators
				group by c1
			)
		)
	)
;