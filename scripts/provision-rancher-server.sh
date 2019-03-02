#!/usr/bin/env bash

#APT Update
echo -e 'Preparing to install Docker'
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get install     apt-transport-https     ca-certificates     curl     gnupg-agent     software-properties-common -y

#Install Docker
echo -e 'Installing Docker'
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

#Install Stable version of Rancher - modify if looking for different version
echo -e 'Run Rancher Server'
sudo docker run -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher:stable