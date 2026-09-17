# Terraform CLI — Cheatsheet

The free, open-source CLI (not Terraform Enterprise/HCP). Already installed on this PC.

| Command | What it does |
|---|---|
| `terraform init` | Download providers, set up backend. Run once per project / after adding a provider. |
| `terraform fmt` | Auto-format `.tf` files. |
| `terraform validate` | Check syntax without touching AWS. |
| `terraform plan` | Preview what will change. **Always run before apply.** |
| `terraform apply` | Create/update real infrastructure. |
| `terraform destroy` | Delete everything Terraform created. |
| `terraform show` | Print current state in human form. |
| `terraform output` | Print output values (e.g. the instance IP). |
| `terraform state list` | List every resource Terraform is tracking. |

## Core files (this project)

- `provider.tf` — which cloud + provider versions
- `variables.tf` — inputs
- `main.tf` — actual resources (VPC, EC2, etc.)
- `outputs.tf` — values printed after apply
- `terraform.tfvars` — your values (gitignored, you create this)

## Typical flow

```bash
cd terraform
terraform init
terraform plan
terraform apply     # type "yes" to confirm
# ... do your testing ...
terraform destroy   # type "yes" to confirm
```
