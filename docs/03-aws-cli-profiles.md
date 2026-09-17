# AWS CLI — Profiles Cheatsheet

## Profile "test" (training / access keys)

You manually add this to your credentials file:

- macOS/Linux: `~/.aws/credentials`
- Windows: `%USERPROFILE%\.aws\credentials` (same file, `aws configure` creates it either way)

```ini
[test]
aws_access_key_id = AKIA...
aws_secret_access_key = ...
```

**Use it** — 3 ways, pick one:

```bash
# A) per-command flag (identical on macOS/Linux/Windows)
aws sts get-caller-identity --profile test

# B) set for the whole terminal session
```

| Shell | Set profile | Read it back |
|---|---|---|
| bash/zsh (macOS/Linux) | `export AWS_PROFILE=test` | `echo $AWS_PROFILE` |
| PowerShell (Windows 11 default) | `$env:AWS_PROFILE = "test"` | `echo $env:AWS_PROFILE` |
| cmd.exe (Windows) | `set AWS_PROFILE=test` | `echo %AWS_PROFILE%` |

```bash
# C) set as your permanent default (same command, all platforms)
aws configure set default.profile test
```

Check which identity is active (all platforms):
```bash
aws sts get-caller-identity
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

**Switch active profile** — same table as above (bash: `export AWS_PROFILE=prod`, PowerShell: `$env:AWS_PROFILE = "prod"`, cmd: `set AWS_PROFILE=prod`).

## Quick reference

| Task | Command |
|---|---|
| List all profiles | `aws configure list-profiles` |
| Show active profile config | `aws configure list` |
| Who am I? | `aws sts get-caller-identity` |
| Switch profile (session) | see table above |
| SSO login/refresh | `aws sso login --profile <name>` |

## Windows notes

- Windows 11 ships PowerShell by default — use it (not cmd.exe) for the commands above.
- AWS CLI v2 install: `winget install Amazon.AWSCLI` (or the MSI from AWS).
- Everything else on this page (`aws ...` commands) is identical to macOS/Linux — only env-var syntax differs.
