function Test-CloudBotTemplate {
    Param(
        [Parameter(Mandatory)]
        $ResourceGroup,
        [Parameter(Mandatory)]
        $ResourceGroupParams,
        [Parameter(Mandatory)]
        $TemplateFile
    )

    $testResult = $true

    $testResult = Test-TemplateParametersExist -TemplateFile $TemplateFile -ParameterFile $ResourceGroupParams

    if ($testResult -eq $true) {

        $testResult = Test-CloudBotDeployment -ResourceGroup $ResourceGroup -TemplateFile $TemplateFile -ParameterFile $ResourceGroupParams
    
    }

    return $testResult
    
}

function Test-TemplateParametersExist {
    Param(
        [Parameter(Mandatory)]
        $TemplateFile,
        [Parameter(Mandatory)]
        $ParameterFile
    )

    $templateJSON = Get-Content $templateFile | ConvertFrom-Json
    $templateParameters = $templateJSON.parameters | Get-Member | Select Name
    $templateParameters = $templateParameters[4..($templateParameters.length - 1)]

    $paramsJSON = Get-Content $resourceGroupParams | ConvertFrom-Json
    $paramsParameters = $paramsJSON.parameters | Get-Member | Select Name
    $paramsParameters = $paramsParameters[4..($paramsParameters.length - 1)]

    $testResult = $false

    foreach ($parameter in $templateParameters) {

        foreach ($param in $paramsParameters) {

            if ($param.Name -match $parameter.Name) {

                $testResult = $true

            }

        }

    }

    return $testResult

}

function Test-CloudBotDeployment {
    Param(
        [Parameter(Mandatory)]
        $ResourceGroup,
        [Parameter(Mandatory)]
        $ParameterFile,
        [Parameter(Mandatory)]
        $TemplateFile
    )

    # We need to use this strange syntax involving Invoke-Command so we can 
    # run Test-AzureRmResourceGroupDeployment in non-interactive 
        
    $script = {
        $serviceprincipal = Get-Content -Path "$PSScriptRoot\..\serviceprincipals\azure.json" | ConvertFrom-Json
        New-CloudBotAzureSession -CertificateThumbprint $serviceprincipal.thumbprint -ApplicationId $serviceprincipal.applicationID -TenantId $serviceprincipal.tenantID | Out-Null
    
        $result = Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroup -TemplateFile $TemplateFile -TemplateParameterFile $ResourceGroupParams
    
        if ($result) {
                
            $output = $false
            
        }
        else {
                
            $output = $true

        }
    
        return $output
    }

    $testResult = Invoke-Command -ScriptBlock $script -ArgumentList $ResourceGroup, $TemplateFile, $ResourceGroupParams

    return $testResult

}