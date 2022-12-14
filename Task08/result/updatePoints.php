<?php

$studentTicket = $_GET['studentTicket'];
$subjectId = $_GET['subjectId'];
$pdo = new PDO('sqlite:../data/students.db');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $studentTicket = $_POST['studentTicket'];
    header("Location: examResult.php?id=$studentTicket");

    $pdo = new PDO('sqlite:../data/students.db');
    $sql = "update studentResults set points=? where studentId=? and groupSubjectId=?;";
    $statement = $pdo->prepare($sql);
    $statement->execute(
        [
            $_POST['points'],
            $_POST['id'],
            $_POST['groupSubjectId'],
        ]
    );

    $statement->closeCursor();
    exit();
}

$query = <<<QUERY
select students.id                         as id,
       groups.id                           as groupId,
       educationalDirections.directionName as direction,
       students.surname                    as surname,
       students.firstName                  as firstName,
       students.secondName                 as secondName,
       genders.id                          as genderId,
       students.birthdate                  as birthdate,
       students.studentTicket              as studentTicket,
       subjects.subjectName                as subjectName,
       studentResults.points               as points,
       groupSubjects.id                    as groupSubjectId
from students
         inner join groups on groups.id = students.groupId
         inner join educationalDirections on educationalDirections.id = groups.educationDirectionId
         inner join genders on genders.id = students.genderId
         inner join studentResults on studentResults.studentId = students.id
         inner join groupSubjects on groupSubjects.id = studentResults.groupSubjectId
         inner join educationalDirectionsSubjects
                    on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
         inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
where students.studentTicket = {$studentTicket} and subjects.id = {$subjectId};
QUERY;
$statement = $pdo->query($query);
$studentMap = $statement->fetchAll();
?>

<html>
<head>
    <meta charset="UTF-8">
    <title>UpdatePoints</title>
</head>
<body>
<h3>Измените данные экзамена студента</h3>
<form action="updatePoints.php" method="POST">
    <input type="hidden" name="studentTicket" value=<?= $studentMap[0]['studentTicket'] ?>>
    <input type="hidden" name="id" value=<?= $studentMap[0]['id'] ?>>
    <input type="hidden" name="groupSubjectId" value=<?= $studentMap[0]['groupSubjectId'] ?>>
    Номер студенческого: <?= $studentMap[0]['studentTicket'] ?><br>
    Фамилия: <?= $studentMap[0]['surname'] ?><br>
    Имя: <?= $studentMap[0]['firstName'] ?><br>
    Отчество: <?= $studentMap[0]['secondName'] ?><br>
    Предмет: <?= $studentMap[0]['subjectName'] ?><br>
    Баллы: <input type="text" name="points" value=<?= $studentMap[0]['points'] ?>><br>
    <input type="submit" value="Изменить"><br>
</form>
<a href="examResult.php?id=<?= $studentTicket ?>">Назад</a>
</body>
</html>