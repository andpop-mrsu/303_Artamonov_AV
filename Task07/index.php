<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Данные студентов</title>
</head>
<body>

<?php
$pdo = new PDO('sqlite:students.db');

$queryStart = <<<QUERY_START
select distinct groupNumber
from students;
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
select id, 
       groupNumber,
       direction,
       surname,
       firstName,
       secondName,
       sex,
       birthdate,
       ticketNumber
from students
order by students.groupNumber, students.surname;
QUERY;
} else {
    $query = <<<QUERY
select id, 
       groupNumber,
       direction,
       surname,
       firstName,
       secondName,
       sex,
       birthdate,
       ticketNumber
from students 
where students.groupNumber = {$groupNumber}
order by students.groupNumber, students.surname;
QUERY;
}

$statement = $pdo->query($query);
$students = $statement->fetchAll();
?>
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
        </tr>
    <?php endforeach; ?>

</table>
</body>
</html>