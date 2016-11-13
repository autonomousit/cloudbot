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

These values are all highlighted below. Leave all other values as default.

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

CloudBot contains a bootstrap deployment script "bootstrap-cloudbot.ps1" that will deploy the necessary infrastructure into Azure.
You will need to modify & complete several variables before running the script highlighted in bold below.

```
# User Azure Details
$subscriptionName = "**My Azure Subscription**"
$resourceGroup = "CloudBot-Development"
$location = "**Southeast Asia**"
$defaultPrefix = "**botdev**"
...
```

Execute the bootstrap script and provide your Azure credentials when prompted.
```
.\bootstrap-cloudbot.ps1
```

The deployment will take some time to complete (~30 minutes)

# Final Configuration
There are a few steps not yet automated that require you to login via RDP to complete the installation.

Once logged into the CloudBot seerver open a Powershell prompt with Administrative privileges.

First set the local Execution Policy to "Unrestricted", the scripts & code for CloudBot currently aren't signed.

```
Set-ExecutionPolicy Unrestricted
```

Next run the "c:\windows\temp\cloudbot\cloudbot-master\final-configuration.ps1" script to install the CloudBot scripts & register a Servcie Principal in Azure for CloudBot to authenticate with.

You'll need to provide your Azure credentials when prompted.

```
.\final-configuration.ps1
```
