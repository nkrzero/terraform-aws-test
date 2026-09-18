# Terraform + AWS Training

Hands-on: deploy a VPC + 1 EC2 VM with Terraform, test internet access, tear it down.

## Contents

- [`docs/01-terraform-cli.md`](docs/01-terraform-cli.md) — Terraform CLI cheatsheet
- [`docs/02-vscode-setup.md`](docs/02-vscode-setup.md) — VS Code setup
- [`docs/03-aws-cli-profiles.md`](docs/03-aws-cli-profiles.md) — AWS CLI, profile "test", SSO for prod
- [`docs/04-aws-console-clickops.md`](docs/04-aws-console-clickops.md) — same environment, built by hand in the AWS console (for comparison)
- [`terraform/`](terraform/) — the actual infra code (VPC, subnet, IGW, security group, EC2)

## Prerequisites

Works on **macOS, Windows 11, and Linux**.

- Terraform CLI — `terraform -version` (macOS: `brew install terraform`; Windows: `winget install Hashicorp.Terraform`)
- AWS CLI v2 — `aws --version` (macOS: `brew install awscli`; Windows: `winget install Amazon.AWSCLI`)
- SSH client — built in on both (macOS: `ssh`; Windows 11: OpenSSH client ships with PowerShell by default)
- An SSH key pair at `~/.ssh/aws_vm` / `~/.ssh/aws_vm.pub` (default path — override via `ssh_public_key_path`/`ssh_private_key_path` if yours is elsewhere). No key yet? `ssh-keygen -t ed25519 -f ~/.ssh/aws_vm`
- You manually add credentials under profile `test` in your AWS credentials file (see [doc 03](docs/03-aws-cli-profiles.md) — path differs by OS)

## Quick start

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars      # Windows PowerShell: Copy-Item terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars: set my_ip_cidr (get it via: curl -s ifconfig.me   — works on both bash and PowerShell)
```

Set the AWS profile for this terminal session:

| Shell | Command |
|---|---|
| bash/zsh (macOS/Linux) | `export AWS_PROFILE=test` |
| PowerShell (Windows 11) | `$env:AWS_PROFILE = "test"` |

```bash
terraform init
terraform plan
terraform apply       # type "yes"
```

## Test internet access

```bash
terraform output -raw ssh_command
```

Copy the printed command and run it (identical on macOS/Linux/Windows 11 — PowerShell has a built-in OpenSSH client). If Windows refuses your private key with an "UNPROTECTED PRIVATE KEY FILE" error, restrict its ACL with the `icacls` commands in [doc 04](docs/04-aws-console-clickops.md#6-key-pair) (same fix, any key file).

Once inside the VM:
```bash
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
