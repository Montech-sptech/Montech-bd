CREATE DATABASE IF NOT EXISTS montech;

USE montech;

CREATE TABLE empresa (
  idEmpresa INT NOT NULL AUTO_INCREMENT,
  razaoSocial VARCHAR(200) NOT NULL,
  cnpj CHAR(14) NOT NULL,
  email VARCHAR(200),
  cep CHAR(8),
  numero VARCHAR(10),
  statusAtividade TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (idEmpresa),
  UNIQUE KEY uq_empresa_cnpj (cnpj)
);

CREATE TABLE aeroporto (
  idAeroporto INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(100) NOT NULL,
  codigoAeroporto VARCHAR(10) NOT NULL,
  statusAtividade TINYINT NOT NULL DEFAULT 1,
  fkEmpresa INT NOT NULL,
  PRIMARY KEY (idAeroporto),
  UNIQUE KEY uq_aeroporto_empresa_codigo (fkEmpresa, codigoAeroporto),
  CONSTRAINT fk_aeroporto_empresa FOREIGN KEY (fkEmpresa)
    REFERENCES empresa (idEmpresa)
);

CREATE TABLE cargo (
  idCargo INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(100) NOT NULL,
  descricao VARCHAR(250),
  statusAtividade TINYINT NOT NULL DEFAULT 1,
  empresa_idEmpresa INT NOT NULL,
  PRIMARY KEY (idCargo),
  UNIQUE KEY uq_cargo_nome (nome),
  CONSTRAINT fk_cargo_empresa FOREIGN KEY (empresa_idEmpresa)
    REFERENCES empresa (idEmpresa)
);

CREATE TABLE permissao (
  idPermissao INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(100) NOT NULL,
  descricao VARCHAR(250),
  PRIMARY KEY (idPermissao),
  UNIQUE KEY uq_permissao_nome (nome)
);

CREATE TABLE componente (
  idComponente INT NOT NULL AUTO_INCREMENT,
  nomeComponente VARCHAR(100) NOT NULL,
  unidadeMedida VARCHAR(30) NOT NULL,
  PRIMARY KEY (idComponente),
  UNIQUE KEY uq_componente_nome (nomeComponente)
);

CREATE TABLE servidor (
  uuidServidor BIGINT NOT NULL,
  nomeServidor VARCHAR(100) NOT NULL,
  hostname VARCHAR(100) NOT NULL,
  sistemaOperacional VARCHAR(100),
  intervaloColeta INT DEFAULT NULL,
  statusAtividade TINYINT NOT NULL DEFAULT 1,
  fkAeroporto INT NOT NULL,
  PRIMARY KEY (uuidServidor),
  UNIQUE KEY uq_servidor_aeroporto_nome (fkAeroporto, nomeServidor),
  CONSTRAINT fk_servidor_aeroporto FOREIGN KEY (fkAeroporto)
    REFERENCES aeroporto (idAeroporto),
  CONSTRAINT ck_servidor_intervalo
    CHECK (intervaloColeta IS NULL OR intervaloColeta > 0)
);

CREATE TABLE usuario (
  idUsuario INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(200) NOT NULL,
  senha VARCHAR(50) NOT NULL,
  cpf CHAR(11) NOT NULL,
  telefone VARCHAR(20),
  statusAtividade TINYINT NOT NULL DEFAULT 1,
  fkCargo INT NOT NULL,
  fkAeroporto INT NOT NULL,
  PRIMARY KEY (idUsuario),
  UNIQUE KEY uq_usuario_email (email),
  UNIQUE KEY uq_usuario_cpf (cpf),
  CONSTRAINT fk_usuario_cargo FOREIGN KEY (fkCargo)
    REFERENCES cargo (idCargo),
  CONSTRAINT fk_usuario_aeroporto FOREIGN KEY (fkAeroporto)
    REFERENCES aeroporto (idAeroporto)
);

CREATE TABLE servidorcomponente (
  idServidorComponente INT NOT NULL AUTO_INCREMENT,
  fkServidor BIGINT NOT NULL,
  fkComponente INT NOT NULL,
  identificadorInstancia VARCHAR(100) NOT NULL DEFAULT 'principal',
  limiteAtencao DECIMAL(10,2),
  limiteCritico DECIMAL(10,2),
  PRIMARY KEY (idServidorComponente),
  UNIQUE KEY uq_servidor_componente_instancia
    (fkServidor, fkComponente, identificadorInstancia),
  CONSTRAINT fk_servidorcomponente_servidor FOREIGN KEY (fkServidor)
    REFERENCES servidor (uuidServidor),
  CONSTRAINT fk_servidorcomponente_componente FOREIGN KEY (fkComponente)
    REFERENCES componente (idComponente),
  CONSTRAINT ck_servidorcomponente_limites CHECK (
    limiteAtencao IS NULL OR limiteCritico IS NULL
    OR limiteAtencao <= limiteCritico
  )
);

CREATE TABLE cargopermissao (
  idCargoPermissao INT NOT NULL AUTO_INCREMENT,
  fkCargo INT NOT NULL,
  fkPermissao INT NOT NULL,
  dataConcessao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (idCargoPermissao),
  UNIQUE KEY uq_cargopermissao (fkCargo, fkPermissao),
  CONSTRAINT fk_cargopermissao_cargo FOREIGN KEY (fkCargo)
    REFERENCES cargo (idCargo),
  CONSTRAINT fk_cargopermissao_permissao FOREIGN KEY (fkPermissao)
    REFERENCES permissao (idPermissao)
);

CREATE TABLE visualizacao (
  idVisualizacao INT NOT NULL AUTO_INCREMENT,
  fkUsuario INT NOT NULL,
  fkServidor BIGINT NOT NULL,
  dataInicioAcesso DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dataFimAcesso DATETIME,
  PRIMARY KEY (idVisualizacao),
  UNIQUE KEY uq_visualizacao_usuario_servidor (fkUsuario, fkServidor),
  CONSTRAINT fk_visualizacao_usuario FOREIGN KEY (fkUsuario)
    REFERENCES usuario (idUsuario),
  CONSTRAINT fk_visualizacao_servidor FOREIGN KEY (fkServidor)
    REFERENCES servidor (uuidServidor),
  CONSTRAINT ck_visualizacao_periodo CHECK (
    dataFimAcesso IS NULL OR dataFimAcesso >= dataInicioAcesso
  )
);