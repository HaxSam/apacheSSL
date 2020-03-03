# sudo docker build --no-cache -t aufgabe .
# sudo docker run -d --name server --hostname localhost -p 80:80 -p 443:443 --rm -it aufgabe

FROM ubuntu:latest

RUN apt-get update
RUN apt-get -y install apache2 nano vim net-tools

RUN groupadd KundeA -g 10001
RUN groupadd KundeB -g 10002
RUN groupadd KundeC -g 10003

RUN useradd a-mueller -G KundeA -s /bin/bash
RUN useradd a-mayer -G KundeA -s /bin/bash
RUN useradd b-metzger -G KundeB -s /bin/bash
RUN useradd b-mueller -G KundeB -s /bin/bash
RUN useradd c-hauser -G KundeC -s /bin/bash
RUN useradd c-wagner -G KundeC -s /bin/bash

RUN mkdir /etc/apache2/kundenssl

COPY sites-available /etc/apache2/sites-available
COPY kundea /var/www/html/kundea
COPY kundeb /var/www/html/kundeb
COPY kundec /var/www/html/kundec

RUN a2enmod ssl
RUN a2ensite kundea.conf
RUN a2ensite kundea-ssl.conf
RUN a2ensite kundeb.conf
RUN a2ensite kundeb-ssl.conf
RUN a2ensite kundec.conf
RUN a2ensite kundec-ssl.conf

RUN mkdir /home/cisco
RUN mkdir /home/cisco/ssl

RUN useradd -d /home/cisco/ -m -p 12345 -s /bin/bash cisco
RUN echo "cisco:12345" | chpasswd

WORKDIR /home/cisco/ssl
RUN cd /home/cisco/ssl

RUN openssl genrsa -passout pass:1234 -des3 -out ca.key 4069
RUN openssl rand -out ca.seq -hex 256
RUN openssl req -passin pass:1234 -new -x509 -days 365 -key ca.key -out ca.crt -subj "/C=DE/O=KraussCA/CN=MartinCA" -sha256

RUN openssl genrsa -passout pass:1234 -des3 -out kundea.key 4069
RUN openssl req -passin pass:1234 -new -key kundea.key -out kundea.csr -subj "/C=DE/O=KundeA/CN=Sannnns" -sha256
RUN openssl rand -out ca.seq -hex 256
RUN openssl x509 -passin pass:1234 -req -days 365 -in kundea.csr -CA ca.crt -CAkey ca.key -out kundea.crt -CAserial ca.seq
RUN openssl rsa -passin pass:1234 -in kundea.key -out kundea.key

RUN openssl genrsa -passout pass:1234 -des3 -out kundeb.key 4069
RUN openssl req -passin pass:1234 -new -key kundeb.key -out kundeb.csr -subj "/C=DE/O=KundeB/CN=Sanic" -sha256
RUN openssl rand -out ca.seq -hex 256
RUN openssl x509 -passin pass:1234 -req -days 365 -in kundeb.csr -CA ca.crt -CAkey ca.key -out kundeb.crt -CAserial ca.seq
RUN openssl rsa -passin pass:1234 -in kundeb.key -out kundeb.key

RUN openssl genrsa -passout pass:1234 -des3 -out kundec.key 4069
RUN openssl req -passin pass:1234 -new -key kundec.key -out kundec.csr -subj "/C=DE/O=KundeC/CN=DoUKnwDeWae" -sha256
RUN openssl rand -out ca.seq -hex 256
RUN openssl x509 -passin pass:1234 -req -days 365 -in kundec.csr -CA ca.crt -CAkey ca.key -out kundec.crt -CAserial ca.seq
RUN openssl rsa -passin pass:1234 -in kundec.key -out kundec.key

RUN mv kundea.crt /etc/apache2/kundenssl/kundea.ctr
RUN mv kundea.key /etc/apache2/kundenssl/kundea.key
RUN mv kundeb.crt /etc/apache2/kundenssl/kundeb.ctr
RUN mv kundeb.key /etc/apache2/kundenssl/kundeb.key
RUN mv kundec.crt /etc/apache2/kundenssl/kundec.ctr
RUN mv kundec.key /etc/apache2/kundenssl/kundec.key

WORKDIR /home/cisco

ENTRYPOINT service apache2 start && /bin/bash