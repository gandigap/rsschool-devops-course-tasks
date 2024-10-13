# rsschool-devops-course-tasks
https://github.com/rolling-scopes-school/tasks/blob/master/devops/modules/1_basic-configuration/task_2.md

###  In this task, i did:

1. **Write Terraform Code**

   - Create Terraform code to configure the following:
     - VPC
     - 2 public subnets in different AZs
     - 2 private subnets in different AZs
     - Internet Gateway
     - Routing configuration:
       - Instances in all subnets can reach each other
       - Instances in public subnets can reach addresses outside VPC and vice-versa

2. **Organize Code**

   - Define variables in a separate variables file.
   - Separate resources into different files for better organization.

3. **Verify Configuration**

   - Execute `terraform plan` to ensure the configuration is correct.
   - Provide a resource map screenshot (VPC -> Your VPCs -> your_VPC_name -> Resource map).

4. **Submit Code**

   - Create a PR with the Terraform code in a new repository.
   - (Optional) Set up a GitHub Actions (GHA) pipeline for the Terraform code.

5. **Additional Tasks**
   - Implement security groups.
   - Create a bastion host for secure access to the private subnets.
   - Organize NAT for private subnets, so instances in private subnet can connect with outside world:
     - Simpler way: create a NAT Gateway
     - Cheaper way: configure a NAT instance in public subnet
   - Document the infrastructure setup and usage in a README file.


### Before use this code, you need add security actions in own repository settings
- AWS_ACCESS_KEY_ID
- AWS_ACCOUNT_ID
- AWS_REGION
- AWS_ROLE_ARN
- AWS_SECRET_ACCESS_KEY
