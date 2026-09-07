param([string]$Profile = "default", [string]$EnvironmentPath = "infrastructure/environments/dev")
$ErrorActionPreference = "Stop"
$apiUrl = terraform -chdir=$EnvironmentPath output -raw api_url
$bucket = terraform -chdir=$EnvironmentPath output -raw dashboard_bucket_name
$distribution = terraform -chdir=$EnvironmentPath output -raw cloudfront_distribution_id
$env:VITE_API_URL = $apiUrl
npm --prefix dashboard install
npm --prefix dashboard run build
aws s3 sync dashboard/dist "s3://$bucket" --delete --profile $Profile
aws cloudfront create-invalidation --distribution-id $distribution --paths "/*" --profile $Profile
Write-Host "Dashboard uploaded. URL: $(terraform -chdir=$EnvironmentPath output -raw dashboard_url)"

