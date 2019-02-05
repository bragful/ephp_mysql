<?php

$db = mysqli_connect("127.0.0.1", "root", "root", "ephp_mysql");
$res = mysqli_query($db, "SELECT 100");
var_dump($res);
var_dump(mysqli_fetch_all($res, MYSQLI_NUM));
mysqli_data_seek($res, 0);
var_dump(mysqli_fetch_all($res, MYSQLI_ASSOC));
mysqli_data_seek($res, 0);
var_dump(mysqli_fetch_all($res, MYSQLI_BOTH));
mysqli_close($db);
