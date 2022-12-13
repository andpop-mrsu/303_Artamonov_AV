pragma foreign_keys = on;

drop table if exists studentExamMarks;
drop table if exists studentSessionResults;
drop table if exists studentResults;
drop table if exists students;
drop table if exists groupSubjects;
drop table if exists groups;
drop table if exists genders;
drop table if exists educationalDirectionsSubjects;
drop table if exists subjects;
drop table if exists educationalDirections;


create table educationalDirections
(
    id            integer primary key autoincrement,
    directionName varchar(100) unique not null check ( length(directionName) > 0 )
);

create table subjects
(
    id          integer primary key autoincrement,
    subjectName varchar(100) unique not null check ( length(subjectName) > 0)
);

create table educationalDirectionsSubjects
(
    id                     integer primary key autoincrement,
    subjectId              integer not null,
    educationalDirectionId integer not null,
    foreign key (subjectId) references subjects (id) on delete restrict,
    foreign key (educationalDirectionId) references educationalDirections (id) on delete restrict
);

create table genders
(
    id         integer primary key autoincrement,
    genderName varchar(100) not null check ( length(genderName) > 0)
);

create table groups
(
    id                   integer primary key autoincrement,
    groupNum             integer not null check ( groupNum > 0 ),
    registrationYear     integer default (cast(strftime('%Y', date('now')) as integer)),
    educationDirectionId integer not null,
    foreign key (educationDirectionId) references educationalDirections (id) on delete restrict
);

create table groupSubjects
(
    id                            integer primary key autoincrement,
    practicalHours                integer not null,
    theoreticalHours              integer not null,
    semesterNumber                integer not null check ( semesterNumber between 1 and 2),
    educationalYear               integer default (cast(strftime('%Y', date('now')) as integer)),
    isExam                        boolean not null,
    educationalDirectionSubjectId integer not null,
    groupId                       integer not null,
    foreign key (educationalDirectionSubjectId) references educationalDirectionsSubjects (id) on delete restrict,
    foreign key (groupId) references groups (id) on delete restrict
);

create table students
(
    id            integer primary key autoincrement,
    studentTicket integer      not null,
    surname       varchar(100) not null check ( length(surname) > 0),
    firstName     varchar(100) not null check ( length(firstName) > 0),
    secondName    varchar(100),
    birthdate     date         not null,
    genderId      integer      not null,
    groupId       integer      not null,
    foreign key (genderId) references genders (id) on delete restrict,
    foreign key (groupId) references groups (id) on delete restrict
);

create table studentResults
(
    id             integer primary key autoincrement,
    studentId      integer not null,
    groupSubjectId integer not null,
    points         integer not null default 0 check ( points >= 0 and points <= 100 ),
    isPassed       boolean,
    mark           integer check ( mark >= 2 and mark <= 5),
    foreign key (studentId) references students (id) on delete restrict,
    foreign key (groupSubjectId) references groupSubjects (id) on delete restrict
);

-- create table studentSessionResults
-- (
--     id             integer primary key autoincrement,
--     studentId      integer not null,
--     groupSubjectId integer not null,
--     isPassed       boolean not null,
--     foreign key (studentId) references students (id) on delete restrict,
--     foreign key (groupSubjectId) references groupSubjects (id) on delete restrict
-- );
--
-- create table studentExamMarks
-- (
--     id             integer primary key autoincrement,
--     studentId      integer not null,
--     groupSubjectId integer not null,
--     mark           integer not null check ( mark >= 2 and mark <= 5 ),
--     foreign key (studentId) references students (id) on delete restrict,
--     foreign key (groupSubjectId) references groupSubjects (id) on delete restrict
-- );

-----------------------------------------------------------

insert into educationalDirections (directionName)
values ('Прикладная математика и информатика'),
       ('Программная инженерия');

insert into subjects (subjectName)
values ('Базы данных'),
       ('Правоведение'),
       ('Уравнения математической физики'),
       ('Численные методы'),
       ('Архитектура микропроцессоров'),
       ('Дискретная математика');

insert into educationalDirectionsSubjects (subjectId, educationalDirectionId)
select subjects.id              as subjectId,
       educationalDirections.id as educationalDirectionId
from subjects,
     educationalDirections
where subjects.subjectName in ('Базы данных', 'Правоведение', 'Уравнения математической физики', 'Численные методы')
  and educationalDirections.directionName = 'Прикладная математика и информатика'
union
select subjects.id              as subjectId,
       educationalDirections.id as educationalDirectionId
from subjects,
     educationalDirections
where subjects.subjectName in ('Базы данных', 'Правоведение', 'Архитектура микропроцессоров', 'Дискретная математика')
  and educationalDirections.directionName = 'Программная инженерия';

insert into genders (genderName)
values ('парень'),
       ('девушка');

insert into groups (groupNum, educationDirectionId, registrationYear)
select 3                        as groupNum,
       educationalDirections.id as educationDirectionId,
       2020                     as registrationYear
from educationalDirections
where educationalDirections.directionName = 'Прикладная математика и информатика'
union
select 4                        as groupNum,
       educationalDirections.id as educationDirectionId,
       2021                     as registrationYear
from educationalDirections
where educationalDirections.directionName = 'Программная инженерия';

insert into groupSubjects (practicalHours, theoreticalHours, semesterNumber, educationalYear, isExam,
                           educationalDirectionSubjectId, groupId)
select 180                                                      as practicalHours,
       108                                                      as theoreticalHours,
       1                                                        as semesterNumber,
       2022                                                     as educationalYear,
       true                                                     as isExam,
       (select educationalDirectionsSubjects.id
        from educationalDirectionsSubjects
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Базы данных'
          and educationalDirections.directionName =
              'Прикладная математика и информатика')            as educationalDirectionSubjectId,
       (select groups.id from groups where groups.groupNum = 3) as groupId
union
select 180                                                      as practicalHours,
       108                                                      as theoreticalHours,
       1                                                        as semesterNumber,
       2022                                                     as educationalYear,
       false                                                    as isExam,
       (select educationalDirectionsSubjects.id
        from educationalDirectionsSubjects
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Правоведение'
          and educationalDirections.directionName =
              'Прикладная математика и информатика')            as educationalDirectionSubjectId,
       (select groups.id from groups where groups.groupNum = 3) as groupId
union
select 180                                                      as practicalHours,
       108                                                      as theoreticalHours,
       1                                                        as semesterNumber,
       2022                                                     as educationalYear,
       true                                                     as isExam,
       (select educationalDirectionsSubjects.id
        from educationalDirectionsSubjects
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Уравнения математической физики'
          and educationalDirections.directionName =
              'Прикладная математика и информатика')            as educationalDirectionSubjectId,
       (select groups.id from groups where groups.groupNum = 3) as groupId
union
select 180                                                      as practicalHours,
       108                                                      as theoreticalHours,
       1                                                        as semesterNumber,
       2022                                                     as educationalYear,
       false                                                    as isExam,
       (select educationalDirectionsSubjects.id
        from educationalDirectionsSubjects
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Численные методы'
          and educationalDirections.directionName =
              'Прикладная математика и информатика')            as educationalDirectionSubjectId,
       (select groups.id from groups where groups.groupNum = 3) as groupId
union
select 180                                                      as practicalHours,
       108                                                      as theoreticalHours,
       1                                                        as semesterNumber,
       2022                                                     as educationalYear,
       true                                                     as isExam,
       (select educationalDirectionsSubjects.id
        from educationalDirectionsSubjects
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Базы данных'
          and educationalDirections.directionName =
              'Программная инженерия')                          as educationalDirectionSubjectId,
       (select groups.id from groups where groups.groupNum = 4) as groupId
union
select 180                                                      as practicalHours,
       108                                                      as theoreticalHours,
       1                                                        as semesterNumber,
       2022                                                     as educationalYear,
       false                                                    as isExam,
       (select educationalDirectionsSubjects.id
        from educationalDirectionsSubjects
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Правоведение'
          and educationalDirections.directionName =
              'Программная инженерия')                          as educationalDirectionSubjectId,
       (select groups.id from groups where groups.groupNum = 4) as groupId
union
select 180                                                      as practicalHours,
       108                                                      as theoreticalHours,
       1                                                        as semesterNumber,
       2022                                                     as educationalYear,
       false                                                    as isExam,
       (select educationalDirectionsSubjects.id
        from educationalDirectionsSubjects
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Архитектура микропроцессоров'
          and educationalDirections.directionName =
              'Программная инженерия')                          as educationalDirectionSubjectId,
       (select groups.id from groups where groups.groupNum = 4) as groupId
union
select 180                                                      as practicalHours,
       108                                                      as theoreticalHours,
       1                                                        as semesterNumber,
       2022                                                     as educationalYear,
       true                                                     as isExam,
       (select educationalDirectionsSubjects.id
        from educationalDirectionsSubjects
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Дискретная математика'
          and educationalDirections.directionName =
              'Программная инженерия')                          as educationalDirectionSubjectId,
       (select groups.id from groups where groups.groupNum = 4) as groupId;

insert into students (studentTicket, surname, firstName, secondName, birthdate, genderId, groupId)
select 1303                                                                                          as studentTicket,
       'Никишкин'                                                                                    as surname,
       'Егор'                                                                                        as firstName,
       'Валерьевич'                                                                                  as secondName,
       '2002-10-16'                                                                                  as birthdate,
       (select genders.id from genders where genders.genderName = 'парень')                            as genderId,
       (select groups.id from groups where groups.groupNum = 3 and groups.registrationYear = '2020') as groupId
union
select 2303                                                                                          as studentTicket,
       'Артамонов'                                                                                   as surname,
       'Алексей'                                                                                     as firstName,
       'Валерьевич'                                                                                  as secondName,
       '2002-08-02'                                                                                  as birthdate,
       (select genders.id from genders where genders.genderName = 'парень')                            as genderId,
       (select groups.id from groups where groups.groupNum = 3 and groups.registrationYear = '2020') as groupId
union
select 3303                                                                                          as studentTicket,
       'Нуянзин'                                                                                     as surname,
       'Максим'                                                                                      as firstName,
       'Александрович'                                                                               as secondName,
       '2002-06-12'                                                                                  as birthdate,
       (select genders.id from genders where genders.genderName = 'парень')                            as genderId,
       (select groups.id from groups where groups.groupNum = 3 and groups.registrationYear = '2020') as groupId
union
select 4303                                                                                          as studentTicket,
       'Тураев'                                                                                      as surname,
       'Денис'                                                                                       as firstName,
       'Владиславович'                                                                               as secondName,
       '2001-12-26'                                                                                  as birthdate,
       (select genders.id from genders where genders.genderName = 'парень')                            as genderId,
       (select groups.id from groups where groups.groupNum = 3 and groups.registrationYear = '2020') as groupId
union
select 1204                                                                                          as studentTicket,
       'Венедиктова'                                                                                 as surname,
       'Яна'                                                                                         as firstName,
       'Петровна'                                                                                    as secondName,
       '2002-07-10'                                                                                  as birthdate,
       (select genders.id from genders where genders.genderName = 'девушка')                          as genderId,
       (select groups.id from groups where groups.groupNum = 4 and groups.registrationYear = '2021') as groupId
union
select 2204                                                                                          as studentTicket,
       'Бугреева'                                                                                    as surname,
       'Анна'                                                                                        as firstName,
       'Сергеевна'                                                                                   as secondName,
       '2002-09-27'                                                                                  as birthdate,
       (select genders.id from genders where genders.genderName = 'девушка')                          as genderId,
       (select groups.id from groups where groups.groupNum = 4 and groups.registrationYear = '2021') as groupId;


insert into studentResults (studentId, groupSubjectId, points, isPassed, mark)
select (select students.id from students where students.studentTicket = 1303) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Базы данных'
          and educationalDirections.directionName = 'Прикладная математика и информатика'
       )                                                                      as groupSubjectId,
       86                                                                     as points,
       true                                                                   as isPassed,
       5                                                                      as mark
union
select (select students.id from students where students.studentTicket = 1303) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Правоведение'
          and educationalDirections.directionName = 'Прикладная математика и информатика'
       )                                                                      as groupSubjectId,
       55                                                                     as points,
       true                                                                   as isPassed,
       null                                                                   as mark
union
select (select students.id from students where students.studentTicket = 1303) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Уравнения математической физики'
          and educationalDirections.directionName = 'Прикладная математика и информатика'
       )                                                                      as groupSubjectId,
       73                                                                     as points,
       true                                                                   as isPassed,
       4                                                                      as mark
union
select (select students.id from students where students.studentTicket = 1303) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Численные методы'
          and educationalDirections.directionName = 'Прикладная математика и информатика'
       )                                                                      as groupSubjectId,
       60                                                                     as points,
       true                                                                   as isPassed,
       null                                                                   as mark

union

select (select students.id from students where students.studentTicket = 2303) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Базы данных'
          and educationalDirections.directionName = 'Прикладная математика и информатика'
       )                                                                      as groupSubjectId,
       50                                                                     as points,
       false                                                                  as isPassed,
       2                                                                      as mark
union
select (select students.id from students where students.studentTicket = 2303) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Правоведение'
          and educationalDirections.directionName = 'Прикладная математика и информатика'
       )                                                                      as groupSubjectId,
       40                                                                     as points,
       false                                                                  as isPassed,
       null                                                                   as mark
union
select (select students.id from students where students.studentTicket = 2303) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Уравнения математической физики'
          and educationalDirections.directionName = 'Прикладная математика и информатика'
       )                                                                      as groupSubjectId,
       70                                                                     as points,
       true                                                                   as isPassed,
       3                                                                      as mark
union
select (select students.id from students where students.studentTicket = 2303) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Численные методы'
          and educationalDirections.directionName = 'Прикладная математика и информатика'
       )                                                                      as groupSubjectId,
       100                                                                    as points,
       true                                                                   as isPassed,
       null                                                                   as mark

union

select (select students.id from students where students.studentTicket = 3303) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Базы данных'
          and educationalDirections.directionName = 'Прикладная математика и информатика'
       )                                                                      as groupSubjectId,
       79                                                                     as points,
       true                                                                   as isPassed,
       4                                                                      as mark
union
select (select students.id from students where students.studentTicket = 3303) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Правоведение'
          and educationalDirections.directionName = 'Прикладная математика и информатика'
       )                                                                      as groupSubjectId,
       100                                                                    as points,
       true                                                                   as isPassed,
       null                                                                   as mark
union
select (select students.id from students where students.studentTicket = 3303) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Уравнения математической физики'
          and educationalDirections.directionName = 'Прикладная математика и информатика'
       )                                                                      as groupSubjectId,
       60                                                                     as points,
       true                                                                   as isPassed,
       3                                                                      as mark
union
select (select students.id from students where students.studentTicket = 3303) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Численные методы'
          and educationalDirections.directionName = 'Прикладная математика и информатика'
       )                                                                      as groupSubjectId,
       82                                                                     as points,
       true                                                                   as isPassed,
       null                                                                   as mark

union

select (select students.id from students where students.studentTicket = 4303) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Базы данных'
          and educationalDirections.directionName = 'Прикладная математика и информатика'
       )                                                                      as groupSubjectId,
       20                                                                     as points,
       false                                                                  as isPassed,
       2                                                                      as mark
union
select (select students.id from students where students.studentTicket = 4303) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Правоведение'
          and educationalDirections.directionName = 'Прикладная математика и информатика'
       )                                                                      as groupSubjectId,
       10                                                                     as points,
       false                                                                  as isPassed,
       null                                                                   as mark
union
select (select students.id from students where students.studentTicket = 4303) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Уравнения математической физики'
          and educationalDirections.directionName = 'Прикладная математика и информатика'
       )                                                                      as groupSubjectId,
       55                                                                     as points,
       true                                                                   as isPassed,
       3                                                                      as mark
union
select (select students.id from students where students.studentTicket = 4303) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Численные методы'
          and educationalDirections.directionName = 'Прикладная математика и информатика'
       )                                                                      as groupSubjectId,
       97                                                                     as points,
       true                                                                   as isPassed,
       null                                                                   as mark

union

select (select students.id from students where students.studentTicket = 1204) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Базы данных'
          and educationalDirections.directionName = 'Программная инженерия'
       )                                                                      as groupSubjectId,
       90                                                                     as points,
       true                                                                   as isPassed,
       5                                                                      as mark
union
select (select students.id from students where students.studentTicket = 1204) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Правоведение'
          and educationalDirections.directionName = 'Программная инженерия'
       )                                                                      as groupSubjectId,
       60                                                                     as points,
       true                                                                   as isPassed,
       null                                                                   as mark
union
select (select students.id from students where students.studentTicket = 1204) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Архитектура микропроцессоров'
          and educationalDirections.directionName = 'Программная инженерия'
       )                                                                      as groupSubjectId,
       67                                                                     as points,
       true                                                                   as isPassed,
       null                                                                   as mark
union
select (select students.id from students where students.studentTicket = 1204) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Дискретная математика'
          and educationalDirections.directionName = 'Программная инженерия'
       )                                                                      as groupSubjectId,
       10                                                                     as points,
       false                                                                  as isPassed,
       2                                                                      as mark

union

select (select students.id from students where students.studentTicket = 2204) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Базы данных'
          and educationalDirections.directionName = 'Программная инженерия'
       )                                                                      as groupSubjectId,
       45                                                                     as points,
       false                                                                  as isPassed,
       2                                                                      as mark
union
select (select students.id from students where students.studentTicket = 2204) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Правоведение'
          and educationalDirections.directionName = 'Программная инженерия'
       )                                                                      as groupSubjectId,
       70                                                                     as points,
       true                                                                   as isPassed,
       null                                                                   as mark
union
select (select students.id from students where students.studentTicket = 2204) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Архитектура микропроцессоров'
          and educationalDirections.directionName = 'Программная инженерия'
       )                                                                      as groupSubjectId,
       23                                                                     as points,
       false                                                                  as isPassed,
       null                                                                   as mark
union
select (select students.id from students where students.studentTicket = 2204) as studentId,
       (select groupSubjects.id
        from groupSubjects
                 inner join educationalDirectionsSubjects
                            on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
                 inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
                 inner join educationalDirections
                            on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
        where subjects.subjectName = 'Дискретная математика'
          and educationalDirections.directionName = 'Программная инженерия'
       )                                                                      as groupSubjectId,
       70                                                                     as points,
       true                                                                   as isPassed,
       3                                                                      as mark;

-----------------------------------------------------------

select studentResults.mark        as examMark,
       count(studentResults.mark) as countExamMarks
from studentResults
         inner join groupSubjects on groupSubjects.id = studentResults.groupSubjectId
         inner join groups on groups.id = groupSubjects.groupId
         inner join educationalDirectionsSubjects
                    on groupSubjects.educationalDirectionSubjectId = educationalDirectionsSubjects.id
         inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
where subjects.subjectName = 'Базы данных'
  and groups.groupNum = 3
group by studentResults.mark;

select students.surname || ' ' || students.firstName || ' ' || students.secondName as studentName
     , studentResults.mark                                                         as examMark
     , subjects.subjectName                                                        as examSubjectName
     , case
           when cast(strftime('%Y', date('now')) as integer) - groups.registrationYear + 1 <= 4
               then (cast(strftime('%Y', date('now')) as integer) -
                     groups.registrationYear + 1) * 100 + groups.groupNum
           else 400 + groups.registrationYear
    end                                                                            as groupNumber
from (select students.id as studentId
      from studentResults
               inner join students on students.id = studentResults.studentId
      where studentResults.mark >= 4
      except
      select students.id as studentId
      from studentResults
               inner join students on students.id = studentResults.studentId
      where studentResults.mark < 4) as t
         inner join students on students.id = t.studentId
         inner join studentResults on studentResults.studentId = students.id
         inner join groupSubjects on groupSubjects.id = studentResults.groupSubjectId
         inner join educationalDirectionsSubjects
                    on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
         inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
         inner join groups on groups.id = groupSubjects.groupId
where groupSubjects.isExam = true;


select distinct students.surname || ' ' || students.firstName || ' ' || students.secondName as studentName,
                studentResults.points                                                       as studentPoints,
                subjects.subjectName                                                        as subjectName,
                case
                    when cast(strftime('%Y', date('now')) as integer) - groups.registrationYear + 1 <= 4
                        then (cast(strftime('%Y', date('now')) as integer) -
                              groups.registrationYear + 1) * 100 + groups.groupNum
                    else 400 + groups.registrationYear
                    end                                                                     as groupNumber
from (select (select studentResults.id
              from studentResults
                       inner join students on students.id = studentResults.studentId
              where studentResults.groupSubjectId = groupSubjects.id
              order by studentResults.points desc
              limit 1
             ) as id
      from groupSubjects) as t
         inner join studentResults on studentResults.id = t.id
         inner join students on students.id = studentResults.studentId
         inner join groupSubjects on groupSubjects.id = studentResults.groupSubjectId
         inner join educationalDirectionsSubjects
                    on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
         inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
         inner join groups on groups.id = groupSubjects.groupId;


select t.studentName   as studentName,
       sum(t.examMark) as sumExamMarks,
       t.groupNumber   as groupNumber
from (select students.surname || ' ' || students.firstName || ' ' || students.secondName as studentName,
             studentResults.points                                                       as examMark,
             case
                 when cast(cast(strftime('%Y', date('now')) as integer) - cast(groups.registrationYear as integer) +
                           1 as integer) <= 4
                     then (cast(strftime('%Y', date('now')) as integer) -
                           groups.registrationYear + 1) * 100 + groups.groupNum
                 else 400 + groups.registrationYear
                 end                                                                     as groupNumber
      from studentResults
               inner join students on students.id = studentResults.studentId
               inner join groupSubjects on groupSubjects.id = studentResults.groupSubjectId
               inner join educationalDirectionsSubjects
                          on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
               inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
               inner join groups on groups.id = groupSubjects.groupId) as t
group by t.studentName
order by sum(t.examMark) desc;


select t.groupNumber   as groupNumber,
       sum(t.examMark) as sumExamMarks
from (select studentResults.points as examMark,
             case
                 when cast(cast(strftime('%Y', date('now')) as integer) - cast(groups.registrationYear as integer) +
                           1 as integer) <= 4
                     then (cast(strftime('%Y', date('now')) as integer) - groups.registrationYear + 1) * 100 +
                          groups.groupNum
                 else 400 + groups.registrationYear
                 end               as groupNumber
      from studentResults
               inner join students on students.id = studentResults.studentId
               inner join groupSubjects on groupSubjects.id = studentResults.groupSubjectId
               inner join educationalDirectionsSubjects
                          on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
               inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
               inner join groups on groups.id = groupSubjects.groupId) as t
group by t.groupNumber
order by sum(t.examMark) desc;


select students.surname || ' ' || students.firstName || ' ' || students.secondName as studentName,
       studentResults.mark                                                         as studentMark,
       (select studentResults.points
        from studentResults
        where studentResults.studentId = students.id
          and studentResults.groupSubjectId = groupSubjects.id)                    as studentPoints,
       subjects.subjectName                                                        as subjectName,
       case
           when cast(strftime('%Y', date('now')) as integer) - groups.registrationYear + 1 <= 4
               then (cast(strftime('%Y', date('now')) as integer) -
                     groups.registrationYear + 1) * 100 + groups.groupNum
           else 400 + groups.registrationYear
           end                                                                     as groupNumber
from students
         inner join studentResults on studentResults.studentId = students.id
         inner join groupSubjects on groupSubjects.id = studentResults.groupSubjectId
         inner join educationalDirectionsSubjects
                    on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
         inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
         inner join groups on groups.id = groupSubjects.groupId
    and students.studentTicket = 2303
    and groupSubjects.isExam = true;


select students.surname || ' ' || students.firstName || ' ' || students.secondName as studentName,
       (select case
                   when studentResults.isPassed then 'сдано'
                   else 'не сдано'
                   end
        from studentResults
        where studentResults.studentId = students.id
          and studentResults.groupSubjectId = groupSubjects.id)                    as isPassed,
       studentResults.points                                                       as studentPoints,
       subjects.subjectName                                                        as subjectName,
       case
           when cast(strftime('%Y', date('now')) as integer) - groups.registrationYear + 1 <= 4
               then (cast(strftime('%Y', date('now')) as integer) -
                     groups.registrationYear + 1) * 100 + groups.groupNum
           else 400 + groups.registrationYear
           end                                                                     as groupNumber
from students
         inner join studentResults on studentResults.studentId = students.id
         inner join groupSubjects on groupSubjects.id = studentResults.groupSubjectId
         inner join educationalDirectionsSubjects
                    on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
         inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
         inner join groups on groups.id = groupSubjects.groupId
where groupSubjects.isExam = false
  and students.studentTicket = 2303;


select students.surname || ' ' || students.firstName || ' ' || students.secondName as studentName,
       (select case
                   when studentResults.isPassed then 'сдано'
                   else 'не сдано'
                   end
        from studentResults
        where studentResults.studentId = students.id
          and studentResults.groupSubjectId = groupSubjects.id)                    as isPassed,
       studentResults.points                                                       as studentPoints,
       subjects.subjectName                                                        as subjectName,
       case
           when cast(strftime('%Y', date('now')) as integer) - groups.registrationYear + 1 <= 4
               then (cast(strftime('%Y', date('now')) as integer) -
                     groups.registrationYear + 1) * 100 + groups.groupNum
           else 400 + groups.registrationYear
           end                                                                     as groupNumber
from students
         inner join studentResults on studentResults.studentId = students.id
         inner join groupSubjects on groupSubjects.id = studentResults.groupSubjectId
         inner join groups on groups.id = groupSubjects.groupId
         inner join educationalDirectionsSubjects
                    on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
         inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
         inner join educationalDirections
                    on educationalDirections.id = educationalDirectionsSubjects.educationalDirectionId
where educationalDirections.directionName = 'Прикладная математика и информатика'
