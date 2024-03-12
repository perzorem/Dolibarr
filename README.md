# SAE51-2, Installation d'un ERP/CRM

Vous trouverez ci-dessous le guide d'installation ainsi que les explications des scripts et du travail réalisé
## I. Initialisation des conteneurs

### script.sh
Prérequis :
	Docker
	Docker-io
	
Executez le script script.sh situé dans /home/user/Dolibarr/script.sh
Ce script va creer deux volumes, MySQL et Dolibarr, le script va créer tout les paramètres nécessaires pour se connecter à l'interface Web de Dolibarr ainsi que les accès à la base de donnée.
```bash
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
```

## II. import.sh

### Utilisation du script d'importation
Prérequis :
	Les fichiers CSV importés doivent respecter le format imposé par Dolibarr pour ses données.
	Les fichiers CSV doivent être placés dans le répertoire suivant:
	"/home/user/Dolibarr/CSV/"

executez le script import.sh situé dans /home/user/Dolibarr/import.sh
Le script indiquera sa bonne execution et vous pourrez ensuite aller constater sur l'interface web de Dolibarr que vos données ont bien été importées

```bash
#!/bin/bash
while IFS=";" read -r line; do
    if [ "$line" != "nom;name_alias;ref_ext;code_client;" ]; then
        IFS=";" read -r nom name_alias ref_ext code_client _ <<< "$line"

        mysql -u dolibarr -p'dolibarr' -h 127.0.0.1 --port=3306 dolibarr << EOF
        INSERT INTO llx_societe (nom, name_alias, ref_ext, code_client)
        VALUES ('$nom', '$name_alias', '$ref_ext', '$code_client');
EOF
    fi
done < "CSV/donnees.csv"
```


