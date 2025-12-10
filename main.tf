provider "aws" {
  region = "us-east-1"
}

# ---------- variables ----------
variable "key_name" {
  type    = string
  default = "jenkins"
}

variable "subnet_id" {
  type    = string
  default = "subnet-0398cec97156f1f60"
}

variable "jenkins_allowed_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

# ---------------------------
# Fetch Subnet Details
# ---------------------------
data "aws_subnet" "selected" {
  id = var.subnet_id
}

# ---------------------------
# Security Group
# ---------------------------
resource "aws_security_group" "app_sg" {
  name        = "ansible-app-sg"
  description = "Allow SSH, HTTP, Netdata"
  vpc_id      = data.aws_subnet.selected.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.jenkins_allowed_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Netdata"
    from_port   = 19999
    to_port     = 19999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ansible-app-sg"
  }
}

# ---------------------------
# Backend (Ubuntu)
# ---------------------------
resource "aws_instance" "backend" {
  ami                         = "ami-0ecb62995f68bb549"
  instance_type               = "t3.micro"
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "u21.local"
  }

  user_data = <<-EOF
