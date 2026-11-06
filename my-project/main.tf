terraform {
  required_providers {
    aws = {
      source = "pulumi/aws"
    }
  }
}

variable "owner_name" {
  description = "Nombre del propietario y texto que aparecerá en la página."
  type        = string
}

variable "vpc_cidr" {
  description = "Rango CIDR de la VPC."
  type        = string
  default     = "10.30.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Rango CIDR de la subred pública."
  type        = string
  default     = "10.30.1.0/24"
}

variable "instance_type" {
  description = "Tipo de instancia EC2."
  type        = string
  default     = "t3.micro"
}

variable "allowed_http_cidrs" {
  description = "Rangos autorizados para visitar la página por HTTP."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

locals {
  deployment_id = pulumi.stack
  name_prefix   = "web-${local.deployment_id}"

  common_tags = {
    Project    = "aws-iac-web-server"
    Owner      = var.owner_name
    Deployment = local.deployment_id
    ManagedBy  = "Pulumi"
  }
}

module "network" {
  source = "./modules/network"

  name_prefix         = local.name_prefix
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  allowed_http_cidrs  = var.allowed_http_cidrs
  common_tags         = local.common_tags
}

module "web_server" {
  source = "./modules/web-server"

  name_prefix        = local.name_prefix
  owner_name         = var.owner_name
  instance_type      = var.instance_type
  subnet_id          = module.network.subnet_id
  security_group_id  = module.network.security_group_id
  common_tags        = local.common_tags
}

output "instance_id" {
  description = "ID de la instancia EC2."
  value       = module.web_server.instance_id
}

output "public_ip" {
  description = "IP pública del servidor."
  value       = module.web_server.public_ip
}

output "web_url" {
  description = "URL pública de la página."
  value       = "http://${module.web_server.public_ip}"
}

output "vpc_id" {
  description = "ID de la VPC."
  value       = module.network.vpc_id
}