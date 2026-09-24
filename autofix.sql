
CREATE TABLE cliente (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE mecanico (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    especialidade VARCHAR(100) NOT NULL,
    valor_hora DECIMAL(10, 2) NOT NULL,
    CHECK (valor_hora > 0)
);

CREATE TABLE veiculo (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    placa VARCHAR(7) UNIQUE NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    marca VARCHAR(100) NOT NULL,
    ano INTEGER NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES cliente(id)
);

CREATE TABLE ordem_servico (
    id SERIAL PRIMARY KEY,
    veiculo_id INTEGER NOT NULL,
    mecanico_id INTEGER NOT NULL,
    data_abertura TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valor_mao_obra DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    status VARCHAR(20) NOT NULL DEFAULT 'Em Aberto',
    FOREIGN KEY (veiculo_id) REFERENCES veiculo(id),
    FOREIGN KEY (mecanico_id) REFERENCES mecanico(id),
    CHECK (valor_mao_obra >= 0),
    CHECK (status IN ('Em Aberto', 'Em Andamento', 'Concluida', 'Cancelada'))
);

CREATE TABLE peca_os (
    id SERIAL PRIMARY KEY,
    os_id INTEGER NOT NULL,
    nome_peca VARCHAR(150) NOT NULL,
    quantidade INTEGER NOT NULL,
    valor_unitario DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (os_id) REFERENCES ordem_servico(id),
    CHECK (quantidade > 0),
    CHECK (valor_unitario > 0)
);


INSERT INTO cliente (nome, email, telefone, cpf) VALUES
('Gabriel Martins', 'gabriel.martins@email.com', '48991234567', '45678912301'),
('Isabela Costa', 'isabela.costa@email.com', '48992345678', '56789123402'),
('Rafael Oliveira', 'rafael.oliveira@email.com', '48993456789', '67891234503');

INSERT INTO mecanico (nome, especialidade, valor_hora) VALUES
('André Ferreira', 'Freios', 95.00),
('Marcos Almeida', 'Suspensão', 105.00),
('Pedro Henrique', 'Motor', 135.00);

INSERT INTO veiculo (cliente_id, placa, modelo, marca, ano) VALUES
(1, 'DEF2G45', 'Onix', 'Chevrolet', 2022),
(2, 'GHT4J67', 'HB20', 'Hyundai', 2023),
(3, 'KLM8N90', 'Polo', 'Volkswagen', 2021);

INSERT INTO ordem_servico (veiculo_id, mecanico_id, valor_mao_obra, status) VALUES
(1, 2, 280.00, 'Concluida'),
(2, 1, 150.00, 'Em Andamento'),
(3, 3, 520.00, 'Concluida'),
(1, 3, 190.00, 'Em Aberto');

INSERT INTO peca_os (os_id, nome_peca, quantidade, valor_unitario) VALUES
(1, 'Pastilha de Freio', 2, 85.00),
(1, 'Fluido de Freio', 1, 40.00),
(2, 'Filtro de Ar', 1, 55.00),
(3, 'Correia Dentada', 1, 180.00);


SELECT 
    v.modelo,
    v.marca,
    v.placa,
    c.nome AS proprietario,
    c.telefone
FROM veiculo v
JOIN cliente c 
    ON v.cliente_id = c.id
ORDER BY v.marca ASC, v.modelo ASC;


SELECT 
    os.id AS id_os,
    v.placa,
    v.modelo,
    os.data_abertura,
    m.nome AS mecanico,
    os.status
FROM ordem_servico os
JOIN veiculo v 
    ON os.veiculo_id = v.id
JOIN cliente c 
    ON v.cliente_id = c.id
JOIN mecanico m 
    ON os.mecanico_id = m.id
WHERE c.nome = 'Gabriel Martins'
ORDER BY os.data_abertura DESC;


SELECT 
    os.id AS id_os,
    v.placa,
    m.nome AS mecanico,
    os.valor_mao_obra,
    COALESCE(SUM(p.quantidade * p.valor_unitario), 0) AS valor_peca,
    os.valor_mao_obra + COALESCE(SUM(p.quantidade * p.valor_unitario), 0) AS valor_total_final
FROM ordem_servico os
JOIN veiculo v 
    ON os.veiculo_id = v.id
JOIN mecanico m 
    ON os.mecanico_id = m.id
LEFT JOIN peca_os p 
    ON os.id = p.os_id
GROUP BY os.id, v.placa, m.nome, os.valor_mao_obra
ORDER BY os.id ASC;


SELECT 
    nome AS mecanico,
    especialidade,
    valor_hora
FROM mecanico
WHERE valor_hora > 100.00
ORDER BY valor_hora DESC;


SELECT 
    m.especialidade,
    SUM(os.valor_mao_obra) AS total_faturado_mao_obra
FROM ordem_servico os
JOIN mecanico m 
    ON os.mecanico_id = m.id
WHERE os.status = 'Concluida'
GROUP BY m.especialidade
ORDER BY total_faturado_mao_obra DESC;
