# Configure Terraform in VS Code

1. Install extension: **HashiCorp Terraform** (publisher: HashiCorp, id `hashicorp.terraform`).
   ```bash
   code --install-extension hashicorp.terraform
   ```
   If `code` isn't recognized (Windows): re-run the VS Code installer and check "Add to PATH", or install the extension from the Extensions panel (`Ctrl+Shift+X`) instead.
2. Install extension: **AWS Toolkit** (optional, publisher: Amazon) — helpful for browsing resources.
3. Reload VS Code. Open the `terraform/` folder.
4. Confirm it works: open `main.tf` → you should see syntax highlighting + autocomplete.
5. Format on save (optional, recommended). Add to `.vscode/settings.json`:
   ```json
   {
     "[terraform]": {
       "editor.formatOnSave": true,
       "editor.defaultFormatter": "hashicorp.terraform"
     },
     "[terraform-vars]": {
       "editor.formatOnSave": true,
       "editor.defaultFormatter": "hashicorp.terraform"
     }
   }
   ```
6. Terminal → use VS Code's integrated terminal for all `terraform` / `aws` commands.
