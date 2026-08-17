provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# NOTE: backend configuration should be added for shared/team state (e.g., S3 + DynamoDB).

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow web and SSH traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
 cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "m5.24xlarge" # oversized default, no variable
  count         = 5
 
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
  Name = "app-server-${count.index}"
  }
}

resource "aws_s3_bucket" "app_data" {
  bucket        = "my-company-app-data-prod"
  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_iam_policy" "app_policy" {
  name = "app-full-access"
 
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_db_instance" "app_db" {
  identifier              = "app-db"
  engine                  = "postgres"
  instance_class          = "db.r5.4xlarge"
  allocated_storage       = 100
  username                = "postgres"
  password                = "SuperSecretPassword123!"
  skip_final_snapshot     = true
  deletion_protection     = false
  publicly_accessible     = true
}


output "db_password" {
 value = aws_db_instance.app_db.password
}