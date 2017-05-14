-- COMP9311 17s1 Project 1
--
-- MyMyUNSW Solutions

-- Q5: program enrolments from 10s1
create or replace view all_stream_enrolments
as
select p.unswid, t.year, t.term, st.code, sn.stype
from People p
     join Program_enrolments pe on (p.id=pe.student)
     join Stream_enrolments se on (pe.id=se.partof)
     join Streams st on (se.stream=st.id)
     join Semesters t on (t.id=pe.semester)
     join Students sn on (p.id=sn.id)
;

create or replace view all_program_enrolments
as
select p.unswid, t.year, t.term, pr.id, pr.code, u.longname as unit, sn.stype
from People p
     join Program_enrolments e on (p.id=e.student)
     join Programs pr on (pr.id=e.program)
     join Semesters t on (t.id=e.semester)
     join OrgUnits u on (pr.offeredby=u.id)
     join Students sn on (p.id=sn.id)
;

create or replace view Q5a(num)
as
select count(*)
from all_stream_enrolments
where code = 'SENGA1' and year=2010 and term='S1' and stype='intl'
;

create or replace view Q5b(num)
as
select count(*)
from all_program_enrolments
where code = '3978' and year = 2010 and term = 'S1' and stype='local'
;

create or replace view Q5c(num)
as
select count(*)
from all_program_enrolments
where unit='Faculty of Engineering' and year=2010 and term='S1'
;


-- Q6: course CodeName
create or replace function
	Q6(text) returns text
as
$$
select CONCAT(code, ' ', name) 
from Subjects s
where s.code = $1
$$ language sql;


-- Q7: Percentage of growth of students enrolled in Database Systems
create or replace view Q7_Courses(course, subject, semester, year, term, starting)
as
select c.id, c.subject, s.id, s.year, s.term, s.starting
from Courses c join Semesters s on (c.semester = s.id)
where c.subject in (select id from Subjects where name = 'Database Systems')
;

create or replace view Q7_Enroll(row, year, term, num_stu, starting)
as
select row_number() over(), c.year, c.term, count(*), c.starting
from Course_enrolments ce join Q7_Courses c on (ce.course = c.course)
group by c.year, c.term, c.starting
order by c.starting
;

create or replace view Q7(year, term, perc_growth)
as
select e1.year, e1.term, (e1.num_stu::float / e2.num_stu::float)::numeric(4,2)
from Q7_Enroll e1, Q7_Enroll e2
where e1.row = e2.row + 1
;


-- Q8: Least popular subjects
create or replace view Q8(subject)
as
select code||' '||name
from Subjects
where id in ( select subject
              from ( select subject, c2.id
                     from Courses c2
                          left outer join Course_enrolments on (c2.id = course)
                          join Subjects s2 on (subject = s2.id)
                     where c2.id in ( select id 
                                      from( select c1.id, rank() over (partition by subject order by starting desc) 
                                            from Courses c1 join Semesters s1 on (semester = s1.id)
                                            where subject in ( select subject
                                                               from Courses 
                                                               group by subject 
                                                               having count(*) >= 20 
                                                             )
                                          ) as A
                                      where rank <= 20
                                    )
                     group by c2.id
                     having count(*) < 20
                   ) as B
              group by subject
              having count(*) = 20
            )
order by code||' '||name
;


-- Q9: Database Systems pass rate for both semester in each year
create or replace view Q9(year, s1_pass_rate, s2_pass_rate)
as
select year,
       (s1npass::float / s1n::float)::numeric(4,2),
       (s2npass::float / s2n::float)::numeric(4,2)
from ( select substr(year::text,3,2) as year,
              sum(case when term='S1' and mark >= 50 then 1 else 0 end) as s1npass,
              sum(case when term='S1' then 1 else 0 end) as s1n,
              sum(case when term='S2' and mark >= 50 then 1 else 0 end) as s2npass,
              sum(case when term='S2' then 1 else 0 end) as s2n
       from ( select ce.mark, c.year, c.term
              from Q7_Courses c join Course_enrolments ce on (c.course=ce.course)
              where ce.mark >= 0
	        ) as A
       group by year
       order by year asc
     ) as B
;


-- Q10: find all students who failed all black series subjects
create or replace view Q10_Course(code, year, term)
as
select sub.code, sem.year, sem.term
from Subjects sub, Courses c, Semesters sem
where sub.id = c.subject and c.semester = sem.id
;

create or replace view Q10_MajorSemesters(year, term)
as
select distinct Semesters.year, Semesters.term
from Courses, Semesters
where Courses.semester = Semesters.id
      and (Semesters.year between 2002 and 2013) 
      and Semesters.term like 'S%'
order by Semesters.year, Semesters.term
;

create or replace view Q10_BlackSeries(code)
as
select distinct c.code
from Q10_Course c
where c.code like 'COMP93%'
      and not exists( (select year, term from Q10_MajorSemesters)
                      except
                      (select year, term from Q10_Course where code = c.code)
                    )
;

create or replace view Q10_Students(unswid, name, code)
as
select distinct p.unswid, p.name, s.code
from Course_enrolments ce, People p, Subjects s, Courses c
where ce.student = p.id
      and ce.course = c.id
      and c.subject = s.id
      and ce.mark < 50
      and s.code like 'COMP93%'
order by p.unswid
;

create or replace view Q10(zid, name)
as
select distinct 'z'||stu.unswid, stu.name
from Q10_Students stu
where not exists( (select code from Q10_BlackSeries)
                  except
                  (select code from Q10_Students where unswid = stu.unswid)
                )
;
