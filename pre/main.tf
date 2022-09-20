terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  profile = "juanvelascoaws"
  region  = "eu-west-3"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    # Con esta configuración, junto con el "most_recent", siempre usaremos la última imagen generada.
    values = ["app-symfony-packer-aws-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["545663651640"] # juanvelasco
}

resource "aws_instance" "instancia-curso-aws" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"

  credit_specification {
    cpu_credits = "unlimited"
  }

  # Asociamos el par de claves que ya teníamos creado
  key_name = "aws_juanvelasco"

  # Asociamos el grupo de seguridad a la instancia
  vpc_security_group_ids = [aws_security_group.http-server-terraform.id]
}

# Creamos un grupo de seguridad para la instancia
resource "aws_security_group" "http-server-terraform" {
  name        = "http-server-terraform"
  description = "Allow HTTP(s) and SSH inbound traffic"

  ingress {
    description      = "TLS from the Internet"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP from the Internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH from the Internet"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
