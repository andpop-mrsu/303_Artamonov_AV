<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Данные студентов</title>
</head>
<body>

<?php
$pdo = new PDO('sqlite:../data/students.db');

$queryStart = <<<QUERY_START
select case
           when cast(strftime('%Y', date('now')) as integer) - groups.registrationYear + 1 <= 4
               then (cast(strftime('%Y', date('now')) as integer) -
                     groups.registrationYear + 1) * 100 + groups.groupNum
           else 400 + groups.registrationYear
           end as groupNumber
from groups;
QUERY_START;
$statement = $pdo->query($queryStart);
$students = $statement->fetchAll();
$statement->closeCursor();
?>

<h1>Выбрать студентов по номеру группы</h1>
<form action="" method="POST">
    <label>
        <select style="width: 200px;" name="groupNumber">
            <option value=<?= null ?>>
                All
            </option>
            <?php foreach ($students as $student) { ?>
                <option value= <?= $student['groupNumber'] ?>>
                    <?= $student['groupNumber'] ?>
                </option>
            <?php } ?>
        </select>
    </label>
    <button type="submit">Поиск по номеру группы</button>
</form>

<?php
$groupNumber = 0;
if (isset($_POST['groupNumber'])) {
    $groupNumber = (int)$_POST['groupNumber'];
}

$students = null;

if ($groupNumber == 0) {
    $query = <<<QUERY
select students.id                         as id,
       case
           when cast(strftime('%Y', date('now')) as integer) - groups.registrationYear + 1 <= 4
               then (cast(strftime('%Y', date('now')) as integer) -
                     groups.registrationYear + 1) * 100 + groups.groupNum
           else 400 + groups.registrationYear
           end                             as groupNumber,
       educationalDirections.directionName as direction,
       students.surname                    as surname,
       students.firstName                  as firstName,
       students.secondName                 as secondName,
       genders.genderName                  as sex,
       students.birthdate                  as birthdate,
       students.studentTicket              as ticketNumber

from students
         inner join groups on groups.id = students.groupId
         inner join educationalDirections on educationalDirections.id = groups.educationDirectionId
         inner join genders on genders.id = students.genderId
order by case
           when cast(strftime('%Y', date('now')) as integer) - groups.registrationYear + 1 <= 4
               then (cast(strftime('%Y', date('now')) as integer) -
                     groups.registrationYear + 1) * 100 + groups.groupNum
           else 400 + groups.registrationYear
           end, students.surname;
QUERY;
} else {
    $query = <<<QUERY
select students.id                         as id,
       case
           when cast(strftime('%Y', date('now')) as integer) - groups.registrationYear + 1 <= 4
               then (cast(strftime('%Y', date('now')) as integer) -
                     groups.registrationYear + 1) * 100 + groups.groupNum
           else 400 + groups.registrationYear
           end                             as groupNumber,
       educationalDirections.directionName as direction,
       students.surname                    as surname,
       students.firstName                  as firstName,
       students.secondName                 as secondName,
       genders.genderName                  as sex,
       students.birthdate                  as birthdate,
       students.studentTicket              as ticketNumber

from students
         inner join groups on groups.id = students.groupId
         inner join educationalDirections on educationalDirections.id = groups.educationDirectionId
         inner join genders on genders.id = students.genderId
where case
           when cast(strftime('%Y', date('now')) as integer) - groups.registrationYear + 1 <= 4
               then (cast(strftime('%Y', date('now')) as integer) -
                     groups.registrationYear + 1) * 100 + groups.groupNum
           else 400 + groups.registrationYear
           end  = {$groupNumber}
order by case
           when cast(strftime('%Y', date('now')) as integer) - groups.registrationYear + 1 <= 4
               then (cast(strftime('%Y', date('now')) as integer) -
                     groups.registrationYear + 1) * 100 + groups.groupNum
           else 400 + groups.registrationYear
           end, students.surname;
QUERY;
}

$statement = $pdo->query($query);
$students = $statement->fetchAll();
?>
<form action="createStudent.php">
    <input type="submit" value="Добавить студента">
</form>
<table class="studentTable" cellpadding="7" cellspacing="0" border="1" width="100%">
    <tr class="studentTable">
        <th>ID</th>
        <th>Номер группы</th>
        <th>Направление</th>
        <th>Фамилия</th>
        <th>Имя</th>
        <th>Отчество</th>
        <th>Пол</th>
        <th>День рождения</th>
        <th>Номер студ. билета</th>
        <th></th>
        <th></th>
        <th></th>
    </tr>
    <?php foreach ($students as $student): ?>
        <tr>
            <td><?= $student['id'] ?></td>
            <td><?= $student['groupNumber'] ?></td>
            <td><?= $student['direction'] ?></td>
            <td><?= $student['surname'] ?></td>
            <td><?= $student['firstName'] ?></td>
            <td><?= $student['secondName'] ?></td>
            <td><?= $student['sex'] ?></td>
            <td><?= $student['birthdate'] ?></td>
            <td><?= $student['ticketNumber'] ?></td>
            <td>
                <form action="./updateStudent.php" method="GET">
                    <input type="hidden" name="id" value=<?= $student['ticketNumber'] ?>>
                    <input type="submit" value="Изменить">
                </form>
            </td>
            <td>
                <form action="./deleteStudent.php" method="GET">
                    <input type="hidden" name="id" value=<?= $student['ticketNumber'] ?>>
                    <input type="submit" value="Удалить">
                </form>
            </td>
            <td>
                <form action="./examResult.php" method="GET">
                    <input type="hidden" name="id" value=<?= $student['ticketNumber'] ?>>
                    <input type="submit" value="Результаты">
                </form>
            </td>
        </tr>
    <?php endforeach; ?>
</table>
</body>
</html>