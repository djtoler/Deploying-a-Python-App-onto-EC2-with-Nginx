
# Purpose
> #### _The purpose of this deployment is to update our infrastructure and our CICD pipeline with tools that give us more control over our operations._ 
> * ##### _Update 1: We created a VPC with a subnet that will house our URL shortener application. This gives us control over network traffic and how it flows in and out of our infrastructure._
> * ##### _Update 2: We use NGINX as a reverse proxy to handle HTTP traffic coming into our EC2 instance through port 80._
> * ##### _Update 3: We use CloudWatch to trigger alarms that will keep us aware of important resource metrics like CPU utilization. This gives us opportunities to respond to critical events before they cause us operational issues._

___

# Problems
#### 1) EC2 went down and couldn’t get back in
> <p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/dp4error.PNG"></p>

> ##### After installing and configuring all of the tools to run our application, the ec2 instance disconnected and wouldn’t accept any other attempts at reconnecting. We tried refreshing, restarting, checking security groups, using ssh, using an endpoint… The instance was terminated and we launched a new one. This worked and we were able to finish deploying our application 

#### 2) GitHub merge issues

#### 3) Couldn’t connect to URL shortener application 
> ##### We configured our Nginx server to listen on port 5000 but never allowed incoming traffic on that port in our security group. We edited our inbound traffic rules to accept all TCP traffic on port 5000 and the our application was available.

> | Before Opening Port 5000                  | After Opening Port 5000               |
> | ----------------------------------- | ----------------------------------- |
> | ![aaaaaa.png](https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/n_working_nginx.PNG) | ![aaaaaa.png](https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/working_nginx.PNG) |

#### 4) CloudWatch CPU monitoring data not granular enough
> #### After running our Jenkins build while CloudWatch is monitoring our CPU utilization we didn’t see the kind of impact that was expected. There were data points on the CloudWatch line graph that did show a spike but the fastest monitoring interval CloudWatch has available is 60 seconds.
> <p align="left"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/cpu_system.PNG" width="75%"></p>
> <p align="left"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/cpu_user.PNG" width="75%"></p>

> ##### Our Jenkins build took about 15 seconds.
> <p align="left"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/jenkins_dev_build_4.PNG" width="75%"></p>

> ##### That means the data we get from CloudWatch wouldn’t accurately represent a critical metric we’re monitoring because it’s only reporting where that metric is exactly at every 60 second interval. 
> ##### Using the bash command `iostat -xz 5` now we can see our CPU utilization at every 5 second interval during that same time period CloudWatch was monitoring and reporting. 
> ##### We run another build.
> <mark>CPU Utilization During Build</mark>
> <p align="left"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/cpuduring.png" width="75%""></p>

> #### We find out that during our Jenkins build, our CPU actually hit a critical level of 89%. This is good information to know because depending on what else may be running on our machine during our future Jenkins builds, we could slow down deployment time or break something critical.


# Steps
### We run this set of scripts to download the tools to run our application
* > ####  [Install Jenkins](https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/scripts/install_jenkins.sh)
* > ####  [Install Python 10](https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/scripts/install_python10.sh)
* > ####  [Install Pip](https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/scripts/install_pip.sh)
* > ####  [Install Nginx](https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/scripts/install_nginx.sh)
* > ##### After running the scipt, format your URL like this --> `http://<YOUR-IP-ADDRESS>:<PORT-NUMBER>` and enter it into the browser. You should see this...
* > <p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/nginx_landingpage.PNG"></p>
* > ##### Open the Nginx config file using this command and replace it with the text below `nano /etc/nginx/sites-enabled/default`
```
###First change the port from 80 to 5000, see below:
server {
  listen 5000 default_server;
  listen [::]:5000 default_server;

####Now scroll down to where you see “location” and replace it
with the text below:

location / {
  proxy_pass http://127.0.0.1:8000;
  proxy_set_header Host $host;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}

```
* > #### [Create IAM Role for CloudWatch](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/create-iam-roles-for-cloudwatch-agent.html)
* > #### Attach Your IAM Role
* > ```
  >  Go to EC2 console
  > Select instance
  >  Click actions
  > Click security
  >  Click modify iam role
  >  Select iam roles from dropdown
  >  Update iam role
  > ```
* > #### [Download CloudWatch Agent](https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/scripts/download_cloudwatch_agent.sh)
* > #### Configure Your CloudWatch Alarm  

## System Diagram
<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/dp4.svg"></p>
## Optimization



<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/cpu1.PNG"></p>



<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/cw_alarm_set_up.PNG"></p>
<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/cw_setup.PNG"></p>
<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/disk_io.PNG"></p>

<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/nginx_landingpage.PNG"></p>
<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/t2_details.PNG"></p>


https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/nginx_landingpage.PNG





