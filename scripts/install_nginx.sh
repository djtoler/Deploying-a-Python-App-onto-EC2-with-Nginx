#!/bin/bash

sudo apt update
sudo apt install nginx
sudo ufw enable
sudo ufw allow 'Nginx Full'
systemctl status nginx
