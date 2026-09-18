# --- All inputs live here. Override via terraform.tfvars ---

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use (see docs/03-aws-cli-profiles.md)"
  type        = string
  default     = "test"
}

variable "project_name" {
  description = "Prefix used to name/tag every resource"
  type        = string
  default     = "tf-training"
}

variable "vpc_cidr" {
  description = "CIDR block for the training VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the single public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance size (t3.micro = free-tier eligible in most regions)"
  type        = string
  default     = "t3.micro"
}

variable "my_ip_cidr" {
  description = "Your public IP in CIDR form, e.g. 1.2.3.4/32 (used to lock down SSH). Get it: curl -s ifconfig.me"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to your existing SSH public key, imported as the AWS key pair. Generate one if needed: ssh-keygen -t ed25519 -f ~/.ssh/aws_vm"
  type        = string
  default     = "~/.ssh/aws_vm.pub"
}

variable "ssh_private_key_path" {
  description = "Path to the matching private key (only used to print the ssh command below)"
  type        = string
  default     = "~/.ssh/aws_vm"
}
