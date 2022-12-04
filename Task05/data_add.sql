insert into users(firstName, secondName, email, genderId, occupationId)
values ('Акайкин', 'Сергей', 'sergey@mail.ru', 2, 2),
       ('Акимова', 'Дарья', 'daria@mail.ru', 1, 2),
       ('Артамонов', 'Алексей', 'alexey@mail.ru', 2, 2),
       ('Бугреева', 'Анна', 'anna@mail.ru', 1, 2),
       ('Венедиктова', 'Яна', 'yana@mail.ru', 1, 2);

insert into movies(title, releaseYear)
values ('Звёздные войны: Скрытая угроза', '1999'),
       ('Звёздные войны: Атака клонов', '2002'),
       ('Звёздные войны: Месть ситхов', '2005');

insert into tags (tagName)
values ('Класс'),
       ('Супер'),
       ('Офигенно');

insert into usersTags (userId, movieId, tagId)
select (select users.id from users where users.email = 'alexey@mail.ru')                    as userId,
       (select movies.id from movies where movies.title = 'Звёздные войны: Скрытая угроза') as movieId,
       (select tags.id from tags where tags.tagName = 'Класс')                              as tagId
union
select (select users.id from users where users.email = 'alexey@mail.ru')                  as userId,
       (select movies.id from movies where movies.title = 'Звёздные войны: Атака клонов') as movieId,
       (select tags.id from tags where tags.tagName = 'Супер')                            as tagId
union
select (select users.id from users where users.email = 'alexey@mail.ru')                  as userId,
       (select movies.id from movies where movies.title = 'Звёздные войны: Месть ситхов') as movieId,
       (select tags.id from tags where tags.tagName = 'Офигенно')                         as tagId;