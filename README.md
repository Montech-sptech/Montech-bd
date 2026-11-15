# MonTech – MySQL com Docker

Banco de dados MySQL do projeto MonTech, empacotado em Docker. Na primeira inicialização o container executa o `montech.sql`, que cria o banco `montech`, as tabelas e os dados iniciais.

Ao subir o banco, a network Docker **`montech-net`** também é criada. Qualquer outro container que entrar nela já consegue acessar o MySQL pelo nome `montech-db`.

## Estrutura do repositório

```
.
├── Dockerfile            # imagem baseada em mysql:8.0 + montech.sql
├── docker-compose.yml    # serviço do banco, volume e network
├── montech.sql           # schema e carga inicial do banco
├── .env.example          # modelo das variáveis de ambiente
├── .env                  # suas senhas (NÃO vai para o Git)
├── .dockerignore
└── .gitignore
```

## Pré-requisitos

- Docker Engine 20.10+ com o plugin Docker Compose v2 (comando `docker compose`)
- Porta `3306` livre no host (ou outra, definida em `MYSQL_PORT`)

Confira com:

```bash
docker --version
docker compose version
```

> Se o seu usuário não estiver no grupo `docker`, use `sudo` antes dos comandos.

## Configuração

Crie o arquivo `.env` a partir do modelo:

```bash
cp .env.example .env
```

Edite os valores:

| Variável | Obrigatória | Padrão | Descrição |
|---|---|---|---|
| `MYSQL_ROOT_PASSWORD` | Sim | – | Senha do usuário `root` |
| `MYSQL_PASSWORD` | Sim | – | Senha do usuário adicional |
| `MYSQL_USER` | Não | `montech` | Usuário adicional, com acesso ao banco `montech` (não pode ser `root`) |
| `MYSQL_PORT` | Não | `3306` | Porta publicada no host |

Evite `$`, `#`, aspas e espaços nas senhas, pois o Compose pode interpretá-los de forma inesperada.

## Subindo o banco

```bash
docker compose up -d --build
```

Acompanhe a inicialização (a primeira vez demora mais porque executa o `montech.sql`):

```bash
docker compose logs -f db
```

O container está pronto quando o status aparece como `healthy`:

```bash
docker compose ps
```

## Conectando ao banco

### Pelo terminal (dentro do container)

```bash
docker exec -it montech-db mysql -uroot -p montech
```

Exemplo de verificação:

```sql
SHOW TABLES;
SELECT nome, codigoAeroporto FROM aeroporto;
```

### Pelo host (DBeaver, MySQL Workbench, aplicação local)

| Campo | Valor |
|---|---|
| Host | `127.0.0.1` |
| Porta | `3306` (ou o valor de `MYSQL_PORT`) |
| Banco | `montech` |
| Usuário | `MYSQL_USER` ou `root` |
| Senha | a do `.env` |

### De outro container (via `montech-net`)

| Campo | Valor |
|---|---|
| Host | `montech-db` (ou o alias `mysql`) |
| Porta | `3306` (sempre a porta interna, independente de `MYSQL_PORT`) |
| Banco | `montech` |

Exemplo de string JDBC:

```
jdbc:mysql://montech-db:3306/montech
```

## Usando a network `montech-net` em outros containers

A network é criada pelo Compose do banco, então **suba o banco primeiro**.

Com `docker run`:

```bash
docker run -d --name minha-api --network montech-net minha-imagem
```

Com Docker Compose, no `docker-compose.yml` do outro projeto:

```yaml
services:
  api:
    image: minha-imagem
    networks:
      - montech-net
    environment:
      DB_HOST: montech-db
      DB_PORT: 3306
      DB_NAME: montech

networks:
  montech-net:
    external: true
```

Para conferir quem está conectado:

```bash
docker network inspect montech-net
```

## Comandos úteis

| Ação | Comando |
|---|---|
| Ver status | `docker compose ps` |
| Ver logs | `docker compose logs -f db` |
| Parar (mantém os dados) | `docker compose stop` |
| Iniciar de novo | `docker compose start` |
| Parar e remover o container e a network (mantém os dados) | `docker compose down` |
| Reconstruir a imagem | `docker compose up -d --build` |

## Backup e restauração

Backup:

```bash
docker exec montech-db sh -c 'mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" montech' > backup-montech.sql
```

Restauração:

```bash
docker exec -i montech-db sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" montech' < backup-montech.sql
```

## Recriando o banco do zero

O `montech.sql` **só é executado quando o volume `montech_data` está vazio**. Se você alterou o SQL, ou mudou as senhas no `.env`, e quer aplicar tudo de novo:

```bash
docker compose down -v      # ATENÇÃO: apaga todos os dados do banco
docker compose up -d --build
```

## Problemas comuns

**`defina MYSQL_ROOT_PASSWORD no .env`**
O arquivo `.env` não existe ou está sem a variável. Rode `cp .env.example .env` e preencha.

**`port is already allocated` / `address already in use`**
A porta `3306` está ocupada (provavelmente outro MySQL ou o container antigo do script). Mude `MYSQL_PORT` no `.env`, por exemplo para `3307`, ou remova o container antigo com `docker rm -f montech-db`.

**`Access denied for user`**
As senhas do `.env` só valem na primeira inicialização. Se você as alterou depois, recrie o banco (seção acima) ou altere a senha direto no MySQL com `ALTER USER`.

**`network montech-net declared as external, but could not be found`**
O banco ainda não foi iniciado. Suba o `docker compose up -d` deste repositório antes dos outros containers.

**O container fica `unhealthy` ou reinicia**
Veja o motivo com `docker compose logs db`. Em geral é erro de sintaxe no `montech.sql` ou volume com dados de uma inicialização anterior que falhou (use `docker compose down -v`).

## Segurança

- Nunca faça commit do `.env`. Ele já está no `.gitignore`.
- O `montech.sql` contém dados de exemplo, incluindo credenciais de integração (Jira). Não o publique em repositório público com tokens reais, e prefira injetar segredos por variáveis de ambiente.
- Se o banco só for acessado por outros containers, remova o bloco `ports` do `docker-compose.yml` para não expor a `3306` no host.