#!/bin/bash

sqlite3 movies_rating.db < db_init.sql

echo "1. Составить список фильмов, имеющих хотя бы одну оценку. Список фильмов отсортировать по году выпуска и по названиям. В списке оставить первые 10 фильмов."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "select movies.title, movies.year
from movies
         inner join ratings on movies.id = ratings.movie_id
group by ratings.movie_id
order by movies.year,
         movies.title
limit 10;"
echo " "

echo "2. Вывести список всех пользователей, фамилии (не имена!) которых начинаются на букву 'A'. Полученный список отсортировать по дате регистрации. В списке оставить первых 5 пользователей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "select users.name
from users
where substr(users.name, instr(users.name, ' ') + 1, length(users.name)) like 'A%'
order by users.register_date
limit 5;"
echo " "

echo "3. Написать запрос, возвращающий информацию о рейтингах в более читаемом формате: имя и фамилия эксперта, название фильма, год выпуска, оценка и дата оценки в формате ГГГГ-ММ-ДД. Отсортировать данные по имени эксперта, затем названию фильма и оценке. В списке оставить первые 50 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "select users.name,
       movies.title,
       movies.year,
       ratings.rating,
       strftime('%Y-%m-%d ', datetime(ratings.timestamp, 'unixepoch')) as date
from ratings
         inner join movies on movies.id = ratings.movie_id
         inner join users on users.id = ratings.user_id
order by substr(users.name, 1, instr(users.name, ' ') - 1),
         movies.title,
         ratings.rating
limit 50;"
echo " "

echo "4. Вывести список фильмов с указанием тегов, которые были им присвоены пользователями. Сортировать по году выпуска, затем по названию фильма, затем по тегу. В списке оставить первые 40 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "select movies.title, tags.tag
from movies
         inner join tags on tags.movie_id = movies.id
order by movies.year,
         movies.title,
         tags.tag
limit 40;"
echo " "

echo "5. Вывести список самых свежих фильмов. В список должны войти все фильмы последнего года выпуска, имеющиеся в базе данных. Запрос должен быть универсальным, не зависящим от исходных данных (нужный год выпуска должен определяться в запросе, а не жестко задаваться)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "select title
from movies
where movies.year = (select max(movies.year) from movies)
order by movies.year;"
echo " "

echo "6. Найти все комедии, выпущенные после 2000 года, которые понравились мужчинам (оценка не ниже 4.5). Для каждого фильма в этом списке вывести название, год выпуска и количество таких оценок. Результат отсортировать по году выпуска и названию фильма."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "select movies.title          as titleOfMopvie,
       movies.year           as yearOfMovieRealese,
       count(ratings.rating) as countRatings
from movies
         inner join ratings on ratings.movie_id = movies.id
         inner join users on users.id = ratings.user_id
where movies.genres like '%Comedy%'
  and movies.year >= 2000
  and users.gender = 'male'
  and ratings.rating >= 4.5
group by movies.id
order by movies.year,
         movies.title;"
echo " "

echo "7. Провести анализ занятий (профессий) пользователей - вывести количество пользователей для каждого рода занятий. Найти самую распространенную и самую редкую профессию посетитетей сайта."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "select t.userOccupation        as userOccupation,
       min(t.countOccupations) as countOccupation
from (select users.occupation as userOccupation,
             count(users.id)  as countOccupations
      from users
      group by users.occupation) as t

union

select t.userOccupation        as userOccupation,
       max(t.countOccupations) as countOccupation
from (select users.occupation as userOccupation,
             count(users.id)  as countOccupations
      from users
      group by users.occupation) as t;"
echo " "

