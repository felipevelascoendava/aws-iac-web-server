# AWS IaC Web Server

Terraform configuration for an Apache web page hosted on Amazon EC2. The network and web server are separated into reusable modules.

## Layout

- `terraform/`: root Terraform configuration.
- `terraform/modules/network/`: VPC, public subnet, Internet Gateway, route table, and association.
- `terraform/modules/web-server/`: security group, Amazon Linux 2023 EC2 instance, and Apache page bootstrap.

## HCP Terraform

Connect the GitHub repository to a VCS-driven workspace and set its Terraform working directory to `terraform`.
Configure AWS authentication in HCP Terraform using dynamic credentials when available. Do not commit AWS access keys or Terraform state.

Set the required Terraform variable `deployment_id` in the workspace, for example `felipe-lab-01`. Use a separate workspace/state for each independent deployment; changing `deployment_id` in one workspace does not preserve its old resources.

The web page is exposed over HTTP on port 80. SSH is not opened to the internet. The instance uses IMDSv2 and an encrypted root volume.

## Cost and cleanup

The EC2 instance, public IPv4 address, and data transfer can incur AWS charges. Review the HCP Terraform plan before applying. When finished, destroy the deployment from its workspace.
