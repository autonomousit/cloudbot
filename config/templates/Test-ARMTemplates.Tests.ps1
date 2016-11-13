$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Validating all Templates against Default Resource Group" {

    $rootPath = $PSScriptRoot + '\'
    $templates = Get-ChildItem $rootPath -Filter '*.json'
    $resourcegroup = "$PSScriptRoot\..\ResourceGroups\default-params.json"

    foreach ($arm in $templates) {

        $armFile = $arm.Name
        $armPath = $rootPath + $armFile

        $namePieces = $armFile.Split('.') 
        $name = $namePieces[0..($namePieces.length - 2)]
        
        It "Tests the $name Template against the Default Resource Group" {

            $result = Test-CloudBotTemplate -ResourceGroup "ERG-Infra-Test" -TemplateFile $armPath -ResourceGroupParams $resourcegroup
            
            $result | Should Be $true

        }

    }

}