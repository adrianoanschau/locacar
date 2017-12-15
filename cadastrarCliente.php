<?php

    require_once 'startup.php';

    if(isset($_POST['cadastrar'])){

        $sql = "SELECT cadastrarCliente('{$_POST['nome']}','{$_POST['cpf']}','{$_POST['telefone']}')";
        $stmt = $conn->prepare($sql);
        $stmt->execute();
        $msg = $stmt->fetchAll()[0]['cadastrarcliente'];

    }

?>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <title>Locacar - Locadora de Veículos</title>
    <meta charset="utf-8">
    <style>
        table{ width:800px;border:1px solid black }
        table tr td{ border:1px solid gray }
    </style>
</head>
<body>
    <h1>Locacar - Locadora de Veículos | Cadastro de Cliente</h1>
    
    <ul>
        <li><a href="index.php">Início</a></li>
    </ul>

    <?php if($msg) { echo "<strong>{$msg}</strong><br><br>"; }?>

    <form method="post">
        <div><label>Nome: <input type="text" name="nome"></div>
        <div><label>CPF: <input type="text" name="cpf">(somente números - 14 dígitos)</div>
        <div><label>Telefone: <input type="text" name="telefone">(somente números - 11 dígitos)</div>
        <div><input type="submit" value="Salvar" name="cadastrar"></div>
    </form>
</body>
</html>