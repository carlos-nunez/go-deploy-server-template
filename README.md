# Go Deploy Server
This repository contains code to setup websocket servers on demand using terraform. It is optimized for low cost, while maintaining security, by using shared resources where available. 

## Shared Resources

- ECS Cluster (named "ws-cluster")
- VPC (named "ws-vpc")
- Route Table (named "ws_public_route_table")
- Route Table Associations (named "ws_subnet_1_association" and "ws_subnet_2_association")
- Two Subnets (named "ws_subnet_1" and "ws_subnet_2")
- Internet Gateway (named "ws_igw")
- Load Balancer (named "ws_load_balancer")
- Load Balancer Listener (named "ws_listener")
- Security Group (named "ws_security_group")
- SSL Certificate (named "ssl_certificate")

## Roles
- IAM Role (named "ecs_execution_role")
- IAM Role Policy Attachment for the Execution Role -(named "ecs_execution_role_policy")
- IAM Role (named "ecs_task_role")
- IAM Role Policy Attachment for the Task Role (named "ecs_task_role_policy")

## Baseline for Environments
- EC2 Transit Gateway (named "ws_transit_gateway")
- EC2 Transit Gateway VPC Attachment (named "ws_attachment")
- Secrets Manager Secret Version (named "dockerhub_creds")
- ECS Task Definition (named "ws_task_definition")
- ECS Service (named "ws_service")
- CloudWatch Log Group (named "ws_log_group")
- Load Balancer Target Group (named "ws_tg")
- Load Balancer Listener Rule (named "ws_listener_rule")
- Route53 Zone (named "ws_zone")
- Route53 Record (named "ws_subdomain")

## HTTP Deploy & Destroy
The deploy server takes in a deploy and destroy requests from the go-api-template api. 

On a deploy request, it will take in the provided data, such as UUID, and create a folder with that UUID. It will then create the necessary files, such as main.tf and variables.tf, and run the baseline. This will spinup an environment at uuid.domain.com. Once it's done, it sets the status of the websocket server in the database, and commits the tf state to version control.

On a destroy request, terraform destroy is run on the folder with the provided UUID.