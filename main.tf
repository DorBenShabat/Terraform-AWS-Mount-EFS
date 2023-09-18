provider "aws" {
  region = var.aws_region
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
}

# Create Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.subnet_cidr
}

# Create Security Group 
resource "aws_security_group" "common_sg" {
  name        = var.sg_name
  description = "Security Group for Resources"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.allowed_cidr_blocks
  }
}

# Create EFS
resource "aws_efs_file_system" "my_efs" {
  creation_token = var.efs_creation_token
  tags = {
    Name = var.efs_name_tag
  }
}

# Associate Security Group with EFS
resource "aws_efs_mount_target" "mount" {
  file_system_id = aws_efs_file_system.my_efs.id
  subnet_id      = aws_subnet.my_subnet.id
  security_groups = [aws_security_group.common_sg.id]
}

# Add an Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Modify the route table to include an Internet Gateway
resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "rt_to_subnet" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_rt.id
}

# EC2 user data script
data "template_file" "init_script" {
  template = file("${path.module}/user_data.sh")

  vars = {
    efs_ip_address = aws_efs_mount_target.mount.ip_address
  }
}


# Create EC2 instance
resource "aws_instance" "my_ec2" {
  ami           = var.ec2_ami  
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.common_sg.id]  
  associate_public_ip_address = true
  user_data = data.template_file.init_script.rendered  

  tags = {
    Name = var.ec2_instance_name
  }
}

# Create the IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

# Define the IAM Policy Document
data "aws_iam_policy_document" "lambda_vpc_access" {
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]
    resources = ["*"]
  }
}

# Attach the Policy Document to the IAM Role
resource "aws_iam_role_policy" "lambda_role_policy" {
  name = var.lambda_policy_name
  role = aws_iam_role.lambda_role.id

  policy = data.aws_iam_policy_document.lambda_vpc_access.json
}



# Create an EFS Access Point
resource "aws_efs_access_point" "my_efs_access_point" {
  file_system_id = aws_efs_file_system.my_efs.id

  posix_user {
    gid = 1001
    uid = 1001
  }

  root_directory {
    path = "/root"

    creation_info {
      owner_gid   = 1001
      owner_uid   = 1001
      permissions = "755"
    }
  }
}


# Create a Lambda function and associate it with the IAM role, VPC, and EFS Access Point
resource "aws_lambda_function" "my_lambda" {
  function_name = var.lambda_function_name
  handler       = "lambda_function.lambda_handler" 
  runtime       = "python3.8"   
  depends_on = [aws_efs_mount_target.mount]  

  filename      = "${path.module}/${var.lambda_function_filename}" # Path to your Lambda function package

  role          = aws_iam_role.lambda_role.arn

  vpc_config {
    subnet_ids         = [aws_subnet.my_subnet.id]
    security_group_ids = [aws_security_group.common_sg.id]
  }

  file_system_config {
    arn              = aws_efs_access_point.my_efs_access_point.arn
    local_mount_path = "/mnt/efs"
  }

  provisioner "local-exec" {
    command = "aws lambda invoke --function-name ${self.function_name} NUL"
  }
}


