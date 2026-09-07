param([string]$Profile = "default", [string]$Region = "eu-west-1", [string]$EnvironmentPath = "infrastructure/environments/dev")
$ErrorActionPreference = "Stop"
$certDir = Join-Path $PSScriptRoot "..\certificates"
New-Item -ItemType Directory -Force -Path $certDir | Out-Null
$policy = terraform -chdir=$EnvironmentPath output -raw iot_policy_name
$endpoint = terraform -chdir=$EnvironmentPath output -raw iot_endpoint
$result = aws iot create-keys-and-certificate --set-as-active --certificate-pem-outfile "$certDir\device.pem.crt" --public-key-outfile "$certDir\public.key" --private-key-outfile "$certDir\private.key" --region $Region --profile $Profile | ConvertFrom-Json
aws iot attach-policy --policy-name $policy --target $result.certificateArn --region $Region --profile $Profile
Invoke-WebRequest -Uri "https://www.amazontrust.com/repository/AmazonRootCA1.pem" -OutFile "$certDir\AmazonRootCA1.pem"
@{ endpoint = $endpoint; certificate_arn = $result.certificateArn } | ConvertTo-Json | Set-Content "$certDir\metadata.json"
Write-Host "Certificate provisioned under certificates/. This directory is ignored by Git."

