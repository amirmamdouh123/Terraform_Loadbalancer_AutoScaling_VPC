![Terraform](https://img.icons8.com/color/144/000000/terraform.png)      ![AWS](https://img.icons8.com/color/144/000000/amazon-web-services.png)


# Integrating External LB with Autoscaling & CloudWatch using Terraform

## Project Overview
This project provisions an AWS cloud architecture using Terraform. The setup includes an Application Load Balancer (ALB), EC2 instances in an Auto Scaling Group, NAT Gateways for outbound traffic from private subnets, and CloudWatch for monitoring.

## Architecture Components

### **Networking**
- **VPC**: A custom Virtual Private Cloud (VPC) to host the resources.
- **Subnets**: Public and private subnets across multiple Availability Zones for high availability.
- **Internet Gateway**: Enables internet access for public subnets.
- **NAT Gateway**: Allows outbound internet access for instances in private subnets.

### **Compute**
- **EC2 Instances**: Deployed inside private subnets through an Auto Scaling Group.
- **Launch Template**: Used to define EC2 configuration including AMI, instance type, and user data.
- **Auto Scaling Group**: Automatically scales the number of EC2 instances based on demand.

### **Load Balancing**
- **Application Load Balancer (ALB)**: Distributes traffic across EC2 instances in private subnets.

### **Monitoring & Logging**
- **CloudWatch**: Collects and monitors logs and metrics from EC2 instances and the ALB.

## Terraform Implementation
### **Resources Created**
- **VPC and Subnets**
- **Internet Gateway and NAT Gateway**
- **Application Load Balancer (ALB)**
- **Auto Scaling Group with EC2 Instances**
- **Security Groups for Access Control**
- **CloudWatch Monitoring**

## Deployment Instructions
1. **Initialize Terraform:**
   ```sh
   terraform init
   ```
2. **Plan Deployment:**
   ```sh
   terraform plan
   ```
3. **Apply Configuration:**
   ```sh
   terraform apply -auto-approve
   ```

## Cleanup
To destroy all resources, run:
```sh
terraform destroy -auto-approve
```

## Notes
- Ensure AWS credentials are configured before deployment.

## Author
- **Amir Mamdouh Helmy**

