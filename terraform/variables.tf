variable "aws_region" {
  description = "AWS Region in which to create the web server."
  type        = string
  default     = "us-east-1"
}

variable "deployment_id" {
  description = "Unique short identifier for this deployment, such as felipe-lab-01. Use a distinct HCP Terraform workspace/state for each independent deployment."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{3,20}$", var.deployment_id))
    error_message = "deployment_id must be 3-20 characters using lowercase letters, digits, or hyphens."
  }
}

variable "owner_name" {
  description = "Name shown on the sample web page."
  type        = string
  default     = "Felipe Velasco Sanchez"
}

variable "environment" {
  description = "Environment label applied to the resources."
  type        = string
  default     = "dev"
}

variable "http_ingress_cidr" {
  description = "IPv4 range allowed to access the HTTP page. Public demo default."
  type        = string
  default     = "0.0.0.0/0"
}

variable "instance_type" {
  description = "EC2 instance type for the demonstration web server."
  type        = string
  default     = "t3.micro"
}
