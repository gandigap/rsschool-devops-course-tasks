### Project Structure:
``` bash
├── Dockerfile
├── README.md
├── ec2.tf
├── ecr.tf
├── gateway.tf
├── js-app
│   ├── index.html
│   ├── jest.config.js
│   ├── node_modules
│   ├── package-lock.json
│   ├── package.json
│   ├── script.js
│   ├── script.test.js
│   └── util.js
├── k3s_server.sh
├── keys.tf
├── main.tf
├── outputs.tf
├── provider.tf
├── resources.tf
├── routes.tf
├── screenshots
│   ├── task-1
│   ├── task-3
│   ├── task-4
│   ├── task-5
│   └── task-6
├── security-group.tf
├── subnets.tf
├── variables.tf
└── vpc.tf
```
### Folders/Files Description:
* **.github/workflows/**:
  
  This hidden directory is where GitHub-specific files are stored, particularly workflows for GitHub Actions.
* **screenshots/**:
  
  This directory is used to store screenshots that are required in some of the tasks.
* **.gitignore**:
    
  This file specifies which folders or files should be ignored when tracking changes with Git.
* **README.md**:
  
  This is the file you're reading right now - the source of information about the project.
* **main.tf**:
  
  This is the primary configuration file for Terraform deployment. It contains the main infrastructure resources one needs to create.
* **providers.tf**:
  
  This file specifies the providers needed for Terraform configuration. Providers are the plugins that allow Terraform to interact with Cloud providers and other APIs.
* **resources.tf**:
  
  This file contains the resource definitions for Terraform configuration. Resources represent the components of infrastructure, like instances, databases, etc.
* **variables.tf**:
  
  This file defines input variables for Terraform configuration. Variables allow parameterization of Terraform scripts, making them more flexible and reusable.

* **ec2.tf**:

  Contains the configuration for Amazon EC2 instances. This file defines the instances to be created, including their types, AMIs, and any associated settings.
* **eip.tf**:

  Manages Elastic IP addresses in AWS. This file typically includes definitions for allocating and associating EIPs with instances or network interfaces.
* **eni.tf**

  Defines Elastic Network Interfaces (ENIs). It may include settings for creating and configuring network interfaces for EC2 instances, enabling advanced networking features.
* **igw.tf**

  Configures an Internet Gateway (IGW) for a VPC. This file typically includes the creation of the IGW and its attachment to the VPC to allow internet access.
* **keys.tf**

  Manages SSH keys or API keys used for authentication with resources. This file may define key pairs for EC2 instances or service account keys for API access.
* **nacl.tf**

  Configures Network Access Control Lists (ACLs) for subnets. This file defines rules for inbound and outbound traffic at the subnet level.
* **outputs.tf**

  Defines output variables that provide information about the resources after they are created. Outputs are useful for referencing resource attributes in other configurations or modules.
* **routes.tf**

  Configures routing tables for the VPC. It defines the routes that control the traffic flow between subnets and to the internet or other VPCs.
* **security-group.tf**

  Manages Security Groups (SGs) for the resources. This includes defining rules for inbound and outbound traffic to control access to EC2 instances and other resources.
* **subnets.tf**

  Defines the subnets within the VPC. This file includes configurations for public and private subnets, specifying CIDR blocks and availability zones.
* **vpc.tf**

  Configures the Virtual Private Cloud (VPC) itself. This file typically includes settings for creating the VPC, such as CIDR block, DNS settings, and any associated features.

### Usage
 When commiting changes or creating a pull request, the GHA pipeline will trigger the **check**,**plan** & **apply** terraform statements to verify changes & update your project infrastracture.

 In order to use this code for your own needs you need to:
* Manually create your own aws s3 bucket that you will use for terraform backend. Modify the *main.tf/backend* config with your s3 bucket name.
* Add necessary environment variables (using ```export TF_VAR_X``` syntax for local usage) to GitHub Secrets, they are specified in **terraform.yml** configuration file or you can see them in **variables.tf** - they won't have `default` parameter.
* To connect to launched instances, I suggest updating ~./ssh/config file with Bastion Host Address as well as other private instances within vpc's private subnets, like k3s' Server & Agent Nodes. To reach those you can use the `ProxyJump` parameter in config file (known as `ssh -J`). Here's the configuration I've used (note that all instances are using the same RSA key):

``` bash
### Configuration for Bastion host (jump host)
Host Bastion
    HostName 255.255.255.255
    User ec2-user
    IdentityFile ~/.ssh/aws/your_key_rsa
    ForwardAgent yes

### Configuration for connecting to the k3s Server via the Bastion host
Host k3s_server
    HostName 10.0.0.0
    User ec2-user
    IdentityFile ~/.ssh/aws/your_key_rsa
    ProxyJump Bastion

### Configuration for connecting to the k3s Agent via the Bastion
Host k3s_agent
    HostName 10.0.0.0
    User ec2-user
    IdentityFile ~/.ssh/aws/your_key_rsa
    ProxyJump Bastion

``` 

### To access `kubectl` remotely from your local machine, setup a *SOCKS5* proxy:
 - Make sure you have `kubectl` installed on your local machine
 - Copy kube config from your k3s server instance to your local machine update it with the k3s Server's private ip address and proxy-url parameter, and finally set `KUBECONFIG` environment variable to its path:
     * Download the kube config: `ssh k3s_server "cat /etc/rancher/k3s/k3s.yaml" > ~/.kube/k3s.yaml`
     * Update it: `vi ~/.kube/k3s.yaml`. More on that step can be found [here](https://kubernetes.io/docs/tasks/extend-kubernetes/socks5-proxy-access-api/).
     * Add `KUBECONFIG` env variable: `export KUBECONFIG=~/.kube/k3s.yaml`
 - Run `ssh -D 1080 -N -q Bastion` in a separate terminal (This will launch a SOCKS5 Proxy through your Bastion Host)
 - Run `kubectl get nodes` to check.

 ## PS. December-man helped me with this task and he allowed to use his configuration. I will try to refactor code in future. But he saved me in this hard time

 ## Task 4 
 - Complete command in terminal `terrafor apply`
 - Connect to k3s_server jenkins use terminal command `ssh k3s_server`
 - Check logs `sudo cat /var/log/cloud-init-output.log` and find jenkins credentials for example `Jenkins admin password: 8T1DnPrfVqOj4UgIkggJAU`
 - Connect to k3s_server jenkins use terminal command `ssh -L 8080:localhost:8080 k3s_server`
 - Open in browser page `http://localhost:8080` and log in Jenkins UI


  ## Task 5
   - Complete command in terminal `terrafor apply`
   - Connect to k3s_server jenkins use terminal command `ssh k3s_server`
   - Check logs `sudo cat /var/log/cloud-init-output.log` and find Wordpress credentials for example `WordPress password: v5EaH9drJz`
   - Connect to k3s_server jenkins use terminal command `ssh -L 8081:localhost:8081 k3s_server`
   - Open in browser page `http://localhost:8081` and log in Wordpress UI

   ## Task 6
   - Complete command `terraform apply` and connect to instance after change .ssh/config `ssh k3s_server`
   - Check logs complete command `sudo cat /var/log/cloud-init-output.log` and find credentials and Jenkins url
 [![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/terraform-config-connect-jenkins-cred.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/terraform-config-connect-jenkins-cred.png)
   - Connect to Jenkins and add required plugins for notifications and webhook trigger and credentionals. Config for webhook trigger you can check in README js-app repository https://github.com/gandigap/js-app
  - Notification instructions
1. Add plugin
 [![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/notification-plugin.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/notification-plugin.png)
 2. Create google password
 [![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/notification-google-password.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/notification-google-password.png)
 3. Add mail-cred
 [![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/notification-jenkins-cred.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/notification-plugin.png)
 4. Add notification system configs
 [![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/notification-test-config-success.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/notification-test-config-success.png)
 [![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/notification-test-config.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/notification-test-config.png)

   - Create pipeline (file in root) and manual run or wait webhook trigger
1. Clone
 [![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/pipe-step-clone.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/pipe-step-clone.png)
2. Install dependencies
 [![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/pipe-step-install-dependencies.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/pipe-step-install-dependencies.png)
3. Unit test
 [![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/pipe-step-unit-tests.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/pipe-step-unit-tests.png)
4. Install aws cli
 [![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/pipe-step-install-aws-cli.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/pipe-step-install-aws-cli.png)
5. Docker build
 [![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/pipe-step-docker-build.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/pipe-step-docker-build.png)
6. Docker push to ECR
 [![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/pipe-step-push-ecr.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/pipe-step-push-ecr.png)
7. Pipe success and notification
  [![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/notification-success-send.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/notification-success-send.png)
  [![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/pipeline-success-1.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/pipeline-success-1.png)
  [![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/pipeline-success-2.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/pipeline-success-2.png)


- After success you can manual run js-app with docker
[![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/manual-deploy.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/manual-deploy.png)
[![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/success-deploy-with-docker.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/success-deploy-with-docker.png)
     or with kubectl and [app-deployment.yaml](https://github.com/gandigap/js-app/blob/main/app-deployment.yaml) from js-app 
1. create ecr secret

[![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/kubectl-deploy-2.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/kubectl-deploy-2.png)

2. Create `app-deployment.yaml` with template from js-app repository
[![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/kubectl-deploy-1.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/kubectl-deploy-1.png)

3. Start js-app pods

[![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/kubectl-deploy-3.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/kubectl-deploy-3.png)

4. Success deploy

[![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/kubectl-deploy-4.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-6/screenshots/task-6/kubectl-deploy-4.png)


 ## Task 7
   - Complete command `terraform apply` and connect to instance after change .ssh/config `ssh k3s_server`
   - Check logs complete command `sudo cat /var/log/cloud-init-output.log`  with Prometheus pods
   - in terminal complete port forward for example `kubectl port-forward -n monitoring prometheus-server-6d5b6c7bdd-vcqrv 9090:9090` and `ssh -L 9090:localhost:9090 k3s_server`

[![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-7/screenshots/task-7/prometheus-pods-and-connect.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-7/screenshots/task-7/prometheus-pods-and-connect.png)

  - Open browser `http://localhost:9090/targets` and check access

[![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-7/screenshots/task-7/prometheus-targets.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-7/screenshots/task-7/prometheus-targets.png)

  ### Main metrics

  - Metric-1 - `node_memory_Active_bytes`

Description: The amount of active memory on a node in bytes.
Why it's needed: Shows how efficiently memory is being used at the node level. Helps prevent situations where a node runs out of memory.

[![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-7/screenshots/task-7/metric-1.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-7/screenshots/task-7/metric-1.png)
  
  - Metric-2 - `node_cpu_seconds_total`

Description: Total seconds that the CPU has been in use.
Why it's needed: Indicates the CPU load on a node. Useful for analyzing performance and planning scaling.

[![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-7/screenshots/task-7/metric-2.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-7/screenshots/task-7/metric-2.png)
  
  - Metric-3 - `kube_pod_status_phase`

Description: Displays the current status of pods in the cluster (Running, Pending, Failed, etc.).
Why it's needed: Allows you to monitor the number of pods in each state and quickly detect issues.

[![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-7/screenshots/task-7/metric-3.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-7/screenshots/task-7/metric-3.png)
  
  - Metric-4 - `node_network_receive_bytes_total`

Description: Tracks the total number of bytes received and transmitted over the network interface.
Why it's needed: Helps detect network bottlenecks or unusual traffic patterns that could indicate issues or attacks.

[![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-7/screenshots/task-7/metric-4.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-7/screenshots/task-7/metric-4.png)

  - Metric-5 - `kube_pod_container_status_restarts_total`

Description: Tracks the number of times a container has restarted.
Why it's needed: High restart counts can indicate unstable pods or misconfigured applications.

[![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-7/screenshots/task-7/metric-5.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-7/screenshots/task-7/metric-5.png)

## Task 8

  - Complete command in terminal `terraform apply`
  - Connect to k3s_server jenkins use terminal command `ssh k3s_server`
  - Check logs `sudo cat /var/log/cloud-init-output.log` 

I made 2 options for unfolding grafana on k3s: 

1. From this repository in k3s_server.sh 

[![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-8/screenshots/task-8/grafana-1.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-8/screenshots/task-8/grafana-1.png)
 
Open url for example `http://51.20.192.120:3000/` and set credentials : login `admin` password `GrafanaAdminPassword`

2. From custom helm chart in https://github.com/gandigap/rs_devops_wordpress/pull/2 where i did the same actions for task-5 with wordpress, but changed for grafana

[![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-8/screenshots/task-8/grafana-4.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-8/screenshots/task-8/grafana-4.png)

Open url for example `http://16.16.66.181:3000//` and set credentials : login `admin` password from github secrets `GRAFANA_ADMIN_PASSWORD`

#### Additionals screenshots 

[![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-8/screenshots/task-8/grafana-2.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-8/screenshots/task-8/grafana-2.png)
[![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-8/screenshots/task-8/grafana-3.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-8/screenshots/task-8/grafana-3.png)
[![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-8/screenshots/task-8/grafana-5.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-8/screenshots/task-8/grafana-5.png)

#### Metrics 
Disk Space Usage - (node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes * 100

Memory Utilization - (node_memory_MemTotal_bytes - node_memory_MemFree_bytes) / node_memory_MemTotal_bytes * 100

CPU Usage - 100 - avg(rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100

[![N|](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-8/screenshots/task-8/grafana-6.png)](https://github.com/gandigap/rsschool-devops-course-tasks/blob/task-8/screenshots/task-8/grafana-6.png)

## Task 9

  - Complete command in terminal `terraform apply`
  - Connect to k3s_server jenkins use terminal command `ssh k3s_server`
  - Clone and run actions form branch task-9  from repository https://github.com/gandigap/rs_devops_wordpress/tree/task-9
  - Check logs `sudo cat /var/log/cloud-init-output.log` 
  - Check grafana password `echo $(kubectl get secret grafana-admin -n grafana -o jsonpath="{.data.GF_SECURITY_ADMIN_PASSWORD}" | base64 --decode)` 
  - Open grafana config and check in UI (Data source, contact points)
  - Create dashboards and add alert rules like me provide on screenshots for metrics
    For memory`(node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100` 
    For CPU `100 - (avg by (instance)(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)`
  - Install stress 
    `sudo amazon-linux-extras install epel -y`
    `sudo yum install stress -y`
  - Run stress 
    For cpu `stress --cpu 2 --timeout 2m`
    For memory `stress --vm 1 --vm-bytes 1G --timeout 5m`
  - Check email from contact points