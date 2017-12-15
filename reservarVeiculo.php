<?php
    require_once 'startup.php';

    $dataRetirar = $_GET['dataRetirar'];
    $dataDevolver = $_GET['dataDevolver'];

    $sqlClientes = "SELECT id,nome FROM clientes";
    $sqlFuncionarios = "SELECT matricula,nome FROM funcionarios";

    if(isset($_POST['reservar'])){

        $sqlReservar = "SELECT alugarVeiculo(:Cliente,:Veiculo,:Funcionario,:dataRetirar,:dataDevolver)";
        $stmt = $conn->prepare($sqlReservar);
        $stmt->execute(array(
            ':Cliente' => $_POST['cliente'],
            ':Veiculo' => $_POST['veiculo'],
            ':Funcionario' => $_POST['funcionario'],
            ':dataRetirar' => $_POST['dataRetirar'],
            ':dataDevolver' => $_POST['dataDevolver']
        ));
        $fetch = $stmt->fetchAll();
        $msg = $fetch[0]['alugarveiculo'];

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
    <h1>Locacar - Locadora de Veículos | Reservar Veículo</h1>
    
    <ul>
        <li><a href="index.php">Início</a></li>
        <li><a href="cadastrarCliente.php">Cadastrar Novo Cliente</a></li>
        <li><a href="cadastrarFuncionario.php">Cadastrar Novo Funcionário</a></li>
    </ul>

    <?php if($msg) { echo "<strong>{$msg}</strong><br><br>"; }?>

    <form method="post">
        <div><label>Cliente: <select name="cliente">
            <option value="0">--selecione--</option>
            <?php foreach($conn->query($sqlClientes) as $cliente){
                ?>
                    <option value="<?=$cliente['id']?>"><?=$cliente['nome']?></option>
                <?php
            } ?>
        </select></label></div>
        <div><label>Funcionário: <select name="funcionario">
            <option value="0">--selecione--</option>
            <?php foreach($conn->query($sqlFuncionarios) as $funcionario){
                ?>
                    <option value="<?=$funcionario['matricula']?>"><?=$funcionario['nome']?></option>
                <?php
            } ?>
        </select></label></div>
        <input type="hidden" name="veiculo" value="<?=$_GET['veiculo']?>">
        <input type="hidden" name="dataRetirar" value="<?=$_GET['dataRetirar']?>">
        <input type="hidden" name="dataDevolver" value="<?=$_GET['dataDevolver']?>">
        <div><input type="submit" value="Reservar" name="reservar"></div>
    </form>

</body>
</html>