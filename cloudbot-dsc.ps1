configuration cloudbot {

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -Name MSFT_xRemoteFile -ModuleName @{ModuleName="xPSDesiredStateConfiguration"; RequiredVersion="5.0.0.0"}
    Import-DscResource -ModuleName @{ModuleName="Hubot"; RequiredVersion="1.1.5"}
    Import-DscResource -ModuleName PowerShellModule

    node $AllNodes.Where({$_.Role -Like 'CloudBot'}).NodeName { 

        # Configure the Environmental Variables used by Hubot
        Environment hubotadapter
        {
            Name = 'HUBOT_ADAPTER'
            Value = 'slack'
            Ensure = 'Present'
        }

        Environment hubotdebug
        {
            Name = 'HUBOT_LOG_LEVEL'
            Value = $Node.HubotLogLevel
            Ensure = 'Present'
        }

        Environment hubotslacktoken
        {
            Name = 'HUBOT_SLACK_TOKEN'
            Value = $Node.SlackAPIKey
            Ensure = 'Present'
        }

        Environment hubotauthadmins
        {
            Name = 'HUBOT_AUTH_ROLES'
            Value = $Node.HubotAuthRoless
            Ensure = 'Present'
        }

        # Install the Pre-Requisites using the same Hubot user
        HubotPrerequisites installPreqs
        {
            Ensure = 'Present'
        }

        # Download the HubotWindows Repo
        xRemoteFile hubotRepo
        {
            DestinationPath = "$($env:Temp)\HubotWindows.zip"
            Uri = "https://github.com/MattHodge/HubotWindows/releases/download/0.0.2/HubotWindows-0.0.2.zip"
        }

        # Extract the Hubot Repo
        Archive extractHubotRepo
        {
            Path = "$($env:Temp)\HubotWindows.zip"
            Destination = $Node.HubotBotPath
            Ensure = 'Present'
            DependsOn = '[xRemoteFile]hubotRepo'
        }

        # Download the CloudBot Repo
        xRemoteFile cloudbotRepo
        {
            DestinationPath = "$($env:Temp)\cloudbot-master.zip"
            Uri = "https://github.com/autonomousit/cloudbot/archive/master.zip"
        }

        # Extract the CloudBot Repo
        Archive extractCloudbotRepo
        {
            Path = "$($env:Temp)\cloudbot-master.zip"
            Destination = "$($env:Temp)"
            Ensure = 'Present'
            DependsOn = '[xRemoteFile]cloudbotRepo'
        }


        # Install Powershell Modules required by CloudBot Scripts
        PSModuleResource installAzureModule
        {
            Ensure = "Present"
            Module_Name = "Azure"
        }

        PSModuleResource installAzureRMModule
        {
            Ensure = "Present"
            Module_Name = "AzureRM"
        }

        # Install Hubot
        HubotInstall installHubot
        {
            BotPath = $Node.HubotBotPath
            Ensure = 'Present'
            DependsOn = '[Archive]extractHubotRepo'
        }
        
        # Install Hubot as a service using NSSM
        HubotInstallService hubotservice
        {
            BotPath = $Node.HubotBotPath
            ServiceName = "Hubot_$($Node.HubotBotName)"
            BotAdapter = $Node.HubotAdapter
            Ensure = 'Present'
            DependsOn = '[HubotInstall]installHubot'
        }
    }
}

$defaultPrefix = "botdev"
$instanceName = $defaultPrefix + "NxServer"
$dataFile = "cloudbot-dsc-data.psd1"
$outputPath = $env:USERPROFILE + "\Desktop\$instanceName.mof"

cloudbot -InstanceName $instanceName -ConfigurationData $dataFile -OutputPath $outputPath