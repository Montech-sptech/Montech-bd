# Versão do MySQL (8.0 = a mesma do seu script; para trocar: --build-arg MYSQL_VERSION=8.4)
ARG MYSQL_VERSION=8.0
FROM mysql:${MYSQL_VERSION}

# Banco criado automaticamente na primeira inicialização
ENV MYSQL_DATABASE=montech
ENV TZ=America/Sao_Paulo

# Scripts .sql nesta pasta rodam em ordem alfabética, só na primeira
# inicialização (quando o volume de dados ainda está vazio)
COPY ./montech.sql /docker-entrypoint-initdb.d/01-montech.sql

EXPOSE 3306

CMD ["--character-set-server=utf8mb4", "--collation-server=utf8mb4_unicode_ci", "--default-time-zone=-03:00"]