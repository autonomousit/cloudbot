# cloudbot
CloudBot is a chatbot that helps you manage your Azure environment

**Pull Requests are VERY welcome**

**NOTE** CloudBot is at a very early proof of concept stage & should be used with caution in production

# Special Thanks
I want to add a special thanks to [Matt Hodge][matthodge] & [David O'Brien][davidobrien] who both did significant work that I am using to deploy & run CloudBot.

Check out their blogs!

[matthodge]: https://hodgkins.io/chatops-on-windows-with-hubot-and-powershell
[davidobrien]: https://david-obrien.net/2015/09/powershell-dsc-to-manage-powershell-modules/

# Installation
First fork or clone the CloudBot repository to your local machine.

CloudBot contains a DSC resource script & data file that will install & configure **MOST** requirements.

Open & modify "cloudbot-dsc-data.psd1". You will need to provide a Slack API Key (see Matt's blog linked above on how to get this value) as well as a Slack handle for the admin auth role.
You'll also need to think of a default naming prefix for your Resources & modify the NodeName accordingly. 

These values are all highlighted in bold below. Leave all other values as default.

```
@{
    AllNodes = @(
        @{
            NodeName = '**botdev**CloudBot'
            Role = 'CloudBot'
            SlackAPIKey = '**xoxb-00000-000000000**'
            HubotBotName = 'cloudbot'
            HubotLogLevel = 'debug'
            InstallPath = 'C:\cloudbot'
            HubotAuthRoles = 'admin=**bhodge**'
        }
    )
}
```

Next, modify the DSC resource script "cloudbot-dsc.ps1". Scroll to the bottom & enter your unique default prefix.

```
$defaultPrefix = "**botdev**"
$instanceName = $defaultPrefix + "NxServer"
$dataFile = "cloudbot-dsc-data.psd1"
$outputPath = $env:USERPROFILE + "\Desktop\$instanceName.mof"
...
```

Finally execute the DSC resource script to output the MOF file to your desktop.

```
.\cloudbot-dsc.ps1
```

CloudBot contains a bootstrap deployment script "bootstrap-cloudbot.ps1" that will deploy the necessary infrastructure into Azure.
You will need to modify & complete several variables before running the script highlighted in bold below.

```
# User Azure Details
$subscriptionName = "**My Azure Subscription**"
$resourceGroup = "CloudBot-Development"
$location = "**Southeast Asia**"
$defaultPrefix = "**botdev**"

$instanceName = $defaultPrefix + "NxServer"
$storageAccount = $defaultPrefix + "storage"
$dscMOFPath = $env:USERPROFILE + "\Desktop\$instanceName.mof"
...
```

Next modify the "defaultPrefix" value in the ARM template parameter file "cloudbot-development-params.json" to match that used elsewhere.
If you don't have a unique value for defaultPrefix the deployment will fail due to DNS namespace clashes.

```
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "defaultPrefix": {
        "value": "**botdev**"
    }, 
    "storageAccountName": {
      "value": "storage"
    },
    ...
```

Execute the bootstrap script and provide your Azure credentials when prompted.
```
.\bootstrap-cloudbot.ps1
```

The deployment will take some time to complete (~15-30 minutes)


