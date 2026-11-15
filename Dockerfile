FROM mysql:$8.0

ENV MYSQL_DATABASE=montech
ENV TZ=America/Sao_Paulo

COPY ./montech.sql /docker-entrypoint-initdb.d/01-montech.sql

EXPOSE 3306