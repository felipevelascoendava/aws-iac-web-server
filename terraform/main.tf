locals {
  name_prefix = "${var.deployment_id}-web"

  common_tags = {
    Project     = "aws-iac-web-server"
    Environment = var.environment
    Deployment  = var.deployment_id
    ManagedBy   = "Terraform"
    Owner       = var.owner_name
  }
}

module "network" {
  source = "./modules/network"

  name_prefix = local.name_prefix
  tags        = local.common_tags
}

module "web_server" {
  source = "./modules/web-server"

  name_prefix        = local.name_prefix
  subnet_id          = module.network.public_subnet_id
  vpc_id             = module.network.vpc_id
  http_ingress_cidr  = var.http_ingress_cidr
  instance_type      = var.instance_type
  owner_name         = var.owner_name
  tags               = local.common_tags
}
