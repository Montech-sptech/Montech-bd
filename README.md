# MonTech - Banco de Dados

Banco de dados MySQL do **MonTech**, sistema de monitoramento da infraestrutura computacional do software **SAGITARIO** (controle de tráfego aéreo). O banco guarda empresas, aeroportos, usuários e permissões, além dos servidores monitorados e dos componentes (CPU, RAM, disco, rede...) que cada um coleta, com seus limites de alerta.

## Contexto

O MonTech monitora os servidores que sustentam o SAGITARIO, com foco no processo de *Flight Plan / Track Correlation*:

| Servidor | Função |
|---|---|
| **SPA** | Tratamento de planos de voo e informações aeronáuticas |
| **SDV** | Tratamento de dados de vigilância (trilhas das aeronaves) |
| **AIS** | Serviço de informação aeronáutica |

Scripts Python coletam as métricas (arquivos `.csv`) e consultam este banco para saber **quem está logado**, **qual servidor** monitorar e **quais componentes** coletar. A aplicação Web usa os mesmos dados para dashboards, alertas e incidentes.

## Estrutura do repositório

| Arquivo | Conteúdo |
|---|---|
| `script-Montech.sql` | Criação do banco `montech`, das tabelas e inserts |
| `der-montech-v2.mwb` | Modelagem dos dados |

--- 

## Modelagem

<img width="958" height="729" alt="der-montech-v2" src="https://github.com/user-attachments/assets/7e2a4c82-933f-45b9-b44d-a58dc3e427a9" />

## Equipe

Projeto da **São Paulo Tech School** (Ciência da Computação), na matéria de Pesquisa e Inovação. Orientação: Julia Araripe e Fernando Brandão.

- Guilherme Gonçalves Britto
- Lucas Santos Gama
- Nicole Rodrigues do Nascimento
- Thiago Alexandre Emidio de Souza
- Vinicius Borges do Nascimento
