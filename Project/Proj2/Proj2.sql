--Q1:

select uoc,count(*) from subjects where eftsload >0 and uoc/eftsload !=48 and code like 'ECO%' group by uoc;

select count(*), 
    (select count(uoc) from subjects where eftsload >0 and uoc/eftsload !=48 and uoc>6 and code like 'ECO%')
    from subjects
    where  eftsload >0 and uoc/eftsload !=48 and code like 'ECO%';



/* test */
create or replace function q1test(uoc_t integer) returns integer as 
$$ select uoc from subjects where uoc>$1 
$$language sql;

/* test */
create or replace function q1test(pattern text) returns integer as 
$$ 
declare
  pp integer;
begin 
   select count(uoc) into pp from subjects where eftsload >0 and uoc/eftsload !=48 and uoc>6 and code like $1;
   return pp;
end;
$$ language plpgsql;

/* test */
create type TestType as (pp integer);
create or replace function q1test(pattern text) returns setof TestType as 
$$ 
declare 
  r TestType;
begin 
   select count(uoc) as a from subjects where eftsload >0 and uoc/eftsload !=48 and uoc>6 and code like $1;
   r.pp :=a;
   return query;
end;
$$ language plpgsql;


/*bigint */
create type IncorrectRecord as (pattern_number integer, uoc_number integer);
create or replace function q1(pattern text, uoc_threshold integer) returns setof IncorrectRecord as 
$$

begin
    return query
    select count(*), 
    (select count(uoc) from subjects where eftsload >0 and uoc/eftsload !=48 and uoc>$2 and code like $1) 
    from subjects
    where  eftsload >0 and uoc/eftsload !=48 and code like $1;
    
end;
$$language plpgsql;


create or replace function q1(pattern text, uoc_threshold integer) returns setof IncorrectRecord as 
$$
declare
  r IncorrectRecord%rowtype;
begin
    for r in
    select count(*), 
    (select count(uoc) from subjects where eftsload >0 and uoc/eftsload !=48 and uoc>$2 and code like $1) 
    from subjects
    where  eftsload >0 and uoc/eftsload !=48 and code like $1
    loop return next r;
    end loop;
    return;
end;
$$language plpgsql;



--Q2:
create type TranscriptRecord as (
            cid integer,-- course ID
            term char(4),-- semester code (e.g. 98s1)
            code char(8),-- UNSW-style course code (e.g. COMP1021)
            name text, -- corresponding subject name of the course
            uoc integer,-- units of credit the student obtained from
                        --this course (full uoc grant to students
                        --who have passed the course, 0 otherwise)
            mark integer,-- numeric mark achieved
            grade char(2),-- grade code (e.g. FL, UF, PS, CR, DN, HD)
            rank integer,-- the rank of the student in this course
            totalEnrols integer -- the total number of students
                                --enrolled in this course with non-null
                                    --mark
);


--Q2all
CREATE OR REPLACE VIEW q2_all AS 
 SELECT course_enrolments.student,
    course_enrolments.course,
    course_enrolments.mark,
    course_enrolments.grade,
    courses.subject,
    courses.semester
   FROM courses
     LEFT JOIN course_enrolments ON course_enrolments.course = courses.id;
     
 
 
/*code from uygnef*/
create or replace function Q1_uoc( int, int)
returns int
as
$$
declare r int;
declare fenshu int;
declare chenji char(2);

begin
select mark,grade into fenshu,chenji
from course_enrolments
where student = $1 
and course = $2;
if 
--fenshu is  null or
chenji = 'SY' or chenji = 'PC' or chenji = 'PS'
or chenji = 'CR' or chenji = 'DN' or chenji = 'HD' or chenji ='PT' or chenji = 'A' or chenji = 'B'
then 
 select uoc into r
 from subjects,courses
 where courses.id = $2
 and subjects.id = courses.subject;
 return r;
 else
 return 0;
 end if;
 end;
$$
language plpgsql;
----------------------------

------------------------
create or replace function Q1_course_code(integer)
returns char(8)
as $$
	select code 
	from subjects
	where id=$1
$$ language sql;

create or replace function Q1_term(integer)
returns text
as $$
	select right(year||lower(term),4)
	from semesters
	where id = $1
$$ language sql;

create or replace function Q1_id(integer)
returns integer
as $$
	select id
	from people
	where unswid = $1
$$ language sql;
----------------------

--------------------
CREATE OR REPLACE VIEW q1_all AS 
 SELECT course_enrolments.student,
    course_enrolments.course,
    course_enrolments.mark,
    course_enrolments.grade,
    courses.subject,
    courses.semester
   FROM courses
     LEFT JOIN course_enrolments ON course_enrolments.course = courses.id;
-------------
create or replace function Q1_name(int)
returns text
as $$
select name from subjects where id = $1
$$ language sql;
-----------

-----------------------
create or replace function Q1_rank(ke integer)
returns table(student integer,rank bigint)
as $$
select student,rank() over (order by mark DESC)from course_enrolments
where course = ke
and mark is not null; 
$$ language sql;
----------------
create or replace function Q1_program_code(int)
returns char(4)
as $$
select code from programs
where id = $1;
$$ language sql;
----------------
create or replace function Q1_student_rank(stu integer, ke integer)
returns bigint
as $$
select rank from Q1_rank(ke)
where student = stu; 
$$ language sql;
-----------------------------
create or replace function Q1_total(integer)
returns bigint
as $$
select count(*) from course_enrolments
where mark is not null 
and course = $1
$$
language sql;
---------------------
---------------------------------
--create type TranscriptRecord as (code char(8), term char(4), course integer, prog char(4), name text, mark integer, grade char(2), uoc integer, rank integer, totalEnrols integer);

create or replace function Q2(integer)
	returns setof TranscriptRecord
as $$
declare
r TranscriptRecord%rowtype;
begin
for r in
select  
course,
Q1_term(Q1_all.semester),
Q1_course_code(subject),
--Q1_program_code(program),
Q1_name(subject),
Q1_uoc(Q1_id($1),course),
Q1_all.mark,
grade,
Q1_student_rank(Q1_id($1),course ) ,
Q1_total(course)

from Q1_all, program_enrolments
where Q1_all.student = Q1_id($1)
and Q1_all.semester = program_enrolments.semester
and Q1_all.student = program_enrolments.student loop 
return next r;
end loop;
return;
end;
$$
language plpgsql;






--Q3:
------------------------
create or replace function Q3_staff_role(int)
returns text
as $$
	select name from staff_roles where id = $1
     $$ language sql;
---------------------
create or replace function Q3_org_name(int)
returns char(64)
as $$
	select name from orgunits where id = $1
     $$ language sql;
-----------------------


--------------test--------------------------
create or replace function Q3_show(int)
returns setof EmploymentRecord
as $$
declare 
a record;
result text := '';
employ EmploymentRecord;
begin
	for a in select * from affiliations where  staff = $1  order by starting
	loop
		if a.ending is null then
			result := result||Q3_staff_role(a.role)||', '||Q3_org_name(a.orgunit)||' ('||a.starting||'..)'||E'\n';	
		else
			result := result||Q3_staff_role(a.role)||', '||Q3_org_name(a.orgunit)||' ('||a.starting||'..'||a.ending||')'||E'\n';
		end if;
	end loop;
	
	select Q3_unswid($1), Q3_name($1), result into employ;
	return next employ;
end
$$ language plpgsql;
      
	  
----------------------------------
create or replace function Q3_name(int)
returns char(128)
as $$
	select name from people where id = $1
$$ language sql;
------------------------------------
create or replace function Q3_unswid(int)
returns int
as $$
select unswid from people where id = $1
$$ language sql;
-------------------------

---------------------
create or replace function Q3_org(int)
returns setof int
as $$
	with recursive included_org(member) as(
		select member from orgunit_groups where owner = $1
	union 
		select p.member from included_org pr, orgunit_groups p where p.owner = pr.member)
	select member from included_org union select $1
$$ language sql;

-----------------------------


create type EmploymentRecord as (unswid integer, name text, roles text);
create or replace function Q3(integer) 
	returns setof EmploymentRecord 
as $$
 declare person int;
	       n int;
	       emp record ;
	       next_date date ;
	       t int := 0;
	       

 begin 
	for person in select staff from affiliations where orgunit in (select * from Q3_org($1)) group by (staff)
	loop 		
		next_date := null;
		t := 0;
		for emp in select * from affiliations where staff = person and orgunit in (select * from Q3_org($1)) order by starting 
		loop
			if next_date is not null then
				if next_date <= emp.starting then
					t := t+1;
				end if;
			end if;
			if next_date is null then
				next_date := emp.ending;
			end if;		
			if next_date < emp.ending then
				next_date := emp.ending;
			end if;
		end loop;
		if t > 0 then
		return next Q3_show(person);
		end if;
	end loop;
end;
$$ language plpgsql;



---hints
create type TeachingRecord as as (unswid integer, staff_name text, teaching_records text);
create or replace function Q3(org_id integer, num_sub integer, num_times integer) returns setof TeachingRecord...

--select subjects offeredby org_id 
select * from subjecs where offeredby = org_id
--select courses whose subjuct offered by org_id
select * from courses where subject in (select id from subjects where offeredby=52);
--select staff who teach those courses more than 8 times
select * from course_staff where course in (select id from courses where subject in (select id from subjects where offeredby=52));
--simplify
create or replace view q3_times as
select cs.staff,count(cs.staff) as times from course_staff cs, courses c, subjects s,q3_tutor
where c.id=cs.course and c.subject = s.id and s.offeredby = 52
and cs.role != q3_tutor.id
group by cs.staff having count(cs.staff)>8;

--more than 20 courses

select cs.course,cs.staff from course_staff cs, courses c, subjects s,q3_tutor
where c.id=cs.course and c.subject = s.id and s.offeredby = 52
and cs.role != q3_tutor.id
group by cs.course, cs.staff order by cs.course;

--create view in order to apply
create or replace view q3_staff_have_teach as 
select * from course_staff 
where course in (select id from courses where subject in (select id from subjects where offeredby=52));

--find out 'tutor' role_id in those course
select * from staff_roles where id in (select distinct role from q3_staff_have_teach);
  id  | rtype | rclass |      name       |                   description                   
------+-------+--------+-----------------+-------------------------------------------------
 1870 | A     | A      | Course Convenor | Academic who runs course (aka LIC)
 3003 | A     | A      | Course Lecturer | Staff member who co-shares teaching of a course
 3004 | A     | A      | Course Tutor    | Staff membe
 /*thus, the '3004' should not be condider*/
 --by the way, there are all tutor role_id 
create or replace view q3_tutor as 
select * from staff_roles where name like '%Tutor%' or description like '%totur%';
  id  | rtype | rclass |            name             |           description            
------+-------+--------+-----------------------------+----------------------------------
 1537 | G     | E      | Tutor                       | 
 1819 |       |        | Tutor (Professional & Tech) | 
 3004 | A     | A      | Course Tutor                | Staff member who takes tutorials
 


--
select staff,count(*) from course_staff 
where staff in (select staff from q3_times) 
and role not in (select id from q3_tutor) group by staff having count(*)>20

---distinct subjects
--select courses whose subjuct offered by org_id
select id,subject from courses where subject in (select id from subjects where offeredby=52) group by subject,id
having count(distinct subject)>20;


select cs.staff,count(cs.staff) as times from course_staff cs, courses c, subjects s,q3_tutor
where c.id=cs.course and c.subject = s.id and s.offeredby = 52
and cs.role != q3_tutor.id
group by cs.staff 
having count(distinct c.subject)>20







--code from wanghao

-- Q3: ...
create type TeachingRecord as (unswid integer, staff_name text, teaching_records text);



create or replace view Q3_T(unswid,cid,role_number,staffid,role_name,subject_code,people_name,orgunit_name,orgunit_id)
as

	select people.unswid,courses.id,course_staff.role,staff.id,staff_roles.name,subjects.code,people.name,orgunits.name,orgunits.id
	from (
		(
			(
				(
					(
						(
							course_staff join staff on staff.id = course_staff.staff
						) 
						join staff_roles on course_staff.role = staff_roles.id
					) 
					join courses on courses.id = course_staff.course
				)
				join subjects on subjects.id = courses.subject
			)
			join people on people.id = staff.id
		)
		join orgunits on orgunits.id = subjects.offeredby
	)
	where staff_roles.name != 'Course Tutor';

;


create or replace function Q3(org_id integer, num_sub integer, num_times integer) 
	returns setof TeachingRecord 
as $$
declare 
	tmp TeachingRecord;
	r record;
	x integer := 0 ;
	y varchar;
	b varchar;
begin

	
	return query 
	(
		select unswid,staff_name,string_agg(teaching_records,'' order by staff_name,teaching_records) 
		from tmp_q3(org_id,num_sub,num_times) group by unswid,staff_name order by staff_name
	);
end;

$$ language plpgsql;




create or replace function tmp_q3(org_id integer, num_sub integer, num_times integer) 
	returns setof TeachingRecord 
as $$
declare 
	tmp TeachingRecord;
	r record;
	x integer := 0 ;
	y varchar;
	b varchar;
	a varchar;
begin
	for x in (select member from orgunit_groups where owner = org_id)
	loop

		for y in 
		(
			select people_name
			from (
					select people_name,subject_code,count(subject_code) 
					from q3_t 
					where orgunit_id = x 
					group by people_name,subject_code
				) a 
			group by a.people_name having count(a.people_name) > num_sub
		)
		loop
				for r in 
				(
					select subject_code,count(subject_code) as num
					from q3_t 
					where orgunit_id = x and people_name = y 
					group by people_name,subject_code 
					having count(subject_code) > num_times
				)
				loop 

					tmp.staff_name := y ; 
					select unswid into tmp.unswid from q3_t where people_name = tmp.staff_name ;
					select orgunit_name into b from q3_t where people_name = tmp.staff_name;

					tmp.teaching_records := r.subject_code||', '||r.num||', '||b||'
';


					return next tmp;
				end loop;
		end loop;
	end loop;
	return;
end;

$$ language plpgsql;
