<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/dp4_cover.png"></p>

# Purpose
#### _The purpose of this deployment is to update our infrastructure and our CICD pipeline with tools that give us more control over our operations._ 
> * ##### _Update 1: We created a VPC with a subnet that will house our URL shortener application. This gives us control over network traffic and how it flows in and out of our infrastructure._
> * ##### _Update 2: We use NGINX as a reverse proxy to handle HTTP traffic coming into our EC2 instance through port 80._
> * ##### _Update 3: We use CloudWatch to trigger alarms that will keep us aware of important resource metrics like CPU utilization. This gives us opportunities to respond to critical events before they cause us operational issues._

___

# Problems
#### 1) EC2 went down and couldn’t get back in
<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/dp4error.PNG"></p>

> ##### _After installing and configuring all of the tools to run our application, the ec2 instance disconnected and wouldn’t accept any other attempts at reconnecting. We tried refreshing, restarting, checking security groups, using ssh, using an endpoint… The instance was terminated and we launched a new one. This worked and we were able to finish deploying our application_ 

#### 2) GitHub merge issues

#### 3) Couldn’t connect to URL shortener application(9/28/23)
> ##### _We configured our Nginx server to listen on port 5000 but never allowed incoming traffic on that port in our security group. We edited our inbound traffic rules to accept all TCP traffic on port 5000 and the our application was available._

> | Before Opening Port 5000                  | After Opening Port 5000               |
> | ----------------------------------- | ----------------------------------- |
> | ![aaaaaa.png](https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/n_working_nginx.PNG) | ![aaaaaa.png](https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/working_nginx.PNG) |
>
> # _🚨Update(10/1/23)🚨_
> ## The approach above was wrong. Nginx is functioning as the reverse proxy at port 8000. Nginx needs to be restarted before the changes made to the config file will take effect.
> ## This way, theres no need to edit our instance's security group to accept traffic on port 5000. Use `sudo systemctl restart nginx` to restart Nginx, re-edit the security group rules and remove port 5000. The gif below shows our app working on port 8000
> 
> ![Alt Text](https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/ezgif.com-gif-maker.gif)

#### 4) CloudWatch CPU monitoring data not granular enough
> #### _After running our Jenkins build while CloudWatch is monitoring our CPU utilization we didn’t see the kind of impact that was expected. There were data points on the CloudWatch line graph that did show a spike but the fastest monitoring interval CloudWatch has available is 60 seconds._
> <p align="left"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/cpu_system.PNG" width="75%"></p>
> <p align="left"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/cpu_user.PNG" width="75%"></p>

> ##### _Our Jenkins build took about 15 seconds._
> <p align="left"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/jenkins_dev_build_4.PNG" width="75%"></p>

> ##### _That means the data we get from CloudWatch wouldn’t accurately represent a critical metric we’re monitoring because it’s only reporting where that metric is exactly at every 60 second interval._
> ##### _Using the bash command `iostat -xz 5` now we can see our CPU utilization at every 5 second interval during that same time period CloudWatch was monitoring and reporting_
> ##### _We run another build._
> <mark>CPU Utilization During Jenkins Build</mark>
> <p align="left"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/cpuduring.png" width="75%"></p>

> #### _We find out that during our Jenkins build, our CPU actually hit a critical level of 89%. This is good information to know because depending on what else may be running on our machine during our future Jenkins builds, we could slow down deployment time or break something critical._

___

# Steps
### Step 1) Build Our Infrastructure
```
Create a VPC
Create a Public Subnet inside of our VPC
Attach a Internet Gateway to our VPC
Attach a Route Table to our Public Subnet
Create a t2-medium EC2 instance inside the Public Subnet of our VPC
Generate access keys for SSH connection
Enabled public IP address to be assigned
Create a Security Group that allows incoming traffic on ports 80, 8080, 8000, 22 & 5000
Launch our EC2 instance
Connect to our EC2 instance using "EC2 Instance Connect" or "SSH"
```

### Step 2) Download Our Application Files & Create Branch
* ##### _[Download App Files](https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/scripts/github_repo_create.sh)_
* ##### _Create a new branch in our repo called "dev" by running: `git checkout dev`_

### Step 3) Install & Configure Our Tools
* ##### Run this set of scripts to download the tools to run our application
* #####  1. _[Install Jenkins](https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/scripts/install_jenkins.sh)_
* #####  2. _[Install Python 10](https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/scripts/install_python10.sh)_
* #####  3. _[Install Pip](https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/scripts/install_pip.sh)_
* #####  4. _[Install Nginx](https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/scripts/install_nginx.sh)... Format your URL like this --> `http://<YOUR--PUBLIC-IP-ADDRESS>:80` and enter it into the browser. You should see this..._
> <p align="left"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/nginx_landingpage.PNG" width="50%"></p>_
* ##### 5. _Open the Nginx config file using this command and replace it with the text below `nano /etc/nginx/sites-enabled/default`_
```
#First change the port from 80 to 5000, see below:

server {
  listen 5000 default_server;
  listen [::]:5000 default_server;

# Now scroll down to where you see “location” and replace it with the text below:

location / {
  proxy_pass http://127.0.0.1:8000;
  proxy_set_header Host $host;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```
* ##### 6. _Use `sudo systemctl restart nginx` to restart Nginx, then format your URL like this --> `http://<YOUR--PUBLIC-IP-ADDRESS>:8000` and enter it into the browser. You should see this..._
> <p align="left"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/8000_working.png "width="50%"></p>

* ##### 7. _[Create IAM Role for CloudWatch](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/create-iam-roles-for-cloudwatch-agent.html)_
* ##### 8. _Attach Your IAM Role using the steps below_
> ```
  > Go to EC2 console
  > Select instance
  > Click actions
  > Click security
  > Click modify IAM role
  > Select IAM roles from dropdown
  > Update IAM role
  > ```
* ##### 9. _[Download CloudWatch Agent](https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/scripts/download_cloudwatch_agent.sh)_
* ##### 10. _Configure Your CloudWatch Alarm_
* ##### 11. _Switch to the 'dev' branch_ in GitHub by running this command: `git switch dev`
* ##### 12. _Update the current Jenkinsfile to this new [Jenkinsfile](https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/scripts/Jenkinsfile)_
* ##### 13. _Merge the dev and main branches & trigger a new Jenkins build by pushing the updated code to GitHub._

___

## System Diagram
<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/dp4_updated.drawio.svg"></p>

## Optimization











