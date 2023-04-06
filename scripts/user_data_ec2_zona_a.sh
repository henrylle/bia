#!/bin/bash

#Instalar Docker e Git
sudo yum update -y
sudo yum install git -y
sudo yum install docker -y
sudo usermod -a -G docker ec2-user
id ec2-user
sudo newgrp docker


#Instalar docker-compose
wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) 
sudo mv docker-compose-$(uname -s)-$(uname -m) /usr/local/bin/docker-compose
sudo chmod -v +x /usr/local/bin/docker-compose

#Ativar docker
sudo systemctl enable docker.service
sudo systemctl start docker.service