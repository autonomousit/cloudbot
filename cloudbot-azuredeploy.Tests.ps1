$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

. .\New-CloudBotAzureSession.ps1

Describe "Run a new Azure Deployment using KEMP-Bot" {
 
    Mock Get-Content -Verifiable { return "{'tenantId': '1234', 'applicationId': '1234', 'thumbprint': '1234'}" } -ParameterFilter {$Path -like "*validserviceprincipal*"}
    Mock Get-Content -Verifiable { return "{'Location': 'North Europe', 'ParameterFile': 'my-parameter-file.json'}" } -ParameterFilter {$Path -like "*validresourcegroup*"} 
    Mock New-CloudBotAzureSession -Verifiable { return "New Azure Session" }

    Context "The Template, ResourceGroup & Service Principal are all valid" {

        Mock New-CloudBotAzureDeployment -Verifiable { return "Succeeded" }

        It "Deploys an ARM Template from the catalog to valid Resource Group using a valid Service Principal" {

            $json = New-CloudBotAzureDeployment -Template "ValidTemplate" -ResourceGroup "ValidResourceGroup" -ServicePrincipal "ValidServicePrincipal"
            $result = $json | ConvertFrom-Json
        
            $result.Template | Should Be "ValidTemplate"
            $result.ResourceGroup | Should be "ValidResourceGroup"
            $result.Message | Should Be "Succeeded"
        }

        Assert-VerifiableMocks

    }
    
    Context "One or more parameters is Invalid or Undefined" {

        Mock Get-Content -Verifiable { throw Exception } -ParameterFilter {$Path -like "*undefinedserviceprincipal*"}
        Mock Get-Content -Verifiable { throw Exception } -ParameterFilter {$Path -like "*undefinedresourcegroup*" }
        Mock New-CloudBotAzureDeployment -Verifiable { return "Azure Resource Group Deployment Failed: Error Message" } -ParameterFilter {$Template -like "*invalidtemplate*"}

        It "Deploys an Invalid ARM Template" {

            $json = New-CloudBotAzureDeployment -Template "InvalidTemplate" -ResourceGroup "ValidResourceGroup" -ServicePrincipal "ValidServicePrincipal"
            $result = $json | ConvertFrom-Json
            
            $result.Message | Should BeLike "Azure Resource Group Deployment Failed: *"

        }

        It "Deploys to an UnDefined Resource Group" {

            $json = New-CloudBotAzureDeployment -Template "ValidTemplate" -ResourceGroup "UndefinedResourceGroup" -ServicePrincipal "ValidServicePrincipal"
            $result = $json | ConvertFrom-Json

            $result.Message | Should BeLike "Couldn't run Deployment: *"

        }

        It "Deploys to an UnDefined Service Principal" {
        
            $json = New-CloudBotAzureDeployment -Template "ValidTemplate" -ResourceGroup "ValidResourceGroup" -ServicePrincipal "UndefinedServicePrincipal"
            $result = $json | ConvertFrom-Json

            $result.Message | Should BeLike "Couldn't open an Azure Session: *"
    
        } 

        Assert-VerifiableMocks

    }

    Assert-VerifiableMocks
}