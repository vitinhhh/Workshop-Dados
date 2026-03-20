create database desafio;

/* primeira tabela */ 

create table pessoas (
id INT PRIMARY KEY auto_increment,
nome varchar(100),
email varchar(100),
idade INT
);

/* DQL */ 
select * from pessoas;

/* segunda tabela */ 
create table pedidos (
id INT PRIMARY KEY AUTO_INCREMENT,
usuario_id INT,
produto VARCHAR(100),
valor DECIMAL(10,2),
FOREIGN KEY (usuario_id) REFERENCES pessoas(id)
);

select * from pedidos;

 /* DML */ 
update pessoas
set idade = 22
Where id = 6;

 /* agregadas */ 
select AVG(idade)
from pessoas;

select MIN(idade)
from pessoas;

select MAX(idade)
from pessoas;

select count(*)
from pessoas;

 /* agrupamentos */ 

SELECT usuario_id, SUM(valor) AS total_gasto
FROM pedidos
GROUP BY usuario_id;

SELECT usuario_id, AVG(valor) AS total_gasto
FROM pedidos
GROUP BY usuario_id;

 /* join */

select pessoas.nome, SUM(pedidos.valor) AS total_gasto
From pessoas
JOIN pedidos ON pessoas.id = pedidos.usuario_id
GROUP BY pessoas.nome;


