output "web_url" {
  description = "Public URL of the Apache web page."
  value       = "http://${module.web_server.public_ip}"
}

output "instance_id" {
  description = "EC2 instance ID."
  value       = module.web_server.instance_id
}

output "public_ip" {
  description = "Public IPv4 address of the web server."
  value       = module.web_server.public_ip
}

output "vpc_id" {
  description = "VPC created for this deployment."
  value       = module.network.vpc_id
}
