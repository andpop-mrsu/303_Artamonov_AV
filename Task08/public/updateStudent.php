<?php

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    header('Location: index.php');

    $pdo = new PDO('sqlite:../data/students.db');
    $sql = "update students set surname=?, firstName=?, secondName=?, genderId=?, groupId=?, birthdate=? where studentTicket=?;";
    $statement = $pdo->prepare($sql);
    $statement->execute(
        [
            $_POST['surname'],
            $_POST['firstName'],
            $_POST['secondName'],
            $_POST['genderId'],
            $_POST['groupId'],
            $_POST['birthdate'],
            $_POST['studentTicket']
        ]
    );

    $statement->closeCursor();
    exit();
}

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


$studentNumber = $_GET['id'];

$query = <<<QUERY
select students.id                         as id,
       groups.id                           as groupId,
       educationalDirections.directionName as direction,
       students.surname                    as surname,
       students.firstName                  as firstName,
       students.secondName                 as secondName,
       genders.id                  as genderId,
       students.birthdate                  as birthdate,
       students.studentTicket              as studentTicket

from students
         inner join groups on groups.id = students.groupId
         inner join educationalDirections on educationalDirections.id = groups.educationDirectionId
         inner join genders on genders.id = students.genderId
where students.studentTicket = {$studentNumber};
QUERY;

$statement = $pdo->query($query);
$studentMap = $statement->fetchAll();
?>

<html>
<head>
    <meta charset="UTF-8">
    <title>CreateStudent</title>
</head>
<body>
<h3>Измените данные студента</h3>
<form action="updateStudent.php" method="POST">
    Номер студенческого: <?= $studentMap[0]['studentTicket'] ?><br>
    <input type="hidden" name="studentTicket" value=<?= $studentMap[0]['studentTicket'] ?>>
    Фамилия: <input type="text" name="surname" value=<?= $studentMap[0]['surname'] ?>><br>
    Имя: <input type="text" name="firstName" value=<?= $studentMap[0]['firstName'] ?>><br>
    Отчество: <input type="text" name="secondName" value=<?= $studentMap[0]['secondName'] ?>><br>
    Пол:
    <?php if ($studentMap[0]['genderId'] === 1) { ?>
        <input type="radio" value=1 name="genderId" checked="checked">парень
        <input type="radio" value=2 name="genderId">девушка<br>
    <?php } else { ?>
        <input type="radio" value=1 name="genderId">парень
        <input type="radio" value=2 name="genderId" checked="checked">девушка<br>
    <?php } ?>
    Группа
    <select name="groupId">
        <?php foreach ($groups as $group) { ?>
            <?php if ($group['id'] === $studentMap[0]['groupId']) { ?>
                <option selected="selected" value= <?= $group['id'] ?>>
                    <?= $group['groupNumber'] ?>
                </option>
            <?php } else { ?>
                <option value= <?= $group['id'] ?>>
                    <?= $group['groupNumber'] ?>
                </option>
            <?php } ?>
        <?php } ?>
        <input type="date" name="birthdate" value=<?= $studentMap[0]['birthdate'] ?>>
    </select>
    <input type="submit" value="Изменить">
</form>
<a href="index.php">Назад</a>
</body>
</html>
