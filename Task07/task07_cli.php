<?php

$pdo = new PDO('sqlite:students.db');

$queryStart = "select distinct groupNumber from students;";
$statement = $pdo->query($queryStart);
$students = $statement->fetchAll();

echo "Список групп студентов:\n";
foreach ($students as $student) {
    echo $student['groupNumber'] . "\n";
}
$statement->closeCursor();

echo "-------------------------------------\n";

$groupNumber = readline("Введите номер группы: ");

if ($groupNumber == "") {
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
    $statement = $pdo->query($query);
    $students = $statement->fetchAll();

    foreach ($students as $student) {
        echo $student['id'] . ' ' . $student['groupNumber'] . ' ' . $student['direction'] . ' ' . $student['surname'] . ' ' . $student['firstName'] . ' ' . $student['secondName'] . ' ' . $student['sex'] . ' ' . $student['birthdate'] . ' ' . $student['ticketNumber'] ."\n";
    }
    exit(0);
}

$isExisting = false;
foreach ($students as $student) {
    if ($student['groupNumber'] == $groupNumber) {
        $isExisting = true;
    }
}

if (!$isExisting) echo "Введен некоректный номер группы\n";
else {
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
    $statement = $pdo->query($query);
    $students = $statement->fetchAll();
    if (count($students) > 0) {
        foreach ($students as $student) {
            echo $student['id'] . ' ' . $student['groupNumber'] . ' ' . $student['direction'] . ' ' . $student['surname'] . ' ' . $student['firstName'] . ' ' . $student['secondName'] . ' ' . $student['sex'] . ' ' . $student['birthdate'] . ' ' . $student['ticketNumber'] ."\n";        }
    } else {
        echo 'Студентов в группе ' . $groupNumber . ' пока нет.' . "\n";
    }

}
?>