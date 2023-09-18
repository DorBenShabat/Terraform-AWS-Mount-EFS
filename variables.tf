
variable "aws_region" {
  description = "The AWS region to deploy resources in."
  default     = "us-east-1"
}


variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "sg_name" {
  description = "Name for the security group"
  default = "common-sg"
}


variable "subnet_cidr" {
  description = "CIDR block for the subnet."
  default     = "10.0.1.0/24"
}


variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks that are allowed to access resources."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}


variable "ec2_ami" {
  description = "AMI ID for the EC2 instance."
  default     = "ami-042e8287309f5df03"  
}

variable "ec2_instance_type" {
  description = "Instance type for the EC2 instance."
  default     = "t2.micro"
}

variable "ec2_instance_name" {
  description = "Name tag for the EC2 instance."
  default     = "dor-instance"
}


variable "efs_creation_token" {
  description = "Unique name for EFS creation."
  default     = "my-efs"
}

variable "efs_name_tag" {
  description = "Name tag for the EFS."
  default     = "my-efs"
}

variable "lambda_role_name" {
  description = "The name for the Lambda IAM role"
  default     = "LambdaVPCAccessRole"
}

variable "lambda_policy_name" {
  description = "The name for the Lambda IAM policy"
  default     = "LambdaVPCAccessPolicy"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  default     = "My-Lambda-Function"
}

variable "lambda_function_filename" {
  description = "Path to the Lambda function package"
  default     = "lambda_function.zip"
}