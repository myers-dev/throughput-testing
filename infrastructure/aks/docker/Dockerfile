FROM ubuntu:20.04
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update --fix-missing -y
RUN apt-get upgrade -y
RUN apt-get install build-essential -y
RUN apt-get install apt-utils -y
RUN apt-get install software-properties-common -y
#RUN add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu groovy universe"
RUN apt-get update -y
RUN apt-get install net-tools -y
RUN apt-get install iputils-ping -y
RUN apt-get install inetutils-traceroute -y
RUN apt-get install iproute2 -y
RUN apt-get install iperf3 -y
RUN apt-get install ntp -y
RUN apt-get install curl -y
RUN apt-get install vim -y
#RUN timedatectl set-timezone America/New_York
RUN apt-get install jq -y
RUN apt-get install wget
RUN apt-get install python3-pip -y
RUN apt-get install unzip -y
RUN apt-get install less -y
RUN apt-get install nginx -y
# Python Dependencies
RUN pip3 install --upgrade pip 
RUN pip3 install azure.servicebus 
RUN pip3 install setuptools_rust 
RUN pip3 install cryptography 
RUN pip3 install azure.cosmosdb.table 
RUN wget https://github.com/tsenart/vegeta/releases/download/v12.8.4/vegeta_12.8.4_linux_amd64.tar.gz
RUN tar xvzf vegeta_12.8.4_linux_amd64.tar.gz
RUN cp vegeta /usr/bin
#
# Disabling default logging for nginx
RUN sed -i s/access_log/"# access_log"/ /etc/nginx/nginx.conf 
RUN sed -i s/error_log/"# error_log"/ /etc/nginx/nginx.conf 
#
# enabling ssl for nginx
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem -subj "/C=US/CN=fwtest"
#
RUN sed -i "s/\# include snippets\/snakeoil.conf;/  include snippets\/snakeoil.conf;/" /etc/nginx/sites-available/default
RUN sed -i "s/# listen 443/  listen 443/" /etc/nginx/sites-available/default
#
# to test : curl -k https://x.x.x.x
#
# generate random file
RUN mv /var/www/html/index.nginx-debian.html /var/www/html/index.nginx-debian.html.bac 
RUN dd if=/dev/urandom  bs=1024 count=1 | base64 > /var/www/html/index.nginx-debian.html # for 1M count = 1000
#
