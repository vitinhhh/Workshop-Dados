create schema VelozCar;

create table Cliente (
id_cliente INT AUTO_INCREMENT PRIMARY KEY,
cpf VARCHAR(11) UNIQUE NOT NULL, 
nome VARCHAR(100) NOT NULL,
telefone VARCHAR(20),
email VARCHAR(100),
data_cadastro DATE,
cliente_status VARCHAR(20)

);

create table Veiculo (
id_veiculo INT AUTO_INCREMENT PRIMARY KEY,
placa CHAR(7) UNIQUE NOT NULL,
modelo VARCHAR(100),
cor VARCHAR (20),
ano_fabricacao INT,
valor_diaria DECIMAL(10,2),
status_veiculo ENUM("alugado", "disponivel"),
tipo_combustivel ENUM("eletrico", "diesel", "gasolina")
);


create table Funcionario (
id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
nome varchar(100),
cargo ENUM('atendente', 'gerente', 'mecanico'),
salario DECIMAL (10,2),
telefone VARCHAR (15),
email VARCHAR (100),
data_admissao DATE,
status_funcionario ENUM('indisponivel', 'disponivel')
);

create table Aluguel (
id_aluguel INT AUTO_INCREMENT PRIMARY KEY,
id_cliente INT NOT NULL,
id_funcionario INT NOT NULL,
id_veiculo INT NOT NULL,
data_inicio DATE,
data_fim DATE,
valor_total DECIMAL (10,2),
status_aluguel ENUM('ativo', 'concluido', 'cancelado'),

FOREIGN KEY (id_cliente) references cliente(id_cliente)
  ON DELETE RESTRICT
  ON UPDATE CASCADE,
FOREIGN KEY (id_funcionario) references funcionario(id_funcionario)
  ON DELETE RESTRICT
  ON UPDATE CASCADE,
FOREIGN KEY (id_veiculo) references veiculo(id_veiculo)
  ON DELETE RESTRICT
  ON UPDATE CASCADE
);


create table Pagamento (
id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
id_aluguel INT NOT NULL,
valor DECIMAL(10,2),
data_pagamento DATE,
metodo_pagamento ENUM('pix', 'cartao', 'dinheiro', 'boleto'),
status_pagamento ENUM('pendente', 'concluido', 'cancelado'),
codigo_transacao VARCHAR(100),
observacao VARCHAR(200),

FOREIGN KEY (id_aluguel) references aluguel(id_aluguel)
  ON DELETE RESTRICT
  ON UPDATE CASCADE
);

create table Manutencao (
id_manutencao INT AUTO_INCREMENT PRIMARY KEY,
id_veiculo INT NOT NULL,
id_funcionario INT NOT NULL,
descricao VARCHAR(200),
tipo_manutencao ENUM('preventiva', 'corretiva'),
data_manutencao DATE,
valor_manutencao DECIMAL(10,2),
status_manutencao ENUM('pendente', 'concluida'),

FOREIGN KEY (id_veiculo) references veiculo(id_veiculo)
  ON DELETE RESTRICT
  ON UPDATE CASCADE,
FOREIGN KEY (id_funcionario) references funcionario(id_funcionario)
 ON DELETE RESTRICT
 ON UPDATE CASCADE
);

CREATE TABLE servico_extra (
id_servico INT AUTO_INCREMENT PRIMARY KEY,
nome VARCHAR(100),
descricao VARCHAR(255),
valor DECIMAL(10,2),
categoria VARCHAR(50),
status ENUM('ativo', 'inativo'),
data_criacao DATE,
observacao VARCHAR(255)
);


create table aluguel_servico (
id_aluguel INT NOT NULL, 
id_servico INT NOT NULL,
quantidade INT,
valor_aplicado DECIMAL (10,2),
data_registro DATE,
status_aluguel_servico ENUM('ativo', 'cancelado'),
observacao VARCHAR(200),
codigo VARCHAR(50),

PRIMARY KEY (id_aluguel, id_servico),

FOREIGN KEY (id_aluguel) references aluguel(id_aluguel)
  ON DELETE RESTRICT
  ON UPDATE CASCADE,
FOREIGN KEY (id_servico) references servico_extra(id_servico)
  ON DELETE RESTRICT
  ON UPDATE CASCADE
);


select * from Cliente;

# Começo: Alter Table

alter table Cliente
CHANGE cliente_status doc_verificacao ENUM('pendente', 'em_analise', 'aprovado') NOT NULL DEFAULT 'pendente';

alter table Cliente
MODIFY COLUMN cpf CHAR(11) NOT NULL;

alter table Cliente
MODIFY COLUMN telefone VARCHAR(15); 

alter table Veiculo
MODIFY COLUMN status_veiculo ENUM('alugado', 'disponivel') NOT NULL DEFAULT 'disponivel';

alter table Veiculo
MODIFY COLUMN tipo_combustivel ENUM('pendente', 'eletrico', 'diesel', 'gasolina') NOT NULL DEFAULT 'pendente';

# Fim: Alter Table

# Começo: Triggers

DELIMITER $$

CREATE TRIGGER calcular_valor_total_aluguel
BEFORE INSERT ON Aluguel
FOR EACH ROW
BEGIN
    DECLARE diaria DECIMAL(10,2);
    
    SELECT valor_diaria INTO diaria
    FROM Veiculo
    WHERE id_veiculo = NEW.id_veiculo;

    SET NEW.valor_total = diaria * (DATEDIFF(NEW.data_fim, NEW.data_inicio) + 1);
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER atualizar_valor_total_aluguel
BEFORE UPDATE ON Aluguel
FOR EACH ROW
BEGIN
    DECLARE diaria DECIMAL(10,2);
    
    IF NEW.data_inicio <> OLD.data_inicio 
       OR NEW.data_fim <> OLD.data_fim
       OR NEW.id_veiculo <> OLD.id_veiculo THEN
        
        SELECT valor_diaria INTO diaria
        FROM Veiculo
        WHERE id_veiculo = NEW.id_veiculo;

        SET NEW.valor_total = diaria * (DATEDIFF(NEW.data_fim, NEW.data_inicio) + 1);
    END IF;
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER calcular_valor_pagamento
BEFORE INSERT ON Pagamento
FOR EACH ROW
BEGIN
    
    IF NEW.valor IS NULL OR NEW.valor = 0 THEN
        SET NEW.valor = (SELECT valor_total FROM Aluguel WHERE id_aluguel = NEW.id_aluguel);
    END IF;
END $$

DELIMITER ;

# Fim: Triggers

select * from aluguel;
delete from aluguel WHERE id_aluguel = 1;

# Começo: Inserts


INSERT INTO Cliente (nome, cpf, telefone, email, data_cadastro, doc_verificacao) VALUES
('João Silva', '11111111111', '11999999999', 'joao@email.com', '2024-01-10', 'pendente'),
('Maria Oliveira', '22222222222', '11988888888', 'maria@email.com', '2024-01-12', 'em_analise'),
('Pedro Santos', '33333333333', '11977777777', 'pedro@email.com', '2024-01-15', 'aprovado'),
('Ana Costa', '44444444444', '11966666666', 'ana@email.com', '2024-01-18', 'pendente'),
('Lucas Almeida', '55555555555', '11955555555', 'lucas@email.com', '2024-01-20', 'aprovado'),
('Fernanda Lima', '66666666666', '11944444444', 'fernanda@email.com', '2024-01-22', 'em_analise'),
('Rafael Rocha', '77777777777', '11933333333', 'rafael@email.com', '2024-01-25', 'pendente'),
('Carla Souza', '88888888888', '11922222222', 'carla@email.com', '2024-01-28', 'aprovado'),
('Bruno Martins', '99999999999', '11911111111', 'bruno@email.com', '2024-02-01', 'em_analise'),
('Patrícia Dias', '00000000000', '11900000000', 'patricia@email.com', '2024-02-05', 'pendente');

INSERT INTO Funcionario (nome, cargo, salario, telefone, email, data_admissao, status_funcionario) VALUES
('Lucas Almeida', 'atendente', 2500.00, '11999998888', 'lucas@email.com', '2024-02-01', 'disponivel'),
('Carlos Pereira', 'atendente', 2500.00, '11999990001', 'carlos@email.com', '2023-12-01', 'disponivel'),
('Juliana Silva', 'gerente', 5000.00, '11999990002', 'juliana@email.com', '2022-06-15', 'disponivel'),
('Marcos Lima', 'mecanico', 3000.00, '11999990003', 'marcos@email.com', '2023-01-20', 'indisponivel'),
('Fernanda Souza', 'atendente', 2600.00, '11999990004', 'fernanda@email.com', '2023-03-12', 'disponivel'),
('Ricardo Alves', 'mecanico', 3200.00, '11999990005', 'ricardo@email.com', '2023-05-18', 'disponivel'),
('Patrícia Costa', 'gerente', 5200.00, '11999990006', 'patricia@email.com', '2022-11-25', 'indisponivel'),
('Bruno Rocha', 'atendente', 2400.00, '11999990007', 'bruno@email.com', '2023-08-10', 'disponivel'),
('Ana Martins', 'mecanico', 3100.00, '11999990008', 'ana@email.com', '2023-09-05', 'disponivel'),
('Lucas Fernandes', 'gerente', 5100.00, '11999990009', 'lucas@email.com', '2022-07-30', 'disponivel');


INSERT INTO Veiculo (placa, modelo, cor, ano_fabricacao, valor_diaria, status_veiculo, tipo_combustivel) VALUES
('ABC1234', 'Toyota Corolla', 'Prata', 2020, 150.00, 'disponivel', 'gasolina'),
('DEF5678', 'Honda Civic', 'Preto', 2019, 160.00, 'disponivel', 'gasolina'),
('GHI9012', 'Chevrolet Onix', 'Branco', 2021, 120.00, 'alugado', 'gasolina'),
('JKL3456', 'Volkswagen Polo', 'Vermelho', 2022, 130.00, 'disponivel', 'diesel'),
('MNO7890', 'Ford Ka', 'Azul', 2020, 110.00, 'disponivel', 'gasolina'),
('PQR2345', 'Nissan Leaf', 'Prata', 2023, 200.00, 'disponivel', 'eletrico'),
('STU6789', 'Hyundai HB20', 'Preto', 2021, 125.00, 'alugado', 'gasolina'),
('VWX0123', 'Jeep Renegade', 'Branco', 2022, 180.00, 'disponivel', 'diesel'),
('YZA4567', 'Toyota Prius', 'Prata', 2023, 210.00, 'disponivel', 'eletrico'),
('BCD8901', 'Honda HR-V', 'Cinza', 2020, 170.00, 'disponivel', 'gasolina');


INSERT INTO Aluguel (id_cliente, id_funcionario, id_veiculo, data_inicio, data_fim, status_aluguel) VALUES
(1, 1, 1, '2024-03-10', '2024-03-12', 'ativo'),
(2, 2, 2, '2024-03-11', '2024-03-13', 'concluido'),
(3, 3, 3, '2024-03-12', '2024-03-14', 'ativo'),
(4, 4, 4, '2024-03-13', '2024-03-15', 'concluido'),
(5, 5, 5, '2024-03-14', '2024-03-16', 'ativo'),
(6, 6, 6, '2024-03-15', '2024-03-17', 'concluido'),
(7, 7, 7, '2024-03-16', '2024-03-18', 'ativo'),
(8, 8, 8, '2024-03-17', '2024-03-19', 'concluido'),
(9, 9, 9, '2024-03-18', '2024-03-20', 'ativo'),
(10, 10, 10, '2024-03-19', '2024-03-21','concluido');


INSERT INTO Manutencao (id_veiculo, id_funcionario, descricao, tipo_manutencao, data_manutencao, valor_manutencao, status_manutencao) VALUES
(1, 1, 'Troca de óleo e filtro', 'preventiva', '2024-03-05', 200.00, 'pendente'),
(2, 6, 'Revisão de freios', 'preventiva', '2024-03-06', 350.00, 'pendente'),
(3, 8, 'Troca de bateria', 'corretiva', '2024-03-07', 500.00, 'concluida'),
(4, 3, 'Alinhamento e balanceamento', 'preventiva', '2024-03-08', 150.00, 'concluida'),
(5, 5, 'Substituição de pneus', 'corretiva', '2024-03-09', 800.00, 'cancelada'),
(6, 9, 'Revisão geral', 'preventiva', '2024-03-10', 300.00, 'pendente'),
(7, 3, 'Troca de óleo e filtro', 'preventiva', '2024-03-11', 200.00, 'concluida'),
(8, 2, 'Revisão de suspensão', 'corretiva', '2024-03-12', 450.00, 'concluida'),
(9, 6, 'Troca de pastilhas de freio', 'preventiva', '2024-03-13', 250.00, 'pendente'),
(10, 8, 'Revisão elétrica', 'corretiva', '2024-03-14', 600.00, 'concluida');

INSERT INTO Pagamento (id_aluguel, data_pagamento, metodo_pagamento, status_pagamento, codigo_transacao, observacao) VALUES
(1, '2024-03-11', 'pix', 'concluido', 'TX001', 'Pagamento via PIX'),
(2, '2024-03-13', 'cartao', 'concluido', 'TX002', 'Pagamento integral, não parcelado'),
(3, '2024-03-14', 'dinheiro', 'pendente', 'TX003', NULL),
(4, '2024-03-15', 'boleto', 'concluido', 'TX004', 'Pagamento via boleto'),
(5, '2024-03-16', 'pix', 'pendente', 'TX005', NULL),
(6, '2024-03-17', 'cartao', 'concluido', 'TX006', NULL),
(7, '2024-03-18', 'dinheiro', 'pendente', 'TX007', NULL),
(8, '2024-03-19', 'boleto', 'concluido', 'TX008', 'Pagamento via boleto'),
(9, '2024-03-20', 'pix', 'pendente', 'TX009', NULL),
(10, '2024-03-21', 'cartao', 'concluido', 'TX010', NULL);


INSERT INTO servico_extra (nome, descricao, valor, categoria, status, data_criacao, observacao) VALUES
('Lavagem completa', 'Lavagem interna e externa do veículo', 80.00, 'Limpeza', 'ativo', '2024-03-10', NULL),
('Seguro adicional', 'Cobertura extra contra danos', 150.00, 'Seguro', 'ativo', '2024-01-12', 'Validade por 7 dias'),
('GPS', 'Aluguel de GPS portátil', 30.00, 'Adicional', 'ativo', '2024-01-15', NULL),
('Cadeirinha infantil', 'Aluguel de cadeirinha para criança', 25.00, 'Adicional', 'ativo', '2024-01-18', NULL),
('Tanque cheio', 'Veículo entregue com tanque completo', 80.00, 'Combustível', 'ativo', '2024-01-20', 'Opcional'),
('Lavagem simples', 'Lavagem externa do veículo', 30.00, 'Limpeza', 'ativo', '2024-01-22', NULL),
('Proteção contra arranhões', 'Cobertura extra contra pequenos danos', 100.00, 'Seguro', 'ativo', '2024-01-25', NULL),
('Wi-Fi portátil', 'Aluguel de hotspot Wi-Fi', 40.00, 'Adicional', 'ativo', '2024-01-28', NULL),
('Kit de primeiros socorros', 'Disponível no veículo', 20.00, 'Adicional', 'ativo', '2024-02-01', NULL),
('Assistência 24h', 'Suporte para emergências', 60.00, 'Seguro', 'ativo', '2024-02-05', 'Ativo somente durante o período do aluguel');

INSERT INTO aluguel_servico (id_aluguel, id_servico, quantidade, valor_aplicado, data_registro, status_aluguel_servico, observacao, codigo) VALUES
(1, 1, 1, 80.00, '2024-03-11', 'ativo', 'Serviço de lavagem adicional', 'AS001'),
(1, 3, 1, 30.00, '2024-03-12', 'ativo', 'GPS incluso no aluguel', 'AS002'),
(2, 2, 1, 150.00, '2024-03-13', 'ativo', NULL, 'AS003'),
(2, 4, 2, 50.00, '2024-03-13', 'ativo', '2 cadeirinhas', 'AS004'),
(3, 5, 1, 80.00, '2024-03-14', 'ativo', NULL, 'AS005'),
(4, 1, 1, 50.00, '2024-03-15', 'ativo', NULL, 'AS006'),
(5, 6, 1, 30.00, '2024-03-16', 'ativo', NULL, 'AS007'),
(6, 7, 1, 100.00, '2024-03-17', 'ativo', 'Proteção extra', 'AS008'),
(7, 8, 1, 40.00, '2024-03-18', 'ativo', NULL, 'AS009'),
(8, 9, 1, 20.00, '2024-03-19', 'ativo', 'Kit de primeiros socorros incluso', 'AS010');

#

# Começo: Select

SELECT doc_verificacao, COUNT(*) AS total_clientes
FROM Cliente
GROUP BY doc_verificacao;

SELECT MONTH(data_cadastro) AS mes, COUNT(*) AS total_clientes
FROM Cliente
GROUP BY MONTH(data_cadastro);

SELECT status_veiculo, COUNT(*) AS total_veiculos
FROM Veiculo
GROUP BY status_veiculo;

SELECT tipo_combustivel, AVG(valor_diaria) AS media_valor
FROM Veiculo
GROUP BY tipo_combustivel;

SELECT cargo, COUNT(*) AS total_funcionarios
FROM Funcionario
GROUP BY cargo;

SELECT cargo, AVG(salario) AS salario_medio
FROM Funcionario
GROUP BY cargo;

SELECT status_aluguel, COUNT(*) AS total_alugueis
FROM Aluguel
GROUP BY status_aluguel;

SELECT id_cliente, SUM(valor_total) AS total_gasto
FROM Aluguel
GROUP BY id_cliente;

# Fim: Select

# Começo: Join

SELECT a.id_aluguel, c.nome AS cliente, v.modelo AS veiculo, a.valor_total
FROM Aluguel a
INNER JOIN Cliente c ON a.id_cliente = c.id_cliente
INNER JOIN Veiculo v ON a.id_veiculo = v.id_veiculo;

SELECT v.id_veiculo, v.modelo, COALESCE(m.status_manutencao, 'nao_solicitada') AS status_manutencao
FROM Veiculo v
LEFT JOIN Manutencao m ON v.id_veiculo = m.id_veiculo;

SELECT p.id_pagamento, p.valor, p.status_pagamento, a.status_aluguel, c.nome AS cliente
FROM Pagamento p
INNER JOIN Aluguel a ON p.id_aluguel = a.id_aluguel
INNER JOIN Cliente c ON a.id_cliente = c.id_cliente;

# Fim: Join
