# Login to Azure
Import-Module Azure

# User Azure Details
$subscriptionName = "My Azure Subscription"
$resourceGroup = "CloudBot-Development"
$location = "Southeast Asia"
$defaultPrefix = "botdev"

$instanceName = $defaultPrefix + "CloudBot"
$storageAccount = $defaultPrefix + "storage"
$dscMOFPath = $env:USERPROFILE + "\Desktop\$instanceName.mof"

# Authenticate to Azure
$credential = Get-Credential
Add-AzureRmAccount -Credential $credential -SubscriptionName $subscriptionName

# Deploy Cloudbot Infrastructure
$deploymentName = "CloudBot-Deployment"
$templateFile =  ".\scripts\config\templates\cloudbot-server.json"
$parameterFile = ".\scripts\config\resourcegroups\cloudbot-development-params.json"

New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroup -TemplateFile $templateFile -TemplateParameterFile $parameterFile

# Upload DSC MOF file
$containerName = "cloudbot-infra"
$context = (Get-AzureRmStorageAccount -ResourceGroupName $resourceGroup -Name $storageaccount).Context

New-AzureStorageContainer -Name $containerName -Permission Off -Context $context

Set-AzureStorageBlobContent -Container $containerName -File $dscMOFPath -Context $context

# Configure Application Server
$extensionName = 'DSCForLinux'
$publisher = 'Microsoft.OSTCExtensions'
$version = '2.0'

$storageKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroup -Name $storageAccount)[0].Value

$storageName = "'" + $storageAccount + "'"
$key = "'" + $storageKey + "'"

$privateConfig = "{
  'StorageAccountName': $storageName,
  'StorageAccountKey': $key
}"

$mofUri = "'https://" + $storageAccount + '.blob.core.windows.net/' + $containerName + '/' + $instanceName + ".mof'"

$publicConfig = "{
  'Mode': 'Push',
  'FileUri': $mofUri
}"

Set-AzureRmVMExtension -ResourceGroupName $resourceGroup -VMName $instanceName -Location $location -Name $extensionName -Publisher $publisher -ExtensionType $extensionName -TypeHandlerVersion $version -SettingString $publicConfig -ProtectedSettingString $privateConfig