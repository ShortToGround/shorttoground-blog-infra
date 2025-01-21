terraform {
  backend "s3" {
    bucket = "shorttoground-blog"
    key    = "terraform/terraform.tfstate"
    region = "us-east-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-2"
}

# TODO: Find out a way to check to see if this security group already exists. 
# This will fail if it already exists I think.
resource "aws_security_group" "web_server_defaults" {
    name = "web_server_defaults"
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = -1
        to_port     = -1
        protocol    = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = var.SSH_PUBLIC_KEY
}

# TODO: Find out a way to check for the ssh keypair and VPC names. 
# This will fail if either of them already exist.
resource "aws_instance" "app_server" {
  ami           = "ami-0ec3d9efceafb89e0" # Debian 11
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.web_server_defaults.id]
  key_name = "ssh_key"
  tags = {
    Name = "static-site"
  }
}

provider "cloudflare" {
  api_token = var.CLOUDFLARE_API_TOKEN
}

resource "cloudflare_record" "blog" {
    value = aws_instance.app_server.public_ip
    zone_id = var.CLOUDFLARE_ZONE_ID
    name = "blog"
    type = "A"
    allow_overwrite = true # Not usually recommended but perfectly fine for this project
}