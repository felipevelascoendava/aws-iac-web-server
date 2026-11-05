variable "name_prefix" {
  description = "Prefix used to name web server resources."
  type        = string
}

variable "subnet_id" {
  description = "Public subnet in which to launch the web server."
  type        = string
}

variable "vpc_id" {
  description = "VPC for the web server security group."
  type        = string
}

variable "http_ingress_cidr" {
  description = "IPv4 range allowed to access HTTP."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "owner_name" {
  description = "Name rendered on the web page."
  type        = string
}

variable "tags" {
  description = "Tags applied to web server resources."
  type        = map(string)
}
