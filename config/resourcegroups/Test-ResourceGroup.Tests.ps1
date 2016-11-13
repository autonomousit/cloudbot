$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Validating all Resource Groups against Default ARM Template" {

    $rootPath = $PSScriptRoot + '\'
    $resourceGroups = Get-ChildItem $rootPath -Filter '*params.json'
    $template = "$PSScriptRoot\..\templates\default.json"

    foreach ($group in $resourceGroups) {

        $groupFile = $group.Name
        $groupPath = $rootPath + $groupFile

        $namePieces = $groupFile.Split('.') 
        $name = $namePieces[0..($namePieces.length - 2)]
        
        It "Tests the Default Template against the $name Resource Group" {

            $result = Test-CloudBotTemplate -ResourceGroup "ERG-Infra-Test" -TemplateFile $template -ResourceGroupParams $groupPath
            
            $result | Should Be $true

        }

    }

}