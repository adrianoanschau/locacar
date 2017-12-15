INSERT INTO categorias VALUES
    (1,'Econômico (sem Ar)'),
    (2,'Econômico (Ar, DH)'),
    (3,'Sedan Compacto'),
    (4,'Pick Up'),
    (5,'SUV');

INSERT INTO marcas VALUES
    (1,'Ford'),
    (2,'Fiat'),
    (3,'Chevrolet'),
    (4,'Volkswagen'),
    (5,'Peugeot'),
    (6,'Renault'),
    (7,'Toyota');

INSERT INTO reservas_finalidade VALUES
    (1,'Locação'),
    (2,'Manutenção');

INSERT INTO veiculos VALUES
    (1,'Fiesta','KKY-8005',1,2,true);

SELECT cadastrarCliente('Adriano Anschau','01029790060','51995795971');
SELECT cadastrarCliente('Fernanda Brenner','01705065006','51995384313');
SELECT cadastrarFuncionario('Roger Machado','10391');
SELECT cadastrarFuncionario('Roberta Gonçalves','12500');

SELECT alugarVeiculo(1,1,'10391','2017-12-14','2017-12-15');