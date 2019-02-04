<?php

$db = mysqli_connect("127.0.0.1", "root", "root", "ephp_mysql");

if (!$db) {
    echo "Error: Cannot connect to MySQL." . PHP_EOL;
    echo "debug errno: " . mysqli_connect_errno() . PHP_EOL;
    echo "debug error: " . mysqli_connect_error() . PHP_EOL;
    exit;
}

echo "Success: Properly connected to MySQL!" . PHP_EOL;
echo "Host info: " . mysqli_get_host_info($db) . PHP_EOL;

mysqli_close($db);
