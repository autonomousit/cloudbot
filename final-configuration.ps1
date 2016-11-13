

# Copy the CloudBot scripts into the Hubot Scripts folder
$cloudbotFiles = Get-ChildItem C:\windows\temp\cloudbot\cloudbot-master

foreach ($item in $cloudbotFiles) {

    Copy-Item -Path $item.FullName -Destination c:\cloudbot\scripts -Recurse -Container
}

# Restart the Hubot Service
Get-Service *Hubot* | Restart-Service

# Create an Azure Service Principal for CloudBot authentication to Azure
$subscriptionName = Read-Host -Prompt "Enter your Azure Subscription Name"
$credential = Get-Credential

Add-AzureRmAccount -Credential $credential -SubscriptionName $subscriptionName

Import-Module .\New-SelfSignedCertificateEx.ps1
$cert = New-SelfSignedCertificateEx -Subject "CN=cloudbotCert" -KeySpec "Exchange" -FriendlyName "cloudbotCert"

$keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())
$app = New-AzureRmADApplication -DisplayName "CloudBot" -HomePage "https://github.com/autonomousit/cloudbot" -IdentifierUris "https://github.com/autonomousit/cloudbot" -CertValue $keyValue -EndDate $cert.NotAfter -StartDate $cert.NotBefore

New-AzureRmADServicePrincipal -ApplicationId $app.ApplicationId

New-AzureRmRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $app.ApplicationId.Guid

$tenant = (Get-AzureRmSubscription -SubscriptionName $subscriptionName).TenantId

@{"thumbprint" = $cert.Thumbprint; "applicationId" = $app.ApplicationId; "tenantID" = $tenant} | ConvertTo-Json > "C:\cloudbot\scripts\config\serviceprincipals\azure.json"