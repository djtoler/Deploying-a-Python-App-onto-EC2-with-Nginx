#!/bin/bash

git --version
git clone https://github.com/kura-labs-org/c4_deployment-4/
sudo apt install gh
gh auth login
gh repo create Deployment4 --public
mkdir dp4
cp -r c4_deployment-34/* dp4/
cd dp4/
git init
git add .
git commit -m"first commit"
git branch -M main
git remote add origin https://github.com/djtoler/Deployment4
git push -u origin main
cd ~
