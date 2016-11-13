# Login to Azure
Import-Module Azure

# User Azure Details
$subscriptionName = "My Azure Subscription"
$resourceGroup = "CloudBot-Development"
$location = "Southeast Asia"
$defaultPrefix = "botdev"

$instanceName = $defaultPrefix + "CloudBot"
$storageAccount = $defaultPrefix + "storage"

# Authenticate to Azure
$credential = Get-Credential
Add-AzureRmAccount -Credential $credential -SubscriptionName $subscriptionName

# Deploy Cloudbot Infrastructure
$deploymentName = "CloudBot-Deployment"
$templateFile =  ".\scripts\config\templates\cloudbot-server.json"
$parameterFile = ".\scripts\config\resourcegroups\cloudbot-development-params.json"

New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroup -TemplateFile $templateFile -TemplateParameterFile $parameterFile

# Publish DSC Configuration
Publish-AzureRmVMDscConfiguration -ResourceGroupName $resourceGroup -ConfigurationPath ".\cloudbot-dsc.ps1" -ConfigurationDataPath ".\cloudbot-dsc-data.psd1" -StorageAccountName $storageAccount

Set-AzureRmVMDscExtension -ResourceGroupName $resourceGroup -VMName $instanceName -ArchiveBlobName "cloudbot-dsc.ps1.zip" -ArchiveStorageAccountName $storageAccount -ConfigurationName "cloudbot" -WmfVersion 5.0 -Version 2.17