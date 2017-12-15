CREATE VIEW listagemVeiculos AS SELECT v.id,v.descricao AS Veiculo, m.descricao AS Marca, c.descricao AS Categoria FROM veiculos v
LEFT JOIN marcas m ON m.id = v.marcas_id LEFT JOIN categorias c ON c.id = v.categorias_id;

CREATE VIEW reservasDoDia AS SELECT c.nome AS Cliente,v.descricao AS Veiculo,v.placa AS Placa,rf.descricao AS Finalidade,r.dataRetirada,r.dataDevolucao
	FROM reservas_veiculos r
	LEFT JOIN clientes c ON c.id=r.clientes_id LEFT JOIN reservas_finalidade rf ON rf.id=r.reservas_finalidade_id
	LEFT JOIN veiculos v ON v.id=r.veiculos_id WHERE r.dataRetirada = (NOW())::date ORDER BY r.dataRetirada;

CREATE VIEW reservasProximas AS SELECT c.nome AS Cliente,v.descricao AS Veiculo,v.placa AS Placa,rf.descricao AS Finalidade,r.dataRetirada,r.dataDevolucao
	FROM reservas_veiculos r
	LEFT JOIN clientes c ON c.id=r.clientes_id LEFT JOIN reservas_finalidade rf ON rf.id=r.reservas_finalidade_id
	LEFT JOIN veiculos v ON v.id=r.veiculos_id WHERE r.dataRetirada > (NOW())::date ORDER BY r.dataRetirada LIMIT 10;

CREATE VIEW contasParaReceber AS SELECT
	cr.descricao,cr.codigo_barras,cr.valor,c.nome AS Cliente,v.descricao AS Veiculo,f.nome AS Funcionario,i.descricao AS Finalidade
	FROM contas_a_receber cr
	LEFT JOIN reservas_veiculos r ON r.id=cr.reservas_veiculos_id
	LEFT JOIN clientes c ON c.id=r.clientes_id
	LEFT JOIN veiculos v ON v.id=r.veiculos_id
	LEFT JOIN funcionarios f ON f.id=r.funcionarios_id
	LEFT JOIN reservas_finalidade i ON i.id=r.reservas_finalidade_id
	WHERE cr.pago = false;
CREATE VIEW contasParaPagar AS SELECT
	cp.descricao,cp.codigo_barras,cp.valor,c.nome AS Cliente,v.descricao AS Veiculo,f.nome AS Funcionario,i.descricao AS Finalidade
	FROM contas_a_pagar cp
	LEFT JOIN reservas_veiculos r ON r.id=cp.reservas_veiculos_id
	LEFT JOIN clientes c ON c.id=r.clientes_id
	LEFT JOIN veiculos v ON v.id=r.veiculos_id
	LEFT JOIN funcionarios f ON f.id=r.funcionarios_id
	LEFT JOIN reservas_finalidade i ON i.id=r.reservas_finalidade_id
	WHERE cp.pago = false;

CREATE OR REPLACE FUNCTION veiculoTemReserva(id_veiculo INTEGER, dataRetirar DATE, dataDevolver DATE) RETURNS BOOLEAN AS $$
DECLARE
	reservas INTEGER;
BEGIN
	reservas := 0;
	SELECT COUNT(*) INTO reservas FROM reservas_veiculos r
			WHERE (r.veiculos_id = id_veiculo)
			AND ((dataRetirar BETWEEN r.dataRetirada AND r.dataDevolucao)
			OR (dataDevolver BETWEEN r.dataRetirada AND r.dataDevolucao));
	IF (reservas > 0) THEN
		RETURN TRUE;
	END IF;
	RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getVeiculosDisponiveis
	(dataInicial DATE, dataFinal DATE) RETURNS SETOF listagemVeiculos AS $$
DECLARE
	tem_reserva BOOLEAN;
	veiculo RECORD;
BEGIN
	FOR veiculo IN SELECT * FROM veiculos v WHERE v.ativo = true LOOP
		SELECT veiculoTemReserva(veiculo.id,dataInicial,dataFinal) INTO tem_reserva;
		IF (tem_reserva=FALSE) THEN RETURN QUERY SELECT * FROM listagemVeiculos WHERE id = veiculo.id;
		END IF;
	END LOOP;
	RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION alugarVeiculo(id_cliente INTEGER, id_veiculo INTEGER, matricula_funcionario CHARACTER VARYING(8), dataRetirar DATE, dataDevolver DATE)
	RETURNS CHARACTER VARYING(32) AS $$
DECLARE
	tem_reserva BOOLEAN;
	hash CHARACTER VARYING(32);
	reservaLastId1 INTEGER;
	reservaLastId2 INTEGER;
	id_funcionario INTEGER;
BEGIN
	SELECT veiculoTemReserva(id_veiculo,dataRetirar,dataDevolver) INTO tem_reserva;
	IF tem_reserva=FALSE THEN

		SELECT id INTO id_funcionario FROM funcionarios WHERE matricula = matricula_funcionario LIMIT 1;

		INSERT INTO reservas_veiculos (clientes_id,veiculos_id, funcionarios_id,reservas_finalidade_id,dataRetirada,dataDevolucao)
			VALUES (id_cliente,id_veiculo,id_funcionario,1,dataRetirar,dataDevolver);
		SELECT CURRVAL('reservas_veiculos_id_seq') INTO reservaLastId1;
		SELECT md5(concat(id_veiculo,dataRetirar,dataDevolver)) INTO hash;
		INSERT INTO contas_a_receber (descricao,reservas_veiculos_id,codigo_barras,valor)
			VALUES ('aluguel de veículo',reservaLastId1,hash,150.0);

		INSERT INTO reservas_veiculos (clientes_id,veiculos_id,funcionarios_id,reservas_finalidade_id,dataRetirada,dataDevolucao)
			VALUES (id_cliente,id_veiculo,id_funcionario,2,dataDevolver + interval '1 day',dataDevolver + interval '1 day');
		SELECT CURRVAL('reservas_veiculos_id_seq') INTO reservaLastId2;
		INSERT INTO contas_a_pagar (descricao,reservas_veiculos_id,codigo_barras,valor)
			VALUES ('taxa manutenção preventiva',reservaLastId2,hash,20.0);
			
		RETURN 'A reserva foi realizada com sucesso.';
	END IF;
	RETURN 'Este veículo já possui reserva dentro do período informado.';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cadastrarCliente(cNome CHARACTER VARYING(255),cCpf CHARACTER VARYING(14),cTelefone CHARACTER VARYING(11))
	RETURNS CHARACTER VARYING(16) AS $$
DECLARE
	lastId INTEGER;
BEGIN
	INSERT INTO clientes (nome,cpf,telefone) VALUES (cNome,cCpf,cTelefone);
	SELECT CURRVAL(pg_get_serial_sequence('clientes','id')) INTO lastId;
	RETURN CONCAT('Cliente cadastrado - (id: ',lastId,')');
END;
$$ LANGUAGE plpgsql;

CREATE TYPE clienteIdNome AS (id INTEGER, nome CHARACTER VARYING(255));

CREATE OR REPLACE FUNCTION consultarCliente(cNome CHARACTER VARYING(255))
	RETURNS SETOF clienteIdNome AS $$
BEGIN
	RETURN QUERY SELECT id,nome FROM clientes WHERE nome ILIKE CONCAT('%',cNome,'%');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cadastrarFuncionario(cNome CHARACTER VARYING(255),cMatricula CHARACTER VARYING(8))
	RETURNS CHARACTER VARYING(16) AS $$
DECLARE
	lastId INTEGER;
BEGIN
	INSERT INTO funcionarios (nome,matricula) VALUES (cNome,cMatricula);
	SELECT CURRVAL(pg_get_serial_sequence('funcionarios','id')) INTO lastId;
	RETURN CONCAT('Funcionário cadastrado - (id: ',lastId,')');
END;
$$ LANGUAGE plpgsql;

CREATE TYPE funcionarioMatriculaNome AS (matricula CHARACTER VARYING(8), nome CHARACTER VARYING(255));

CREATE OR REPLACE FUNCTION consultarFuncionario(cNome CHARACTER VARYING(255))
	RETURNS SETOF funcionarioMatriculaNome AS $$
BEGIN
	RETURN QUERY SELECT matricula,nome FROM funcionarios WHERE nome ILIKE CONCAT('%',cNome,'%');
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION receberPagamento(codigoBarras CHARACTER VARYING(32))
	RETURNS BOOLEAN AS $$
DECLARE
	boleto RECORD;
BEGIN
	SELECT * INTO boleto FROM contas_a_receber WHERE codigo_barras = codigoBarras;
	IF boleto.pago=false THEN
		UPDATE contas_a_receber SET pago = true WHERE codigo_barras = codigoBarras;
		RETURN TRUE;
	END IF;
	RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fazerPagamento(codigoBarras CHARACTER VARYING(32))
	RETURNS BOOLEAN AS $$
DECLARE
	boleto RECORD;
BEGIN
	SELECT * INTO boleto FROM contas_a_pagar WHERE codigo_barras = codigoBarras;
	IF boleto.pago=false THEN
		UPDATE contas_a_pagar SET pago = true WHERE codigo_barras = codigoBarras;
		RETURN TRUE;
	END IF;
	RETURN FALSE;
END;
$$ LANGUAGE plpgsql;