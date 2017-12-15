CREATE TABLE IF NOT EXISTS veiculos (
  id SERIAL NOT NULL PRIMARY KEY,
  descricao CHARACTER VARYING(255) NOT NULL,
  placa CHARACTER VARYING(8) NOT NULL,
  marcas_id INTEGER NOT NULL,
  categorias_id INTEGER NOT NULL,
  ativo BOOLEAN NULL DEFAULT TRUE
);
CREATE INDEX veiculos_marcas_idx ON veiculos (marcas_id);
CREATE INDEX veiculos_categorias_idx ON veiculos (categorias_id);

CREATE TABLE IF NOT EXISTS marcas (
  id SERIAL NOT NULL PRIMARY KEY,
  descricao CHARACTER VARYING(255) NOT NULL
);
CREATE TABLE IF NOT EXISTS categorias (
  id SERIAL NOT NULL PRIMARY KEY,
  descricao CHARACTER VARYING(255) NOT NULL
);

ALTER TABLE veiculos ADD CONSTRAINT veiculos_marcas_fk FOREIGN KEY (marcas_id) REFERENCES marcas (id) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE veiculos ADD CONSTRAINT veiculos_categorias_fk FOREIGN KEY (categorias_id) REFERENCES categorias (id) ON DELETE RESTRICT ON UPDATE RESTRICT;

CREATE TABLE IF NOT EXISTS funcionarios (
  id SERIAL NOT NULL PRIMARY KEY,
  nome CHARACTER VARYING(255) NOT NULL,
  matricula CHARACTER VARYING(8) NOT NULL
);
CREATE INDEX funcionarios_matricula_idx ON funcionarios (matricula);
ALTER TABLE funcionarios ADD CONSTRAINT funcionarios_matricula_uk UNIQUE (matricula);

CREATE TABLE IF NOT EXISTS reservas_finalidade (
  id SERIAL NOT NULL PRIMARY KEY,
  descricao CHARACTER VARYING(64) NULL DEFAULT NULL
);
CREATE TABLE IF NOT EXISTS clientes (
  id SERIAL NOT NULL PRIMARY KEY,
  nome CHARACTER VARYING(255) NOT NULL,
  cpf CHARACTER VARYING(14) NOT NULL,
  telefone CHARACTER VARYING(11) NOT NULL
);

CREATE TABLE IF NOT EXISTS reservas_veiculos (
  id SERIAL NOT NULL PRIMARY KEY,
  clientes_id INTEGER NOT NULL,
  veiculos_id INTEGER NOT NULL,
  funcionarios_id INTEGER NOT NULL,
  reservas_finalidade_id INTEGER NOT NULL,
  dataRetirada DATE NOT NULL,
  dataDevolucao DATE NOT NULL
);
CREATE INDEX reservas_veiculos_clientes_idx ON reservas_veiculos (clientes_id);
CREATE INDEX reservas_veiculos_veiculos_idx ON reservas_veiculos (veiculos_id);
CREATE INDEX reservas_veiculos_funcionarios_idx ON reservas_veiculos (funcionarios_id);
CREATE INDEX reservas_veiculos_finalidade_idx ON reservas_veiculos (reservas_finalidade_id);

ALTER TABLE reservas_veiculos ADD CONSTRAINT reservas_veiculos_clientes_fk FOREIGN KEY (clientes_id) REFERENCES clientes (id) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE reservas_veiculos ADD CONSTRAINT reservas_veiculos_veiculos_fk FOREIGN KEY (veiculos_id) REFERENCES veiculos (id) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE reservas_veiculos ADD CONSTRAINT reservas_veiculos_funcionarios_fk FOREIGN KEY (funcionarios_id) REFERENCES funcionarios (id) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE reservas_veiculos ADD CONSTRAINT reservas_veiculos_finalidade_fk FOREIGN KEY (reservas_finalidade_id) REFERENCES reservas_finalidade (id) ON DELETE RESTRICT ON UPDATE RESTRICT;

CREATE TABLE IF NOT EXISTS contas_a_receber (
  id SERIAL NOT NULL PRIMARY KEY,
  descricao CHARACTER VARYING(32) DEFAULT NULL,
  reservas_veiculos_id INTEGER NOT NULL,
  codigo_barras CHARACTER VARYING(32) NOT NULL,
  valor DOUBLE PRECISION NOT NULL,
  pago BOOLEAN DEFAULT FALSE
);
CREATE INDEX contas_a_receber_reservas_idx ON contas_a_receber (reservas_veiculos_id);
ALTER TABLE contas_a_receber ADD CONSTRAINT contas_a_receber_reservas_fk FOREIGN KEY (reservas_veiculos_id) REFERENCES reservas_veiculos (id) ON DELETE RESTRICT ON UPDATE RESTRICT;

CREATE TABLE IF NOT EXISTS contas_a_pagar (
  id SERIAL NOT NULL PRIMARY KEY,
  descricao CHARACTER VARYING(32) DEFAULT NULL,
  reservas_veiculos_id INTEGER NOT NULL,
  codigo_barras CHARACTER VARYING(32) NOT NULL,
  valor DOUBLE PRECISION NOT NULL,
  pago BOOLEAN DEFAULT FALSE
);
CREATE INDEX contas_a_pagar_reservas_idx ON contas_a_pagar (reservas_veiculos_id);
ALTER TABLE contas_a_pagar ADD CONSTRAINT contas_a_pagar_reservas_fk FOREIGN KEY (reservas_veiculos_id) REFERENCES reservas_veiculos (id) ON DELETE RESTRICT ON UPDATE RESTRICT;








CREATE TABLE IF NOT EXISTS precos (
  id SERIAL NOT NULL PRIMARY KEY,
  descricao CHARACTER VARYING(255) NOT NULL,
  veiculos_id INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS contratos (
  id SERIAL NOT NULL PRIMARY KEY,
  descricao CHARACTER VARYING(255) NOT NULL,
  locacoes_id INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS imagens_veiculos (
  id SERIAL NOT NULL PRIMARY KEY,
  descricao CHARACTER VARYING(255) NOT NULL,
  veiculos_id INTEGER NOT NULL
);