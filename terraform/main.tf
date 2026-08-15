provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAABCDEFGHIJKLMNOP"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}

# NOTE: no required_providers block with a version constraint here.
# NOTE: no backend block — state is local, shared team infra.

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

# Commented-out old approach, left here "just in case"
# resource "aws_instance" "legacy_server" {
#   ami           = "ami-0123456789abcdef0"
#   instance_type = "t2.micro"
# }

output "db_password" {
 value = aws_db_instance.app_db.password
}