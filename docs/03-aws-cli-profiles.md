# AWS CLI — Profiles Cheatsheet

## Profile "test" (training / access keys)

You manually add this to `~/.aws/credentials`:

```ini
[test]
aws_access_key_id = AKIA...
aws_secret_access_key = ...
```

**Use it** — 3 ways, pick one:

```bash
# A) per-command flag
aws sts get-caller-identity --profile test

# B) export for the whole terminal session
export AWS_PROFILE=test
aws sts get-caller-identity      # no --profile needed now

# C) set as your permanent default
aws configure set default.profile test
```

Check which identity/profile is active:
```bash
aws sts get-caller-identity
echo $AWS_PROFILE
```

Terraform uses this same profile via `var.aws_profile` ("test" by default — see `terraform/variables.tf`).

---

## Production profiles — AWS SSO (IAM Identity Center)

Never put long-lived access keys in prod. Use SSO instead:

```bash
aws configure sso
```

You'll be prompted for:
| Prompt | Example |
|---|---|
| SSO start URL | `https://your-org.awsapps.com/start` |
| SSO region | `us-east-1` |
| (browser opens → login + approve) | |
| Account / Role | pick from list |
| CLI default region | `us-east-1` |
| CLI profile name | e.g. `prod` |

**Use it:**
```bash
aws sts get-caller-identity --profile prod
```

**Re-login when the SSO session expires** (~8–12h typically):
```bash
aws sso login --profile prod
```

**Switch active profile** — same as above:
```bash
export AWS_PROFILE=prod
```

## Quick reference

| Task | Command |
|---|---|
| List all profiles | `aws configure list-profiles` |
| Show active profile config | `aws configure list` |
| Who am I? | `aws sts get-caller-identity` |
| Switch profile (session) | `export AWS_PROFILE=<name>` |
| SSO login/refresh | `aws sso login --profile <name>` |
