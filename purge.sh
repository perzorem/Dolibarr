docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

docker network prune -f
docker volume rm $(docker volume ls -q)
