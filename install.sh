apt update
apt install docker
docker build --no-cache -t aufgabe .
docker run -d --name server --hostname localhost -p 80:80 -p 443:443 --rm -it aufgabe
docker exec server service apache2 start

