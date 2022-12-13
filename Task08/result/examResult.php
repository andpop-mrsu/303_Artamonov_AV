<?php

$studentTicket = $_GET['id'];
$pdo = new PDO('sqlite:../students.db');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $studentTicket = $_POST['studentTicket'];
    header("Location: examResult.php?id=$studentTicket");

    $pdo = new PDO('sqlite:../students.db');

    $queryStart = <<<QUERY
select subjects.subjectName    as subjectName,
       subjects.id             as subjectId,
       studentResults.points   as points,
       studentResults.mark     as mark,
       students.studentTicket  as studentTicket,
       students.id             as id,
       groupSubjects.id        as groupSubjectId
from studentResults
         inner join students on students.id = studentResults.studentId
         inner join groupSubjects on groupSubjects.id = studentResults.groupSubjectId
         inner join educationalDirectionsSubjects
                    on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
         inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
where students.studentTicket = {$studentTicket} and groupSubjects.isExam = true;
QUERY;
    $statement = $pdo->query($queryStart);
    $subjects = $statement->fetchAll();
    $statement->closeCursor();

    foreach ($subjects as $subject) {
        $mark = 0;
        if ($subject["points"] > 85) {
            $mark = 5;
        } else if ($subject["points"] > 70) {
            $mark = 4;
        } else if ($subject["points"] > 50) {
            $mark = 3;
        } else {
            $mark = 2;
        }

        $sql = "update studentResults set mark=? where studentId=? and groupSubjectId=?;";
        $statement = $pdo->prepare($sql);
        $statement->execute(
            [
                $mark,
                $subject['id'],
                $subject['groupSubjectId'],
            ]
        );
        $statement->closeCursor();
    }
    exit();
}

$queryStart = <<<QUERY
select subjects.subjectName    as subjectName,
       subjects.id             as subjectId,
       studentResults.points   as points,
       studentResults.mark     as mark,
       students.studentTicket  as studentTicket
from studentResults
         inner join students on students.id = studentResults.studentId
         inner join groupSubjects on groupSubjects.id = studentResults.groupSubjectId
         inner join educationalDirectionsSubjects
                    on educationalDirectionsSubjects.id = groupSubjects.educationalDirectionSubjectId
         inner join subjects on subjects.id = educationalDirectionsSubjects.subjectId
where students.studentTicket = {$studentTicket} and groupSubjects.isExam = true;
QUERY;
$statement = $pdo->query($queryStart);
$results = $statement->fetchAll();
$statement->closeCursor();

$query = <<<QUERY
select students.id                         as id,
       groups.id                           as groupId,
       educationalDirections.directionName as direction,
       students.surname                    as surname,
       students.firstName                  as firstName,
       students.secondName                 as secondName,
       genders.id                          as genderId,
       students.birthdate                  as birthdate,
       students.studentTicket              as studentTicket

from students
         inner join groups on groups.id = students.groupId
         inner join educationalDirections on educationalDirections.id = groups.educationDirectionId
         inner join genders on genders.id = students.genderId
where students.studentTicket = {$studentTicket};
QUERY;
$statement = $pdo->query($query);
$studentMap = $statement->fetchAll();
?>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Результаты экзаменов</title>
    </head>
    <body>
        Номер студенческого: <?= $studentMap[0]['studentTicket'] ?><br>
        Фамилия: <?= $studentMap[0]['surname'] ?><br>
        Имя: <?= $studentMap[0]['firstName'] ?><br>
        Отчество: <?= $studentMap[0]['secondName'] ?><br>

        <table class="studentTable" cellpadding="7" cellspacing="0" border="1" width="100%">
            <tr class="studentTable">
                <th>Предмет</th>
                <th>Баллы</th>
                <th>Оценка</th>
                <th></th>
            </tr>
            <?php foreach ($results as $result): ?>
                <tr>
                    <td><?= $result['subjectName'] ?></td>
                    <td><?= $result['points'] ?></td>
                    <td><?= $result['mark'] ?></td>
                    <td>
                        <form action="updatePoints.php" method="GET">
                            <input type="hidden" name="studentTicket" value=<?= $result['studentTicket'] ?>>
                            <input type="hidden" name="subjectId" value=<?= $result['subjectId'] ?>>
                            <input type="submit" value="Изменить баллы">
                        </form>
                    </td>
                </tr>
            <?php endforeach; ?>
        </table>
        <form action="examResult.php" method="POST">
            <input type="hidden" name="studentTicket" value=<?= $studentMap[0]['studentTicket'] ?>>
            <input type="submit" value="Выставить оценки за экзамены">
        </form>
        <a href="../index.php">Назад</a>
    </body>
</html>

