<?php
header('Location: ../index.php');

$pdo = new PDO('sqlite:../students.db');
$sql = "delete from students where studentTicket=?;";
$statement = $pdo->prepare($sql);
$statement->execute([$_GET['id']]);
$statement->closeCursor();
