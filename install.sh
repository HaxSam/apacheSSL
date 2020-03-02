apt update

apt install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

apt-key fingerprint 0EBFCD88

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
   
apt update

apt install docker-ce docker-ce-cli containerd.io docker

docker build --no-cache -t aufgabe .
docker run -d --name server --hostname localhost -p 80:80 -p 443:443 --rm -it aufgabe
docker exec server service apache2 start

