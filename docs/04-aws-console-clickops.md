# AWS Console — "Point and Click" Steps

Manually building the exact same environment the [`terraform/`](../terraform/) code creates, using only the AWS web console. No CLI, no code. Use this to compare against `terraform apply` (1 command, ~30s) vs. this (~15 clicks across 5 services, ~10-15 min).

Region: **us-east-1** (N. Virginia) — same as `aws_region` default. Set it in the top-right region dropdown before starting.

## What we're building

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

Same names Terraform uses (prefix `tf-training-`), so you can eyeball the two side by side in the console afterward.

## 1. VPC

**VPC console → Your VPCs → Create VPC**

- Resources to create: **VPC only**
- Name tag: `tf-training-vpc`
- IPv4 CIDR: `10.0.0.0/16`
- IPv6 CIDR block: No IPv6 CIDR block
- Tenancy: Default
- Create VPC

DNS hostnames and DNS resolution are **on by default** for new VPCs — matches `enable_dns_support`/`enable_dns_hostnames = true` in the Terraform. No extra step needed (but worth checking: select the VPC → Actions → Edit VPC settings → confirm both are checked).

## 2. Internet Gateway

**VPC console → Internet Gateways → Create internet gateway**

- Name tag: `tf-training-igw`
- Create internet gateway
- On the next screen: **Actions → Attach to VPC** → select `tf-training-vpc` → Attach internet gateway

## 3. Public Subnet

**VPC console → Subnets → Create subnet**

- VPC: `tf-training-vpc`
- Subnet name: `tf-training-public-subnet`
- Availability Zone: pick the first one listed for the region (e.g. `us-east-1a`) — matches `data.aws_availability_zones.available.names[0]`
- IPv4 CIDR block: `10.0.1.0/24`
- Create subnet

Then enable auto-assign public IPs (matches `map_public_ip_on_launch = true`):

- Select the subnet → **Actions → Edit subnet settings**
- Check **Enable auto-assign public IPv4 address**
- Save

## 4. Route Table

**VPC console → Route Tables → Create route table**

- Name: `tf-training-public-rt`
- VPC: `tf-training-vpc`
- Create route table

Add the internet route:

- Select the route table → **Routes** tab → Edit routes → Add route
- Destination: `0.0.0.0/0`
- Target: Internet Gateway → `tf-training-igw`
- Save changes

Associate it with the subnet:

- **Subnet associations** tab → Edit subnet associations
- Check `tf-training-public-subnet`
- Save associations

## 5. Security Group

**EC2 console → Security Groups → Create security group**

- Name: `tf-training-sg`
- Description: `Allow SSH from my IP, allow all outbound`
- VPC: `tf-training-vpc`
- Inbound rules → Add rule:
  - Type: SSH (auto-fills port 22, TCP)
  - Source: **My IP** (console auto-fills your current public IP as a `/32`) — matches `var.my_ip_cidr`
  - Description: `SSH from my IP only`
- Outbound rules: leave the default (`All traffic`, `0.0.0.0/0`) — this is already there by default and matches the Terraform `egress` block
- Create security group

## 6. Key Pair

**EC2 console → Key Pairs → Create key pair**

- Name: `tf-training-key`
- Key pair type: RSA
- Private key file format: `.pem`
- Create key pair — **the browser downloads `tf-training-key.pem` automatically, this is the only time you can get it**

Lock down permissions like Terraform's `file_permission = "0600"` does automatically — SSH refuses to use a key file that's readable by others:

**macOS/Linux:**
```bash
mv ~/Downloads/tf-training-key.pem .
chmod 600 tf-training-key.pem
```

**Windows (PowerShell)** — POSIX `chmod` doesn't exist; restrict the NTFS ACL instead:
```powershell
Move-Item "$env:USERPROFILE\Downloads\tf-training-key.pem" .
icacls tf-training-key.pem /inheritance:r
icacls tf-training-key.pem /grant:r "$env:USERNAME:(R)"
```

## 7. EC2 Instance

**EC2 console → Instances → Launch instances**

- Name: `tf-training-vm`
- AMI: search "Amazon Linux 2023 AMI" → pick the default one offered (Free tier eligible, x86_64) — matches `al2023-ami-*-x86_64`
- Instance type: `t3.micro`
- Key pair: `tf-training-key`
- Network settings → Edit:
  - VPC: `tf-training-vpc`
  - Subnet: `tf-training-public-subnet`
  - Auto-assign public IP: Enable (should already be inherited from the subnet setting in step 3)
  - Firewall (security groups): **Select existing security group** → `tf-training-sg`
- Launch instance

## Connect

Wait ~1 min for status checks to pass, then grab the public IP from the instance details page and:

```bash
ssh -i tf-training-key.pem ec2-user@<public-ip>
```

Identical command on Windows 11 — PowerShell includes the OpenSSH client by default. If you get a "permissions are too open" / "UNPROTECTED PRIVATE KEY FILE" error, re-run the `icacls` commands above.

```bash
curl -s https://checkip.amazonaws.com   # should print the VM's public IP = internet works
```

## Tear down (in this order — dependencies block deletion otherwise)

1. **EC2 → Instances** → select `tf-training-vm` → Instance state → Terminate instance (wait until it's fully terminated)
2. **EC2 → Key Pairs** → select `tf-training-key` → Actions → Delete (also delete your local `.pem` file)
3. **EC2 → Security Groups** → select `tf-training-sg` → Actions → Delete security groups
4. **VPC → Route Tables** → select `tf-training-public-rt` → Actions → Delete route table (subnet association is removed automatically)
5. **VPC → Internet Gateways** → select `tf-training-igw` → Actions → Detach from VPC, then Actions → Delete internet gateway
6. **VPC → Subnets** → select `tf-training-public-subnet` → Actions → Delete subnet
7. **VPC → Your VPCs** → select `tf-training-vpc` → Actions → Delete VPC

## Terraform vs. Console

| | Terraform | Console |
|---|---|---|
| Steps | `terraform apply` | ~15 clicks across 5 screens |
| Repeatable | Yes — identical every run | No — manual, error-prone to repeat exactly |
| Teardown | `terraform destroy` (correct order, automatic) | 7 manual steps, ordering matters, easy to leave orphans (and get billed) |
| Drift detection | `terraform plan` shows any manual changes | None — console changes are invisible until you go look |
| Review before applying | Yes — `plan` is a diff you read first | No — each click applies immediately |
| Source of truth | The `.tf` files, in git | Whatever's currently in the console, undocumented |

The console is useful for understanding *what* each resource is and exploring options interactively. For anything you'll build more than once, Terraform wins.
