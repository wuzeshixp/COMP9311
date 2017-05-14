###################################
PREPARE


####################################
$ ssh grieg
$ cd /srvr/YOU
$ source /srvr/YOU/env
$ initdb
$ edit $PGDATA/postgresql.conf
... set unix_socket_directories = 'name of PGDATA directory' ...
... set max_connections = 5 ...
... set listen_addresses = '' ...
$ pg_ctl start -l $PGDATA/log
$ psql -l

$createdb  proj1
$ psql  proj1  -f  /home/cs9311/web/17s1/proj/proj1/mymyunsw.dump
$ psql  proj1
... run some checks to make sure the database is ok

proj1=# \d
... look at the schema ...
proj1=# select * from Students;
... look at the Students table ...
proj1=# select p.unswid,p.name from People p join Students s on (p.id=s.id);
... lookat the names and UNSW ids of all students ...
proj1=# select p.unswid,p.name,s.phone from People p join Staff s on (p.id=s.id);
... look at the names, staff ids, and phone #s of all staff ...
proj1=# select count(*) from Course_Enrolments;
... how many course enrolment records ...
proj1=# select * from dbpop();
... how many records in all tables ...
proj1=# select * from transcript(3197893);
... transcript for student with ID 3197893
...
proj1=# ... etc. etc. etc.
proj1=# \q


$ mkdir  Project1Directory
... make a working directory for Project 1
$ cp  /home/cs9311/web/17s1/proj/proj1/proj1.sql  Project1Directory




##########################################################
project1 question1 

Define a SQL view Q1(unswid,name)that gives all the buildings that have more than 30 rooms. 
Each tuple in the view should contain the following:
the id of the building (Buildings.unswidfield) 
the name of the building (Buildings.namefield)
##########################################################
proj1=# select building,count(*) from rooms group by building having count(building)>30;

                           building | count 
                          ----------+-------
                                112 |    41
                                115 |    47
                                107 |    51
                                121 |    40
                                101 |    39
                                213 |    55
                                117 |    49
                                111 |    56
                                100 |    78
                                116 |    42
                                102 |    35
                                105 |    35
                          (12 rows)
                          
proj1=# select unswid,name from buildings where id in (select building from rooms group by building having count(building)>30);
                             unswid |              name               
                            --------+---------------------------------
                             K17    | Computer Science Building
                             MECH   | Mechanical Engineering Building
                             CHEMSC | Chemical Sciences Building
                             ASB    | Australian School of Business
                             EE     | Electrical Engineering Building
                             MAT    | Mathews Building
                             MB     | Morven Brown Building
                             OMB    | Old Main Building
                             QUAD   | Quadrangle
                             RC     | Red Centre
                             WEB    | Robert Webster Building
                             F      | Building F
                            (12 rows)
      
 proj1=# create view Q1 as select unswid,name from buildings where id in 
        (select building from rooms group by building having count(building)>30);
 
 
 
 
####################################################################################################################
project1 question2

Define a SQL view Q2(name,faculty,phone,starting)which gives the details about 
all of the current Dean of Faculty. Each tuple in the view should contain the following:

his/her name (use the name field from the People table)

the faculty (use the longname field from the OrgUnits table)

his/her phone number (use the phone field from Staff table)

the date when he/she was a ppointed (use the starting field from the Affiliations table)
Since there is some dirty-looking data in the Affiliations table,
you will need to ensure that you return only legitimate Deans of Faculty. Apply the following filters together:

only choose people whose role is exactly ‘Dean’


Every current Dean has null value in the Affiliations.ending field;;;;;;;;;;;;;;;;;;;;;;;;;;
##########################################################################################################################



proj1=# select * from orgunits where utype =1;

  id  | utype |                name                 |                  longname                   | unswid |  phone   |         email         | website |  starting  |   ending   
------+-------+-------------------------------------+---------------------------------------------+--------+----------+-----------------------+---------+------------+------------
    2 |     1 | Board Studies Sci & Math            | Board of Studies in Science and Mathematics | BSSM   |          |                       |         | 1990-01-01 | 2000-01-01
    3 |     1 | Faculty of Life Sciences            | Faculty of Life Sciences                    | LIFE   |          |                       |         | 2000-01-01 | 2005-01-01
   31 |     1 | Faculty of Arts and Social Sciences | Faculty of Arts and Social Sciences         | ARTSC  |          |                       |         | 2000-01-01 | 
   38 |     1 | UNSW Canberra at ADFA               | UNSW Canberra at ADFA                       | UNICL  |          |                       |         | 2000-01-01 | 
   52 |     1 | Faculty of Science                  | Faculty of Science                          | SCI    |          |                       |         | 2000-01-01 | 
   64 |     1 | Faculty of Built Environment        | Faculty of Built Environment                | BLTEN  | 93854799 | fbe@unsw.edu.au       |         | 2000-01-01 | 
   82 |     1 | College of Fine Arts (COFA)         | College of Fine Arts (COFA)                 | COFA   | 93850684 | cofa@unsw.edu.au      |         | 2000-01-01 | 
  112 |     1 | Faculty of Engineering              | Faculty of Engineering                      | ENG    |          |                       |         | 1980-01-01 | 
  164 |     1 | Faculty of Law                      | Faculty of Law                              | LAW    |          |                       |         | 2000-01-01 | 
  183 |     1 | Faculty of Medicine                 | Faculty of Medicine                         | MED    |          |                       |         | 2000-01-01 | 
 1278 |     1 | Australian School of Business       | Australian School of Business               | COM\dM   | 99319500 |                       |         | 2000-01-01 | 
 1519 |     1 | UNSW Asia                           | UNSW Asia                                   | ASIA   |          |                       |         | 2000-01-01 | 
 1597 |     1 | Faculty of AA                       | The Academic Administration Faculty (Test)  |        | 93850000 | wlmok@cse.unsw.edu.au |         | 2000-01-01 | 
 1626 |     1 | BOS                                 | DVC (A) Board of Studies                    |        |          |                       |         | 2000-01-01 | 
(14 rows)


proj1=# select * from staff_roles where name='Dean';
                                    id  | rtype | rclass | name | description 
                                  ------+-------+--------+------+-------------
                                   1286 | A     | A      | Dean | 
                                  (1 row)


proj1=# select * from affiliations where role=1286 and ending IS NULL;

                                    staff   | orgunit | role | isprimary |  starting  | ending 
                                  ----------+---------+------+-----------+------------+--------
                                   50404791 |     112 | 1286 | t         | 2001-01-01 | 
                                   50404791 |    1446 | 1286 | f         | 2001-01-01 | 
                                   50404791 |    1448 | 1286 | f         | 2001-01-01 | 
                                    5034591 |    1567 | 1286 | f         | 2010-03-05 | 
                                    5034591 |     164 | 1286 | t         | 2010-03-05 | 
                                   50280287 |    1450 | 1286 | f         | 2001-01-01 | 
                                   50280287 |      31 | 1286 | t         | 2001-01-01 | 
                                   50405697 |      64 | 1286 | t         | 2010-03-05 | 
                                   50405697 |    1572 | 1286 | f         | 2010-03-08 | 
                                   50405697 |    1573 | 1286 | f         | 2010-03-09 | 
                                   50392143 |    1571 | 1286 | f         | 2010-03-09 | 
                                   50500017 |    1568 | 1286 | f         | 2010-06-07 | 
                                   50500017 |    1569 | 1286 | f         | 2010-06-07 | 
                                   50500017 |      52 | 1286 | t         | 2010-06-07 | 
                                   50392143 |    1570 | 1286 | f         | 2010-03-08 | 
                                   50392143 |     183 | 1286 | t         | 2010-08-12 | 
                                   50404672 |      31 | 1286 | f         | 2012-07-25 | 
                                   50500017 |    1506 | 1286 | f         | 2001-01-01 | 
                                   50509754 |    1278 | 1286 | t         | 2013-02-19 | 
                                    5034580 |      82 | 1286 | t         | 2013-04-01 | 
                                    5034580 |    1575 | 1286 | f         | 2013-04-22 | 
                                  (21 rows)


proj1=# select * from affiliations where role=1286 and ending IS NULL and orgunit in
(select id from orgunits where utype=1);
                                  staff   | orgunit | role | isprimary |  starting  | ending 
                                ----------+---------+------+-----------+------------+--------
                                 50280287 |      31 | 1286 | t         | 2001-01-01 | 
                                 50404672 |      31 | 1286 | f         | 2012-07-25 | 
                                 50500017 |      52 | 1286 | t         | 2010-06-07 | 
                                 50405697 |      64 | 1286 | t         | 2010-03-05 | 
                                  5034580 |      82 | 1286 | t         | 2013-04-01 | 
                                 50404791 |     112 | 1286 | t         | 2001-01-01 | 
                                  5034591 |     164 | 1286 | t         | 2010-03-05 | 
                                 50392143 |     183 | 1286 | t         | 2010-08-12 | 
                                 50509754 |    1278 | 1286 | t         | 2013-02-19 | 
                                (9 rows)




 



Q.name:#select name from people where id in
(select staff from affiliations where role=1286 and ending IS NULL and orgunit in
(select id from orgunits where utype=1));     

Q.faculty:#select longname from orgunits where utype =1 and id in
(select orgunit from affiliations where role=1286 and ending IS NULL and orgunit in
(select id from orgunits where utype=1));      

Q2.phone:#select phone from staff where id in
(select staff from affiliations where role=1286 and ending IS NULL and orgunit in
(select id from orgunits where utype=1));     

Q2.starting:#select starting from affiliations where role=1286 and ending IS NULL and orgunit in
(select id from orgunits where utype=1);


proj1=# create view Q2 as select people.name AS NAME, longname AS FACULTY,staff.phone AS PHONE,affiliations.starting AS STARTING
from people,orgunits,affiliations,staff
where orgunits.utype=1 and orgunits.id = affiliations.orgunit and affiliations.role=1286 and affiliations.ending IS NULL
and people.id=affiliations.staff and staff.id=affiliations.staff;

####################################################################################################################

####################################################################################################################

select * from Q2 where starting =(select min(starting) from Q2) or starting =(select max(starting) from Q2);
     name      |               faculty               |  phone   |  starting
---------------+-------------------------------------+----------+------------
 Graham Davies | Faculty of Engineering              | 93854970 | 2001-01-01
 James Donald  | Faculty of Arts and Social Sciences | 93851739 | 2001-01-01
 Ross Harley   | College of Fine Arts (COFA)         | 93850758 | 2013-04-01

//http://www.cnblogs.com/xiaowu/archive/2011/08/17/2143445.html
//http://www.cnblogs.com/Richardzhu/p/3571670.html
//proj1 q3 wuzeshi 
create view Q3 as
select (case 
           when starting =(select max(starting) from Q2) then 'Shortest serving'
           when starting =(select min(starting) from Q2) then 'Longest serving'
           else 'warning'
           end
          ) status ,name, faculty, starting
from Q2 where starting =(select min(starting) from Q2) or starting =(select max(starting) from Q2);

///

select (case when eftsload>0 then uoc/eftsload end) as ratio ,count(*) from subjects group by ratio;
##因为eftsload 可能为0##

select cast(eftsload as numeric(4,1)) from subjects;

select cast((case when eftsload>0 then uoc/eftsload end) as numeric(4,1)) as ratio ,
count(*) as nsubjects from subjects group by ratio;

  create view q4 as 
  select cast(
                (case 
                 when eftsload>0 then uoc/eftsload 
                 else 0
                 end
                ) as numeric(4,1)
              ) as ratio ,
  count(*) as nsubjects from subjects group by ratio;
  
  
  
q5 
international student:
select * from students where stype='intl';

proj1=# select * from semesters where term='S1' and year=2010;
 id  | unswid | year | term |   name    |    longname     |  starting  |   ending   |  startbrk  |   endbrk   | endwd |  endenrol  |   census
-----+--------+------+------+-----------+-----------------+------------+------------+------------+------------+-------+------------+------------
 164 |   5104 | 2010 | S1   | Sem1 2010 | Semester 1 2010 | 2010-03-01 | 2010-06-07 | 2010-04-02 | 2010-04-11 |       | 2010-03-08 | 2010-03-31
(1 row)


select count(*) from program_enrolment where semester= 164
  
proj1=# select * from programs where firstoffer = 164;
  id  | code |              name              | uoc | offeredby | career | duration | description | firstoffer | lastoffer
------+------+--------------------------------+-----+-----------+--------+----------+-------------+------------+-----------
 6085 | 3984 | Computer Science / Law         | 240 |       164 | UG     |       60 |             |        164 |
 6086 | 3987 | Science (International)        | 192 |        52 | UG     |          |             |        164 |


proj1=# select id from streams where code ='SENGA1';
  id
------
 1275
 1771
(2 rows)

proj1=# select * from stream_enrolments where stream in (select id from streams where code ='SENGA1');
获得partof = programs_enrolments.id

proj1=#select * from program_enrolments where id in (select partof from stream_enrolments where stream in (select id from streams where code ='SENGA1'));
获得所有Software Engineering (SENGA1) stream的学生

create or replace view q5a as
select count(*)
from  program_enrolments,students,semesters,stream_enrolments,streams
where program_enrolments.id = stream_enrolments.partof
and stream_enrolments.stream= streams.id and streams.code='SENGA1'
and program_enrolments.semester=semesters.id and semesters.term='S1' and semesters.year =2010
and program_enrolments.student = students.id and students.stype = 'intl';  

q5b
select count(*) from program_enrolments,students 
where program = 554 and semester=164 and program_enrolments.student = students.id and students.stype = 'local';

create or replace view q5b as
select count(*) from program_enrolments,students,semesters,programs
where program_enrolments.program = programs.id and programs.code='3978' 
and program_enrolments.semester=semesters.id and semesters.term='S1' and semesters.year =2010
and program_enrolments.student = students.id and students.stype = 'local';


q5c
create or replace view q5c as
select count(*) from program_enrolments,students,semesters,programs,orgunits
where programs.offeredby=orgunits.id and orgunits.name='Faculty of Engineering'
and program_enrolments.program = programs.id
and program_enrolments.semester=semesters.id and semesters.term='S1' and semesters.year =2010
and program_enrolments.student = students.id;



q6

create or replace function q6(text) returns text 
as $$ select code,name from subjects where code = $1; 
$$ language sql;

create or replace function test(text) 
returns text 
as $$ select name from subjects where code = $1; 
$$ language sql;

合并文本
SELECT code,STUFF((SELECT ','+name FROM subjects),1,1,'') FROM subjects GROUP BY 其他列

显示结果带有括号，逗号，引号
sleproj1=# select ( cast(code as text),cast(name as text))as fuck from subjects;
                    fuck
---------------------------------------------
 (COFA9305,"PhD (Sat) Part-Time")
 (MNGT1373,"Managing Change-Online")

create or replace function TasterAddress(text) returns text
as $$
   select loc.state||', '||loc.country
   from   Taster t, Location loc
   where  t.given = $1 and t.livesIn = loc.id
$$ language sql;

显示结果无括号，逗号，引号
   select (code||' '||name)as fuck
   from   subjects  

//select REPLACE('abc bcd cde def',' ', ',');


create or replace function q6(text) returns text 
as $$ select (code||' '||name)as cname from subjects where code = $1; 
$$ language sql;






Q7
select id,code from subjects where name='Database Systems';
  id  |   code
------+----------
 1884 | COMP3311
 4897 | COMP9311
 
select * from courses where subject in (select id from subjects where name='Database Systems');
//obtain all information and courses.id about subjects1884 & 4897 enrollment
                id   | subject | semester | homepage
              -------+---------+----------+----------
                1572 |    4897 |      122 |
                3524 |    1884 |      123 |
                3552 |    4897 |      123 |
                5705 |    1884 |      126 |



select course, count(*) from course_enrolments where 
course in (select id from courses where subject in (select id from subjects where name='Database Systems'))
group by course;


 比如下面的sql语句：
① selete * from testtable limit 2,1;
② selete * from testtable limit 2 offset 1;
注意：
1.数据库数据计算是从0开始的
2.offset X是跳过X个数据，limit Y是选取Y个数据
3.limit  X,Y  中X表示跳过X个数据，读取Y个数据
这两个是能完成需要，但是他们之间是有区别的：
①是从数据库中第三条开始查询，取一条数据，即第三条数据读取，一二条跳过
②是从数据库中的第二条数据开始查询两条数据，即第二条和第三条。


create view q7 as 
select s1.year, s1.term, 
cast(
      count(ce.student)::float/lag(count(ce.student)) 
      over (order by s1.starting) as numeric (4,2)
    ) as perc_growth
from course_enrolments ce, courses c, subjects s, semesters s1
where ce.course = c.id and c.subject = s.id and c.semester= s1.id and s.name = 'Database Systems'
group by s1.year, s1.term, s1.starting offset 1;


create or replace view q7 (year,term,perc_growth) as select term.year, term.term,
cast(
count(ce.student) :: float / lag(count(ce.student))
over ( order by term.starting) as numeric(4,2)) as perc_growth
from course_enrolments ce, courses c, subjects s, semesters term
where ce.course = c.id
and c.subject = s. id
and c.semester = term.id
and s.name='Database Systems'
group by term.year, term.term, term.starting offset 1;




# q8

create or replace view Q8(subject)
as
select (code || ' ' || name) as subject from subjects
where id in (select subject from ( 
	select subject, row_number() over (partition by courses.subject order by starting desc) as index
	from semesters join courses on courses.semester = semesters.id) as get_index
	where index <= 20
	group by subject having count(subject) >= 20
except
select subject from courses where id in (select course from course_enrolments group by course having count(student) >= 20));


# q9

create view q9_new_ce as 
select ce.course, ce.mark, courses.semester, semesters.year,semesters.starting
from course_enrolments ce, courses, subjects,semesters
where ce.course=courses.id 
and courses.subject= subjects.id 
and courses.semester = semesters.id
and subjects.name='Database Systems'

create view q9_en_all as 
select year,starting,semester,count(semester) as num_all 
from coure enrolments where mark >=0 group by year,starting,semester;

create view q9_en_pass as 
select year,starting,semester,count(semester) as num_pass 
from coure enrolments where mark >=50 group by year,starting,semester;


create view q9_semester_rate as 
select a.year,a.starting,a.semester,
cast((b.num_pass :: float / a.num_al) as numeric (4.2)) as rate
from q9_en_all a,q9_en_pass b 
where a.starting = b.starting;

create or replace view q9 as
select substring '(' #something wrong with this bracket,but the function works
cast(
     a.year as char(4)),3,2
        ) as year,
a.rate as s1_pass_rate, b.rate as s2_pass_rate

from q9_semester_rate a,q9_semester_rate b
where a.year=b.year where a.starting < b.staring order by a.year;


# q10
             
select * from subjects where code like 'COMP93%';
                 
create view q10_s as 
select id , year, term
where year between 2002 and 2013
and term ='S1' OR term='S2';

create view q10_courses as 
select s.year, s.term, courses.id,subjects.name
from courses,subjects,q10_s s
where subjects.code like 'COMP93%'
and courses.subject = subjects.id
and courses.semester= s.id;

create view q10_unpass as 
select ce.student,ce.course,ce.mark,subjects.code
from course_enrolments ce, courses, subjects
where ce.course =course.id
and course.subject = subjects.id

select un.student,un.code from q10_unpass un , q10_courses c, people
where people.id = un.student
and c.id= un.student







-- Q10: find all students who failed all black series subjects

create or replace view all_course_q10(id, semester, year, term, longname, subject, subject_number)
as
select c.id, c.semester, se.year, se.term, su.longname, c.subject, count(subject) over (partition by subject) as subject_number
from courses c join semesters se on se.id = c.semester 
join subjects su on su.id = c.subject
where su.code ~ '^COMP93'
and (se.term = 'S1' or se.term = 'S2') and se.year >= 2002 and se.year <= 2013
;

create or replace view all_student_q10(mark, student, longname, semester, term, year)
as
select mark, student, longname, semester, term, year from course_enrolments ce
join all_course_q10 acq on ce.course = acq.id
where acq.subject_number = 24
and mark >= 0
;

create or replace view fail_student_q10(student)
as
select student from (select distinct student, longname from all_student_q10 where mark < 50) as a 
group by student 
having count(student) = 2
; 

create or replace view Q10(zid, name)
as
select ('z' || unswid) as zid, name from people where id in (select student from fail_student_q10);





#


