<?php

$pdo = new PDO('sqlite:../data/students.db');
$queryStart = <<<QUERY_START
select case
           when cast(strftime('%Y', date('now')) as integer) - groups.registrationYear + 1 <= 4
               then (cast(strftime('%Y', date('now')) as integer) -
                     groups.registrationYear + 1) * 100 + groups.groupNum
           else 400 + groups.registrationYear
           end as groupNumber, 
       groups.id as id
from groups;
QUERY_START;
$statement = $pdo->query($queryStart);
$groups = $statement->fetchAll();
$statement->closeCursor();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    header('Location: ../public/index.php');

    $sql = <<<SQL
insert into students (studentTicket, surname, firstName, secondName, birthdate, genderId, groupId)
values (?, ?, ?, ?, ?, ?, ?);
SQL;
    $statement = $pdo->prepare($sql);
    $statement->execute(
        [
            $_POST['studentTicket'],
            $_POST['surname'],
            $_POST['firstName'],
            $_POST['secondName'],
            $_POST['birthdate'],
            $_POST['genderId'],
            $_POST['groupId'],
        ]
    );
    $statement->closeCursor();

    $sql = <<<SQL
insert into studentResults (studentId, groupSubjectId, points, isPassed, mark)
select students.id as studentId,
       groupSubjects.id as groupSubjectId,
       0 as points,
       null as isPassed,
       null as mark
from students
inner join groupSubjects on groupSubjects.groupId = students.groupId
where students.studentTicket = ?;
SQL;
    $statement = $pdo->prepare($sql);
    $statement->execute(
        [
            $_POST['studentTicket'],
        ]
    );
    $statement->closeCursor();
    exit();
}
?>

<html>
<head>
    <meta charset="UTF-8">
    <title>CreateStudent</title>
</head>
<body>
<h3>Введите новые данные</h3>
<form action="" method="POST">
    Номер студенческого: <input type="text" name="studentTicket" required><br>
    Фамилия: <input type="text" name="surname" required><br>
    Имя: <input type="text" name="firstName" required><br>
    Отчество: <input type="text" name="secondName"><br>
    Пол:
    <input type="radio" value=1 name="genderId" checked="checked">парень
    <input type="radio" value=2 name="genderId">девушка<br>
    Группа
    <select name="groupId">
        <?php foreach ($groups as $student) { ?>
            <option value= <?= $student['id'] ?>>
                <?= $student['groupNumber'] ?>
            </option>
        <?php } ?>
        <input type="date" name="birthdate" required>
    </select>
    <input type="submit" value="Добавить">
</form>
<a href="../public/index.php">Назад</a>
</body>
</html>
