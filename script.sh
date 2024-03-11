#!/bin/bash

docker volume create mysqldb
docker volume create dolibarr
docker network create Dolibarr

docker run --name Base_mysql \
    -p 3306:3306 \
    -v mysqldb:/var/lib/mysql \
    --env MYSQL_ROOT_PASSWORD=trap \
    --env MYSQL_USER=dolibarr \
    --env MYSQL_PASSWORD=dolibarr \
    --env MYSQL_DATABASE=dolibarr \
    --env character_set_client=utf8 \
    --env character-set-serveur=utf8mb4 \
    --env collation-serveur=utf8mb4_unicode_ci \
    --network=Dolibarr \
    -d mysql

echo "démarrage de la base de donnée en cours..."
sleep 120
echo "terminé"

#mysql -u dolibarr -p'dolibarr' -h 127.0.0.1 --port=3306 dolibarr < SQL/createdoli.sql

docker run -p 80:80 \
    --name Dolibarr \
    --env DOLI_DB_HOST=Base_mysql \
    --env DOLI_DB_NAME=dolibarr \
    --env DOLI_MODULES=modSociete \
    --env DOLI_ADMIN_LOGIN=Doliuser \
    --env DOLI_ADMIN_PASSWORD=Doliuser \
    --network=Dolibarr \
    -d \
    upshift/dolibarr

echo "démarrage du conteneur en cours..."
sleep 180
echo "terminé"

docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' Dolibarr  
