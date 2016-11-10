. .\scripts\New-CloudBotAzureSession.ps1

function New-CloudBotAzureDeployment {

    Param(
        [Parameter(Mandatory)]
        $Template,
        [Parameter(Mandatory)]
        $ResourceGroup,
        [Parameter(Mandatory)]
        $ServicePrincipal,
        [Parameter()]
        $ConfigPath=".\scripts\config\"
    )

    try {

        $servicePrincipalFile = $ConfigPath + "serviceprincipals\" + $ServicePrincipal + ".json"
        $servicePrincipalDetails = Get-Content -Path $servicePrincipalFile | ConvertFrom-Json
    
        New-CloudBotAzureSession -CertificateThumbprint $servicePrincipalDetails.thumbprint -ApplicationId $servicePrincipalDetails.applicationID -TenantId $servicePrincipalDetails.tenantID | Out-Null
      
        try {

            $templateFile = $ConfigPath + "templates\" + $Template + ".json"
            $resourceGroupFile = $ConfigPath + "resourcegroups\" + $ResourceGroup + ".json"
            $resourceGroupDetails = Get-Content -Path $resourceGroupFile | ConvertFrom-Json

            $timestamp = Get-Date -UFormat "%H%M%d%M%Y"
            $deploymentName = "CloudBot-" + "$timestamp"

            try {

                $response = New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $ResourceGroup -TemplateFile $templateFile -TemplateParameterFile $resourceGroupDetails.ParameterFile
                $result = $response.ProvisioningState.ToString()

            }
            catch {

                $msg = $_.Exception.Message
                $result = "Azure Resource Group Deployment Failed: $msg"

            }

        }
        catch {

            $msg = $error[0].Exception
            $result = "Couldn't start Deployment: $msg"

        }
    }
    catch {

        $msg = $error[0].Exception
        $result = "Couldn't open a CloudBot Azure Session: $msg"

    }

    $deployment = @{}
    $deployment.Template = $Template
    $deployment.ResourceGroup = $ResourceGroup
    $deployment.Message = $result  

    return $deployment | ConvertTo-Json

}