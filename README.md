# Terraform + AWS Training

Hands-on: deploy a VPC + 1 EC2 VM with Terraform, test internet access, tear it down.

## Contents

- [`docs/01-terraform-cli.md`](docs/01-terraform-cli.md) — Terraform CLI cheatsheet
- [`docs/02-vscode-setup.md`](docs/02-vscode-setup.md) — VS Code setup
- [`docs/03-aws-cli-profiles.md`](docs/03-aws-cli-profiles.md) — AWS CLI, profile "test", SSO for prod
- [`docs/04-aws-console-clickops.md`](docs/04-aws-console-clickops.md) — same environment, built by hand in the AWS console (for comparison)
- [`terraform/`](terraform/) — the actual infra code (VPC, subnet, IGW, security group, EC2)

## Prerequisites (already installed on this PC)

- Terraform CLI ✅ (`terraform -version`)
- AWS CLI ✅ (`aws --version`)
- You manually add credentials under profile `test` in `~/.aws/credentials` (see doc 03)

## Quick start

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars: set my_ip_cidr (get it via: curl -s ifconfig.me)

export AWS_PROFILE=test
terraform init
terraform plan
terraform apply       # type "yes"
```

## Test internet access

```bash
terraform output ssh_command   # copy the command it prints
$(terraform output -raw ssh_command)
# once inside the VM:
curl -s https://checkip.amazonaws.com   # should print the VM's public IP = internet works
```

## Tear down

```bash
terraform destroy    # type "yes"
```

## What gets built

```
Internet
   │
Internet Gateway ── Route Table (0.0.0.0/0 → IGW)
   │
 VPC (10.0.0.0/16)
   │
Public Subnet (10.0.1.0/24)
   │
EC2 VM (t3.micro, public IP, SSH from your IP only)
```
