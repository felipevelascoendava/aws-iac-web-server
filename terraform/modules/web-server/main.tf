data "aws_ssm_parameter" "amazon_linux_2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_security_group" "web" {
  name        = "${var.name_prefix}-web-sg"
  description = "Allow public HTTP access to the demo page; no inbound SSH."
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from the configured IPv4 range"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.http_ingress_cidr]
  }

  egress {
    description = "Outbound access for OS package installation and updates"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-web-sg" })
}

resource "aws_instance" "web" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023_ami.value
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_size = 8
    volume_type = "gp3"
  }

  user_data = <<-USERDATA
    #!/bin/bash
    set -euxo pipefail
    dnf install -y httpd
    cat > /var/www/html/index.html <<'HTML'
    <!doctype html>
    <html lang="en">
      <head><meta charset="utf-8"><title>My IaC web server</title></head>
      <body><h1>Hi, I am ${var.owner_name} and this is my IaC</h1></body>
    </html>
    HTML
    systemctl enable --now httpd
  USERDATA

  tags = merge(var.tags, { Name = "${var.name_prefix}-ec2" })
}
