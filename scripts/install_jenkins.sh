#!/bin/bash
sudo apt-get update
sudo apt install openjdk-8-jdk -y
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee     /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]     https://pkg.jenkins.io/debian binary/ | sudo tee     /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install fontconfig openjdk-17-jre
sudo apt-get install jenkins
sudo systemctl start jenkins
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
