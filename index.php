<?php

require_once 'startup.php';

$stmt = $conn->prepare('SELECT * FROM veiculos WHERE id=:id;');
$stmt->execute(array(':id'=>1));

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
    
    <h1>Locacar - Locadora de Veículos</h1>
    
    <ul>
        <li>Reservas</li>
        <li><a href="?veiculosDisponiveis">Veículos Disponíveis</a></li>
        <li><a href="?reservasDoDia">Ver Reservas do Dia</a></li>
        <li><a href="?reservasProximas">Ver Reservas Próximas</a></li>
        <br>
        <li>Cadastro</li>
        <li><a href="cadastrarCliente.php">Novo Cliente</a></li>
        <li><a href="cadastrarFuncionario.php">Novo Funcionário</a></li>
        <br>
        <li>Financeiro</li>
        <li><a href="?contasParaReceber">Contas Para Receber</a></li>
        <li><a href="?contasParaPagar">Contas Para Pagar</a></li>
    </ul>
    
        <?php if(isset($_GET['reservasDoDia'])){ ?>
                <h4>Reservas com Data de Retirada marcada para hoje (<?=date('d/m/Y')?>)</h4>
                <table>
                <thead>
                    <tr>
                        <th>Cliente</th>
                        <th>Veículo</th>
                        <th>Placa</th>
                        <th>Finalidade</th>
                        <th>Data Retirada</th>
                        <th>Data Devolução</th>
                    </tr>
                </thead>
                <tbody>
                <?php foreach($conn->query("SELECT * FROM reservasDoDia") as $row){ ?>
                    <tr>
                        <td><?=$row['cliente']?></td>
                        <td><?=$row['veiculo']?></td>
                        <td><?=$row['placa']?></td>
                        <td><?=$row['finalidade']?></td>
                        <td><?=$row['dataretirada']?></td>
                        <td><?=$row['datadevolucao']?></td>
                    </tr>
                <?php } ?>
                </tbody>
            </table>
        <?php } ?>
        
            <?php if(isset($_GET['reservasProximas'])){ ?>
                    <h4>Reservas com Data de Retirada marcada para a partir de amanhã (<?=date('d/m/Y',strtotime('+1 day'))?>)</h4>
                    <table>
                    <thead>
                        <tr>
                            <th>Cliente</th>
                            <th>Veículo</th>
                            <th>Placa</th>
                            <th>Finalidade</th>
                            <th>Data Retirada</th>
                            <th>Data Devolução</th>
                        </tr>
                    </thead>
                    <tbody>
                    <?php foreach($conn->query("SELECT * FROM reservasProximas") as $row){ ?>
                        <tr>
                            <td><?=$row['cliente']?></td>
                            <td><?=$row['veiculo']?></td>
                            <td><?=$row['placa']?></td>
                            <td><?=$row['finalidade']?></td>
                            <td><?=$row['dataretirada']?></td>
                            <td><?=$row['datadevolucao']?></td>
                        </tr>
                    <?php } ?>
                    </tbody>
                </table>
            <?php } ?>

        <?php if(isset($_GET['veiculosDisponiveis'])){
            $hoje = date('Y-m-d');
            $dataRetirar = ($_POST['dataRetirar'])?$_POST['dataRetirar']:$hoje;
            $dataDevolver = ($_POST['dataDevolver'])?$_POST['dataDevolver']:$hoje;
            ?>
            <form method="post">
                <div><label>Data para Retirar: <input type="date" name="dataRetirar" value="<?=$dataRetirar?>"></label></div>
                <div><label>Data para Devolver: <input type="date" name="dataDevolver" value="<?=$dataDevolver?>"></label></div>
                <div><input type="submit" value="Consultar" name="consultar"></div>
            </form>
            <?php

                if(isset($_POST['consultar'])){

                    $sql = "SELECT * FROM getVeiculosDisponiveis('{$_POST['dataRetirar']}','{$_POST['dataDevolver']}');";

                ?>
                <h4>Veículos Disponíveis de <u><?=date('d/m/Y',strtotime($_POST['dataRetirar']))?></u> a <u><?=date('d/m/Y',strtotime($_POST['dataDevolver']))?></u></h4>
                <table>
                    <thead>
                        <tr>
                            <th>Veículo</th>
                            <th>Marca</th>
                            <th>Categoria</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                    <?php foreach($conn->query($sql) as $row){ ?>
                        <tr>
                            <td><?=$row['veiculo']?></td>
                            <td><?=$row['marca']?></td>
                            <td><?=$row['categoria']?></td>
                            <td><a href="reservarVeiculo.php?veiculo=<?=$row['id']?>&dataRetirar=<?=$_POST['dataRetirar']?>&dataDevolver=<?=$_POST['dataDevolver']?>">Reservar</a></td>
                        </tr>
                    <?php } ?>
                    </tbody>
                </table>
            <?php } ?>
    <?php } ?>
    
    
        <?php if(isset($_GET['contasParaReceber'])){ ?>
            <h4>Contas em Aberto à Receber</h4>
            <table>
            <thead>
                <tr>
                    <th>Cliente</th>
                    <th>Veículo</th>
                    <th>Funcionário</th>
                    <th>Finalidade</th>
                    <th>Descrição</th>
                    <th>Valor</th>
                    <th>Código Barras</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
            <?php foreach($conn->query("SELECT * FROM contasParaReceber") as $row){ ?>
                <tr>
                    <td><?=$row['cliente']?></td>
                    <td><?=$row['veiculo']?></td>
                    <td><?=$row['funcionario']?></td>
                    <td><?=$row['finalidade']?></td>
                    <td><?=$row['descricao']?></td>
                    <td><?=$row['valor']?></td>
                    <td><?=$row['codigo_barras']?></td>
                    <td><a href="?receberPagamento=<?=$row['codigo_barras']?>">Receber Pagamento</a></td>
                </tr>
            <?php } ?>
            </tbody>
            </table>
        <?php } ?>


    <?php if(isset($_GET['contasParaPagar'])){ ?>
        <h4>Contas em Aberto à Pagar</h4>
        <table>
        <thead>
            <tr>
                <th>Cliente</th>
                <th>Veículo</th>
                <th>Funcionário</th>
                <th>Finalidade</th>
                <th>Descrição</th>
                <th>Valor</th>
                <th>Código Barras</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
        <?php foreach($conn->query("SELECT * FROM contasParaPagar") as $row){ ?>
            <tr>
                <td><?=$row['cliente']?></td>
                <td><?=$row['veiculo']?></td>
                <td><?=$row['funcionario']?></td>
                <td><?=$row['finalidade']?></td>
                <td><?=$row['descricao']?></td>
                <td><?=$row['valor']?></td>
                <td><?=$row['codigo_barras']?></td>
                <td><a href="?fazerPagamento=<?=$row['codigo_barras']?>">Fazer Pagamento</a></td>
            </tr>
        <?php } ?>
        </tbody>
        </table>
    <?php } ?>

    <?php if(isset($_GET['receberPagamento'])){
        $sql = "SELECT receberPagamento('{$_GET['receberPagamento']}')";
        $stmt = $conn->prepare($sql);
        $stmt->execute();
        
        if($stmt->fetchAll()[0]['receberpagamento']){
            echo "<strong>Pagamento recebido.</strong>";
        } else {
            echo "<strong>Houve um erro para receber o pagamento.</strong>";
        }
        
    } ?>
    
    <?php if(isset($_GET['fazerPagamento'])){
        $sql = "SELECT fazerPagamento('{$_GET['fazerPagamento']}')";
        $stmt = $conn->prepare($sql);
        $stmt->execute();
        
        if($stmt->fetchAll()[0]['fazerpagamento']){
            echo "<strong>Pagamento realizado.</strong>";
        } else {
            echo "<strong>Houve um erro para fazer o pagamento.</strong>";
        }
        
    } ?>

</body>
</html>