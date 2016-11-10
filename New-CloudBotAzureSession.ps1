function New-CloudBotAzureSession {
    
    Param(
        [Parameter(Mandatory)]
        $CertificateThumbprint,
        [Parameter(Mandatory)]
        $ApplicationId,
        [Parameter(Mandatory)]
        $TenantId

    )

    $result = Add-AzureRmAccount -ServicePrincipal -CertificateThumbprint $CertificateThumbprint -ApplicationId $ApplicationId -TenantId $TenantId

    return $result

}