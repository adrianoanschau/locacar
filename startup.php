<?php

date_default_timezone_set('America/Sao_Paulo');

require_once 'conexao.php';

define('DB_HOST','localhost');
define('DB_NAME','locadora');
define('DB_USER','postgres');
define('DB_PASS','123456');
define('DB_DRIVER','pgsql');

$conn = Database::conexao();