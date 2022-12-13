#!/bin/bash

sqlite3 movies_rating.db < db_init.sql

echo "1. Найти все пары пользователей, оценивших один и тот же фильм. Устранить дубликаты, проверить отсутствие пар с самим собой. Для каждой пары должны быть указаны имена пользователей и название фильма, который они ценили."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "select users1.name, users2.name, movies.title from
ratings ratings1, ratings ratings2 on ratings1.movie_id = ratings2.movie_id
inner join movies on movies.id = ratings1.movie_id
inner join users users1 on users1.id = ratings1.user_id
inner join users users2 on users2.id = ratings2.user_id
where ratings1.user_id < ratings2.user_id limit 30;"
echo " "

echo "2. Найти 10 самых свежих оценок от разных пользователей, вывести названия фильмов, имена пользователей, оценку, дату отзыва в формате ГГГГ-ММ-ДД."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "select movies.title,
       users.name,
       ratings.rating,
       strftime('%Y-%m-%d ', datetime(ratings.timestamp, 'unixepoch')) as date
from ratings
         inner join movies on movies.id = ratings.movie_id
         inner join users on users.id = ratings.user_id
order by ratings.timestamp
limit 10;"
echo " "

echo "3. Вывести в одном списке все фильмы с максимальным средним рейтингом и все фильмы с минимальным средним рейтингом. Общий список отсортировать по году выпуска и названию фильма. В зависимости от рейтинга в колонке 'Рекомендуем' для фильмов должно быть написано 'Да' или 'Нет'."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "select t.title, t.year, t.rating, t.recommended
from (select movies.*, 'yes' as recommended, ratings.rating
      from movies
               inner join ratings on ratings.movie_id = movies.id
               inner join
           (select max(avgRatings.avgRating) as maxAvgrating
            from (select avg(ratings.rating) as avgRating
                  from movies
                           inner join ratings on ratings.movie_id = movies.id
                  group by movies.id) as avgRatings) as maxAvgRatings on maxAvgRatings.maxAvgrating = ratings.rating

      union

      select movies.*, 'no' as recommended, ratings.rating
      from movies
               inner join ratings on ratings.movie_id = movies.id
               inner join
           (select min(avgRatings.avgRating) as minAvgrating
            from (select avg(ratings.rating) as avgRating
                  from movies
                           inner join ratings on ratings.movie_id = movies.id
                  group by movies.id) as avgRatings) as minAvgratings
           on minAvgratings.minAvgrating = ratings.rating) as t
order by t.year,
         t.title;"
echo " "

echo "4. Вычислить количество оценок и среднюю оценку, которую дали фильмам пользователи-женщины в период с 2010 по 2012 год."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "select count(ratings.rating), avg(ratings.rating)
from ratings
         inner join users on users.id = ratings.user_id
where users.gender = 'female'
  and strftime('%Y', datetime(ratings.timestamp, 'unixepoch')) between '2010' and '2012';"
echo " "

echo "5. Составить список фильмов с указанием их средней оценки и места в рейтинге по средней оценке. Полученный список отсортировать по году выпуска и названиям фильмов. В списке оставить первые 20 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "select movies.*,
       t.avgRating,
       t.num
from movies
         inner join (select t2.num,
                            t1.movie_id,
                            t2.avgRating
                     from (select ratings.movie_id,
                                  avg(ratings.rating) as avgRating
                           from ratings
                           group by ratings.movie_id) as t1
                              inner join (select row_number() over (order by avgRatings.avgRating desc) as num,
                                                 avgRatings.avgRating
                                          from (select distinct avg(ratings.rating) as avgRating
                                                from ratings
                                                group by ratings.movie_id) as avgRatings) as t2
                                         on t2.avgRating = t1.avgRating) as t on t.movie_id = movies.id
order by movies.year,
         movies.title
limit 20;
"
echo " "

echo "6. Вывести список из 10 последних зарегистрированных пользователей в формате 'Фамилия Имя|Дата регистрации' (сначала фамилия, потом имя)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "select substr(users.name, instr(users.name, ' '), length(users.name))
           || ' '
           || substr(users.name, 0, instr(users.name, ' '))
           || '|'
           || users.register_date as name_registerDate
from users
order by users.register_date desc
limit 10;"
echo " "

echo "7. С помощью рекурсивного CTE составить таблицу умножения для чисел от 1 до 10."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "select x
           || '*'
           || y
           || '='
           || cast(cast(x as int) * cast(y as int) as varchar) as prod
from (select *
      from (with recursive prod(x) as (
          select 1
          union all
          select x + 1
          from prod
          limit 10
      )
            select x
            from prod)

               cross join

           (with recursive prod(y) as (
               select 1
               union all
               select y + 1
               from prod
               limit 10
           )
            select y
            from prod));"
echo " "

echo "8. С помощью рекурсивного CTE выделить все жанры фильмов, имеющиеся в таблице movies (каждый жанр в отдельной строке)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "with recursive getGenres(genres, genre) as (
    select movies.genres as genres, '' as genre from movies
    union all
    select substr(genres, instr(genres, '|') + 1, length(genres)) as genre,
           substr(genres, 1, instr(genres, '|') - 1) as genre
    from getGenres
    where instr(genres, '|') > 0
)
select distinct getGenres.genre as genres from getGenres
where getGenres.genre <> '';"
echo " "
