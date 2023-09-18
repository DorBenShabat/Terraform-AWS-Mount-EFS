# Terraform AWS Infrastructure Project

This Terraform project provisions a set of AWS resources, including a VPC, Subnet, Security Group, EFS, EC2 instance, and a Lambda function. The EC2 instance is configured to mount the EFS, and the Lambda function is set up to write data to the EFS.

## Resources Created

1. **VPC (`aws_vpc`)**: A Virtual Private Cloud to provide an isolated section of the AWS Cloud.
2. **Subnet (`aws_subnet`)**: A subnet within the VPC.
3. **Security Group (`aws_security_group`)**: Defines inbound and outbound traffic rules.
4. **EFS (`aws_efs_file_system`)**: An Elastic File System for scalable file storage.
5. **Internet Gateway (`aws_internet_gateway`)**: Allows communication between the VPC and the internet.
6. **Route Table (`aws_route_table`)**: Defines routes for directing traffic.
7. **EC2 Instance (`aws_instance`)**: A virtual server to run applications.
8. **IAM Role and Policy (`aws_iam_role` and `aws_iam_role_policy`)**: Allows the Lambda function to assume a role and access specific resources.
9. **EFS Access Point (`aws_efs_access_point`)**: An access point to simplify the EFS access process.
10. **Lambda Function (`aws_lambda_function`)**: A serverless function to write data to the EFS.

## Variables

The `variables.tf` file contains a list of variables used in the project. These variables include AWS region, CIDR blocks, EC2 configurations, EFS configurations, and Lambda configurations.

## User Data Script

The `user_data.sh` script is executed when the EC2 instance is launched. It installs necessary packages, creates a directory for EFS, and mounts the EFS to the instance.

## Lambda Function

The `lambda_function.py` script is a Python-based AWS Lambda function. When triggered, it writes data to a file in the EFS.

## Usage

1. **Initialization**:
   ```bash
   terraform init
    ```
   
2. **Apply**:
   ```bash
   terraform apply
    ```
   
3. **Destroy**:
   ```bash
   terraform destroy
    ```
## Prerequisites

- Terraform installed.
- AWS CLI configured with necessary permissions.
- Ensure the `lambda_function.zip` file (specified in `variables.tf`) contains the `lambda_function.py` script.

## Notes

- Ensure that the AWS region specified in `variables.tf` supports all the services used in this project.
- Always review the Terraform plan output before applying changes to the infrastructure.
- Monitor AWS costs to avoid unexpected charges.

   
