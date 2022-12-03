## Лабораторная работа 8. Сценарии PHP. Разработка CRUD-приложения для работы с БД

### Задание.
Создать веб-приложение для ввода, сохранения в базе данных и вывода информации о составе групп и сданных экзаменах.

На стартовой странице приложения должен выводиться список всех студентов c сортировкой по номеру группы и фамилии, также должна быть реализована фильтрация по номеру группы. 	
Для каждой записи в этом списке нужно добавить:
* Кнопки/ссылки "Редактировать" и "Удалить", при нажатии на которые будет открываться форма для изменения персональных данных студента или форма с запросом на удаление данной записи.
* Кнопку "Результаты экзаменов", при нажатии на которую будет открываться список с результатами всех экзаменов (в хронологическом порядке), которые сдавал этот студент. В этом списке также должны быть кнопки для выполнения операций CRUD.
* Внизу списка студентов разместить кнопку "Добавить", вызывающую форму для ввода новой записи.
* В форме ввода данных о студентах номер группы выбирать из раскрывающегося списка всех возможных вариантов (справочник с номерами групп должен быть заполнен в базе данных заранее), пол устанавливать с помощью переключателя.
* В форме ввода данных по сданным экзаменам номер группы, фамилии студентов и названия дисциплин должны выбираться из раскрывающихся списков, содержимое которых заполняется из базы данных. Реализовать возможность ввода результатов экзаменов задним числом, за любой курс, на котором ранее учился студент. Названия дисциплин в списке для выбора должны соответствовать учебному направлению студента и его году обучения на момент сдачи экзамена.

* * *
### Требования к оформлению и коду
* Работать нужно в ветке Task08 Git-репозитория, в каталоге Task08.
* Корень сайта должен быть в каталоге Task08/public.
* Ссылки для открытия форм поместить в файл Task08/public/index.php.
* Файл с базой данных разместить в каталоге Task08/data.

* * *

### Отправка задания на проверку
Процедура отправки задания на проверку и манипуляции с репозиториями после проверки описаны в файле [Git_instruction.md](Git_instruction.md).

* * *
### Лекции
* Frontend и backend. Веб-приложения на PHP. https://youtu.be/nngT3DShFF4
* Веб-приложения на PHP. Часть 2. https://youtu.be/z3lmJndVIho?list=PLicf0S1Y1CXvXyOxJ1YoVH034LjvSCeG8