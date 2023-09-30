
# Deployment 4

## Purpose

> #### _The purpose of this deployment is to update our infrastructure and our CICD pipeline with tools that give us more control over our operations._ 
> * #### _Update 1: We created a VPC with a subnet that will house our URL shortener application. This gives us control over network traffic and how it flows in and out of our infrastructure._
> * #### _Update 2: We use NGINX as a reverse proxy to handle HTTP traffic coming into our EC2 instance through port 80._
> * #### _Update 3: We use CloudWatch to trigger alarms that will keep us aware of important resource metrics like CPU utilization. This gives us opportunities to respond to critical events before they cause us operational issues._

## Problems

### EC2 went down and couldn’t get back in
> <p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/dp4error.PNG"></p>

### GitHub merge issues
### Couldn’t connect to URL shortener application 
> <p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/n_working_nginx.PNG"></p>

### CloudWatch CPU monitoring data not granular enough

## Steps
## System Diagram
## Optimization


<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/cpu1.PNG"></p>
<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/cpu_from_sysstat.PNG"></p>
<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/cpuduring.png"></p>
<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/cpu_system.PNG"></p>
<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/cpu_user.PNG"></p>
<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/cpubefore.png"></p>
<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/cw_alarm_set_up.PNG"></p>
<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/cw_setup.PNG"></p>
<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/disk_io.PNG"></p>

<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/jenkins_dev_build_4.PNG"></p>
<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/nginx_landingpage.PNG"></p>
<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/n_working_nginx.PNG"></p>
<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/t2_details.PNG"></p>
<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/working_nginx.PNG"></p>
<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/dp4.svg"></p>

