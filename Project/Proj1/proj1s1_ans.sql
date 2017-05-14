-- COMP9311 17s1 Project 1
--
-- MyMyUNSW Solutions

-- Q1: buildings that have more than 30 rooms
create or replace view Q1(unswid, name)
as
select b.unswid,b.name
from Buildings b
     join Rooms r on (b.id=r.building)
group by b.id
having count(r.id) > 30
;


-- Q2: get details of the current Deans of Faculty
create or replace view Q2(name, faculty, phone, starting)
as
select p.name, u.longname, f.phone, a.starting
from people p
     join affiliations a on (a.staff=p.id)
     join staff_roles r on (a.role = r.id)
     join orgunits u on (a.orgunit = u.id)
     join orgunit_types t on (u.utype = t.id)
     join staff f on (f.id=p.id)
where r.name = 'Dean'
      and t.name = 'Faculty'
      and (a.ending is null)
;


-- Q3: get details of the longest-serving and shortest-serving current Deans of Faculty
create or replace view LongestServingDoF(status, name, faculty, starting)
as
select 'Longest serving'::text, Q2.name, Q2.faculty, Q2.starting
from Q2
where starting = (select min(starting) from Q2)
;

create or replace view ShortestServingDoF(status, name, faculty, starting)
as
select 'Shortest serving'::text, Q2.name, Q2.faculty, Q2.starting
from Q2
where starting = (select max(starting) from Q2)
;

create or replace view Q3(status, name, faculty, starting)
as
(select * from LongestServingDoF)
union
(select * from ShortestServingDoF)
;


-- Q4 UOC/ETFS ratio
create or replace view Q4(ratio,nsubjects)
as
select cast(uoc/eftsload as numeric(4,1)), count(uoc/eftsload)
from subjects
where eftsload != 0 or eftsload != null 
group by cast(uoc/eftsload as numeric(4,1))
;

