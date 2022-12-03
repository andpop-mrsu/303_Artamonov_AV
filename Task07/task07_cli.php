<?php

$pdo = new PDO('sqlite:students.db');

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

echo "Список групп студентов:\n";
foreach ($students as $student) {
    echo $student['groupNumber'] . "\n";
}
$statement->closeCursor();

echo "-------------------------------------\n";

$groupNumber = readline("Введите номер группы: ");

if ($groupNumber == "") {
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