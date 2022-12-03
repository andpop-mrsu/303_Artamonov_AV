## Лабораторная работа 7. Сценарии PHP. Разработка консольного и веб-приложения для отображения данных из БД.

### Задание.
1. С помощью консольного PHP-сценария task7_cli.php подключиться к базе данных и сформировать список студентов из всех действующих групп (год окончания обучения не больше текущего года). Список выводить в табличном виде (номер группы, направление подготовки, ФИО, пол, дата рождения, номер студенческого билета), таблицу вывести с помощью псевдографики. Информация должна быть отсортирована по номеру группы и фамилиям студентов.  
Реализовать возможность фильтрации списка студентов по всем имеющимся в базе данных номерам действующих групп (эти номера взять именно из базы, а не задавать явно в тексте программы!). При запуске программа должна вывести все имеющиеся в базе номера групп, пользователь должен ввести нужный номер с клавиатуры, либо нажать Enter для вывода информации по всем группам. Не забудьте про валидацию вводимого номера.

2. Выполнить ту же задачу в виде веб-приложения: список студентов должен быть оформлен в виде HTML-страницы, 
номер группы для фильтрации должен выбираться из раскрывающегося списка. Страницу сформировать с помощью скрипта index.php в режиме шаблонизатора (без `echo`) с использованием альтернативного синтаксиса PHP.

* * *
### Требования к оформлению и коду
* Работать нужно в ветке Task07 Git-репозитория.
* Осмысленное именование сущностей (на английском языке).
* К БД подключаться с помощью PDO, использовать подготовленные запросы.
* Для отладки веб-приложения использовать локальный сервер, встроенный в PHP.

* * *

### Отправка задания на проверку
Процедура отправки задания на проверку и манипуляции с репозиториями после проверки описаны в файле [Git_instruction.md](Git_instruction.md).

* * *
### Лекции
* Консольные приложения на PHP. https://youtu.be/UGU_TiZnrkM
* Frontend и backend. Веб-приложения на PHP. https://youtu.be/nngT3DShFF4