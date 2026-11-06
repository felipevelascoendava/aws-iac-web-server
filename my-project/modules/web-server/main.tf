terraform {
  required_providers {
    aws = {
      source = "pulumi/aws"
    }
  }
}

variable "name_prefix" {
  type        = string
  description = "Prefijo único para los nombres de los recursos."
}

variable "owner_name" {
  type        = string
  description = "Nombre que aparecerá en la página."
}

variable "instance_type" {
  type        = string
  description = "Tipo de instancia EC2."
}

variable "subnet_id" {
  type        = string
  description = "ID de la subred pública."
}

variable "security_group_id" {
  type        = string
  description = "ID del security group."
}

variable "common_tags" {
  type        = map(string)
  description = "Etiquetas comunes para los recursos."
}

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "web" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true

  user_data = <<-USERDATA
    #!/bin/bash
    set -euxo pipefail

    dnf install -y httpd
    systemctl enable --now httpd

    cat > /var/www/html/index.html <<'HTML'
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>IaC Web Server</title>
      </head>
      <body>
        <h1>Hi, I am ${var.owner_name} and this is my IaC</h1>
      </body>
    </html>
    HTML
  USERDATA

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ec2"
    Role = "web-server"
  })

  depends_on = [
    data.aws_ssm_parameter.amazon_linux_2023
  ]
}

output "instance_id" {
  description = "ID de la instancia EC2."
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "IP pública de la instancia."
  value       = aws_instance.web.public_ip
}