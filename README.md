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
> ##### _We had a lot of issues with merging the Jenkinsfile from dev branch to main branch. Found a command to use to get our branches in sync. `git cherry-pick [commit-hash]` will take any commit you've made on any branch and apply it to the branch you're currently working in._
> ##### _These are the last git commands used that got our Jenkins file updated and matching in our dev and main branches_

```
  263  git checkout dev
  264  git log
  265  git checkout main
  266  git cherry-pick 8a7b52482fadb6f664dacbcf86bb812a28ae0536
  267  nano Jenkinsfile
  268  git add Jenkinsfile
  269  git cherry-pick --continue
  270  git push origin main
  271  cat Jenkinsfile
  272  git checkout dev
  273  cp Jenkinsfile Jenkinsfile.bak
  274  git checkout main
  275  cp Jenkinsfile.bak Jenkinsfile
  276  git add Jenkinsfile
  277  git commit -m "Restored Jenkinsfile from dev branch"
  278  git push origin main
```

> ##### Inside our target branch, we basically override the current Jenkinsfile with a backup of the Jenkinsfile from the dev branch and pushed it to the main branch.

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

> ## _🚨Update(10/2/23)🚨_
> ### CloudWatch actually can give us the data we're looking for. We just have to configure the alarms the right way. When creating the alarm we can choose intervals as low as 10 second. We can also choose to have the highest point our CPU utilization reached within that interval.

> <p align="left"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/Screenshot%202023-10-02%20at%2010.52.46%20AM.png" width="50%"></p>
___

# Steps
### Step 1) Build Our Infrastructure
* #### _In this deployment, we move away from the default infastructre AWS provides and build our own. This gives us more control over important aspects of our system design like regulating ingress and egress traffic. This can reduce our costs by protecting our resources from potential unauthorized use/abuse... Or cost optimizing our system components by isolating them and analyzing each one individually._
```
Create a VPC
Create a Public Subnet inside of our VPC
Attach a Internet Gateway to our VPC
Attach a Route Table to our Public Subnet
Create a t2-medium EC2 instance inside the Public Subnet of our VPC
Generate access keys for SSH connection
Enabled public IP address to be assigned
Create a Security Group that allows incoming traffic on ports 80, 8080, 8000, 22 
Launch our EC2 instance
Connect to our EC2 instance using "EC2 Instance Connect" or "SSH"
```

### Step 2) Download Our Application Files & Create An Additional Branch In GitHub Repo
* #### _In this step we create an additional branch in GitHub. This feature will give us the flexibility we need to modify our current code and test new versions in isolated enviornments. In our context, the benifit of using GitHub branches is that it will protect our production enviornment from being introduced to errors that can degrade or crash our application's services, which is exactly [what happened when we deployed URL Shortener v3.1](https://github.com/djtoler/dp3-1)._
> ##### _[Download App Files](https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/scripts/github_repo_create.sh)_
> ##### _Create a new branch in our repo called "dev" by running: `git checkout dev`_

### Step 3) Install & Configure Our Tools
> ##### Run this set of scripts to download the tools to run our application
> #####  1. _[Install Jenkins](https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/scripts/install_jenkins.sh)_
> #####  2. _[Install Python 10](https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/scripts/install_python10.sh)_
> #####  3. _[Install Pip](https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/scripts/install_pip.sh)_
> #####  4. _[Install Nginx](https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/scripts/install_nginx.sh)... Format your URL like this --> `http://<YOUR--PUBLIC-IP-ADDRESS>:80` and enter it into the browser. You should see this..._
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

## Questions
* #### How is the server performing? _During the multi-branch pipeline run, the servers CPU spiked up to 89% utilization._
* #### Can the server handle everything installed on it? if yes, how would a T.2 micro handle in this deployment? _The server did handle everything installed on it. If we had used a t2.mirco, our CPU utilization would have went higher and it would have reached those high utilization percentages faster Memory also spiked considerably with the t2.medium and it would have spiked even more using a t2.micro. Both memory and utilization spiking would cause performance issuse which could impact our applications availability._
* #### What happens to the CPU when you run another build? _CPU utilization and memory utilization would both spike._
___
## System Diagram
<p align="center"><img src="https://github.com/djtoler/Deployment4___Nginx_Jenkins/blob/main/assets/dp4_updated3.drawio.svg"></p>

## Optimization

* #### Configure our GitHub by editing the config file
* #### Get a better handle on GitHub merging, commiting and conflict resolving.
* #### Use a userdata script for our EC2 instance to have all of our tools installed during its launch
* #### Since we are moving away from managed infastructure, automate deploying our infastructure with code and managing it with alarms, notifications & automated responses











