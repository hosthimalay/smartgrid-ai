# Deployment

Run commands from the repository root in PowerShell.

## 1. Configure and validate

```powershell
Copy-Item infrastructure/environments/dev/terraform.tfvars.example infrastructure/environments/dev/terraform.tfvars
terraform fmt -recursive infrastructure
terraform -chdir=infrastructure/environments/dev init -backend=false
terraform -chdir=infrastructure/environments/dev validate
py -m pytest tests
```

To enable the account-wide USD 10 budget alert, add your email to the uncommitted `terraform.tfvars`.

## 2. Review and apply

```powershell
terraform -chdir=infrastructure/environments/dev plan -out=smartgrid.tfplan
terraform -chdir=infrastructure/environments/dev show smartgrid.tfplan
terraform -chdir=infrastructure/environments/dev apply smartgrid.tfplan
```

## 3. Publish the dashboard

```powershell
.\scripts\deploy-dashboard.ps1
```

## 4. Provision and run the simulator

```powershell
.\scripts\provision-simulator.ps1
.\scripts\run-simulator.ps1
```

Provision a simulator certificate once. Re-running the provisioning script creates another active certificate that must later be revoked and deleted deliberately.

## 5. Verify

```powershell
$api = terraform -chdir=infrastructure/environments/dev output -raw api_url
Invoke-RestMethod "$api/health"
Invoke-RestMethod "$api/devices"
terraform -chdir=infrastructure/environments/dev output dashboard_url
```

## Cleanup

Stop the simulator before destroying infrastructure. Empty/versioned development buckets are configured for removal by Terraform, but the separately provisioned IoT certificate must be detached, deactivated and deleted explicitly.
