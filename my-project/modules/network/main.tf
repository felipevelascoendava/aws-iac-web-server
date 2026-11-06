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

variable "vpc_cidr" {
  type        = string
  description = "Rango CIDR de la VPC."
}

variable "public_subnet_cidr" {
  type        = string
  description = "Rango CIDR de la subred pública."
}

variable "allowed_http_cidrs" {
  type        = list(string)
  description = "Orígenes permitidos para HTTP."
}

variable "common_tags" {
  type        = map(string)
  description = "Etiquetas comunes para los recursos."
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "web" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "web" {
  vpc_id = aws_vpc.web.id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-igw"
  })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.web.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-public-subnet"
    Tier = "public"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.web.id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-public-rt"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.web.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "web" {
  name        = "${var.name_prefix}-web-sg"
  description = "Allow configured HTTP traffic to the web server"
  vpc_id      = aws_vpc.web.id

  ingress {
    description = "HTTP from configured CIDR ranges"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_http_cidrs
  }

  egress {
    description = "Outbound traffic for OS package installation and updates"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-web-sg"
  })
}

output "vpc_id" {
  description = "ID de la VPC."
  value       = aws_vpc.web.id
}

output "subnet_id" {
  description = "ID de la subred pública."
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "ID del security group para el servidor web."
  value       = aws_security_group.web.id
}