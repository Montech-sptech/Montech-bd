CREATE DATABASE IF NOT EXISTS montech;

USE montech;

-- 1. Estrutura da empresa

CREATE TABLE empresa (
    idEmpresa INT AUTO_INCREMENT PRIMARY KEY,
    razaoSocial VARCHAR(200) NOT NULL,
    cnpj CHAR(14) NOT NULL UNIQUE,
    email VARCHAR(200),
    cep CHAR(8),
    numero VARCHAR(10),
    statusAtividade BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE aeroporto (
    idAeroporto INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    codigoAeroporto VARCHAR(10) NOT NULL,
    statusAtividade BOOLEAN NOT NULL DEFAULT TRUE,
    fkEmpresa INT NOT NULL,

    CONSTRAINT uq_aeroporto_empresa_codigo
        UNIQUE (fkEmpresa, codigoAeroporto),

    CONSTRAINT fk_aeroporto_empresa
        FOREIGN KEY (fkEmpresa) REFERENCES empresa(idEmpresa)
);

-- 2. Usuários e permissões de ações no site

CREATE TABLE cargo (
    idCargo INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao VARCHAR(250),
    statusAtividade BOOLEAN NOT NULL DEFAULT TRUE,
    fkEmpresa INT NOT NULL,
    
	CONSTRAINT fk_cargo_empresa
        FOREIGN KEY (fkEmpresa) REFERENCES empresa(idEmpresa)
);

CREATE TABLE permissao (
    idPermissao INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao VARCHAR(250)
);

CREATE TABLE cargoPermissao (
    idCargoPermissao INT AUTO_INCREMENT PRIMARY KEY,
    fkCargo INT NOT NULL,
    fkPermissao INT NOT NULL,
    dataConcessao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_cargo_permissao
        UNIQUE (fkCargo, fkPermissao),

    CONSTRAINT fk_cp_cargo
        FOREIGN KEY (fkCargo) REFERENCES cargo(idCargo),

    CONSTRAINT fk_cp_permissao
        FOREIGN KEY (fkPermissao) REFERENCES permissao(idPermissao)
);

CREATE TABLE usuario (
    idUsuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(200) NOT NULL UNIQUE,
    cpf CHAR(11) NOT NULL UNIQUE,
    senhaHash VARCHAR(255) NOT NULL,
    telefone VARCHAR(20),
    statusAtividade BOOLEAN NOT NULL DEFAULT TRUE,
    fkCargo INT NOT NULL,
    fkAeroporto INT NOT NULL,

    CONSTRAINT fk_usuario_cargo
        FOREIGN KEY (fkCargo) REFERENCES cargo(idCargo),

    CONSTRAINT fk_usuario_aeroporto
        FOREIGN KEY (fkAeroporto) REFERENCES aeroporto(idAeroporto)
);

-- 3. Servidores e componentes monitorados

CREATE TABLE servidor (
    idServidor INT AUTO_INCREMENT PRIMARY KEY,
    nomeServidor VARCHAR(100) NOT NULL,
    hostname VARCHAR(100) NOT NULL,
    sistemaOperacional VARCHAR(100),
    intervaloColeta INT,
    statusAtividade BOOLEAN NOT NULL DEFAULT TRUE,
    fkAeroporto INT NOT NULL,

    CONSTRAINT uq_servidor_aeroporto_nome
        UNIQUE (fkAeroporto, nomeServidor),

    CONSTRAINT fk_servidor_aeroporto
        FOREIGN KEY (fkAeroporto) REFERENCES aeroporto(idAeroporto)
);

CREATE TABLE componente (
    idComponente INT AUTO_INCREMENT PRIMARY KEY,
    nomeComponente VARCHAR(100) NOT NULL UNIQUE,
    unidadeMedida VARCHAR(30) NOT NULL
);

CREATE TABLE servidorComponente (
    idServidorComponente INT AUTO_INCREMENT PRIMARY KEY,
    fkServidor INT NOT NULL,
    fkComponente INT NOT NULL,

    -- Permite distinguir, por exemplo, Disco C: de Disco D:
    identificadorInstancia VARCHAR(100) NOT NULL DEFAULT 'principal',

    limiteAtencao DECIMAL(10,2),
    limiteCritico DECIMAL(10,2),

    CONSTRAINT uq_servidor_componente_instancia
        UNIQUE (fkServidor, fkComponente, identificadorInstancia),

    CONSTRAINT fk_sc_servidor
        FOREIGN KEY (fkServidor) REFERENCES servidor(idServidor),

    CONSTRAINT fk_sc_componente
        FOREIGN KEY (fkComponente) REFERENCES componente(idComponente),

    CONSTRAINT ck_sc_limites
        CHECK (
            limiteAtencao IS NULL
            OR limiteCritico IS NULL
            OR limiteCritico >= limiteAtencao
        )
);


-- Liberação individual: exceção para um usuário específico.
CREATE TABLE visualizacao (
    idVisualizacao INT AUTO_INCREMENT PRIMARY KEY,
    fkUsuario INT NOT NULL,
    fkServidor INT NOT NULL,
    dataInicioAcesso DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dataFimAcesso DATETIME NULL,

    CONSTRAINT uq_visualizacao_usuario_servidor
        UNIQUE (fkUsuario, fkServidor),

    CONSTRAINT fk_visualizacao_usuario
        FOREIGN KEY (fkUsuario) REFERENCES usuario(idUsuario),

    CONSTRAINT fk_visualizacao_servidor
        FOREIGN KEY (fkServidor) REFERENCES servidor(idServidor),

    CONSTRAINT ck_visualizacao_periodo
        CHECK (
            dataFimAcesso IS NULL
            OR dataFimAcesso > dataInicioAcesso
        )
);

-- 4. Relatórios criados na tela apresentada

CREATE TABLE relatorio (
    idRelatorio INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    resumo TEXT,
    descricaoObservacoes TEXT,
    dataInicioPeriodo DATETIME NOT NULL,
    dataFimPeriodo DATETIME NOT NULL,
    dataRelatorio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    statusRelatorio VARCHAR(30) NOT NULL DEFAULT 'Concluído',
    fkUsuario INT NOT NULL,
    fkServidor INT NOT NULL,

    CONSTRAINT fk_relatorio_usuario
        FOREIGN KEY (fkUsuario) REFERENCES usuario(idUsuario),

    CONSTRAINT fk_relatorio_servidor
        FOREIGN KEY (fkServidor) REFERENCES servidor(idServidor),

    CONSTRAINT ck_relatorio_periodo
        CHECK (dataFimPeriodo >= dataInicioPeriodo)
);