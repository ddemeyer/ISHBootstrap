﻿param (
    [Parameter(Mandatory=$false)]
    [string]$Computer,
    [Parameter(Mandatory=$false)]
    [pscredential]$Credential=$null,
    [Parameter(Mandatory=$true)]
    [string]$DeploymentName
)
$ishBootStrapRootPath=Resolve-Path "$PSScriptRoot\..\.."
$cmdletsPaths="$ishBootStrapRootPath\Source\Cmdlets"
$scriptsPaths="$ishBootStrapRootPath\Source\Scripts"

. $ishBootStrapRootPath\Examples\Cmdlets\Get-ISHBootstrapperContextValue.ps1
. $ishBootStrapRootPath\Examples\ISHDeploy\Cmdlets\Write-Separator.ps1
Write-Separator -Invocation $MyInvocation -Header -Name "Configure"

if(-not $Computer)
{
    & "$scriptsPaths\Helpers\Test-Administrator.ps1"
}

if(-not (Get-Command Invoke-CommandWrap -ErrorAction SilentlyContinue))
{
    . $cmdletsPaths\Helpers\Invoke-CommandWrap.ps1
}        

#region xopus information
#XOPUS License Key
$xopusLicenseKey = Get-ISHBootstrapperContextValue -ValuePath "Configuration.XOPUS.LisenceKey"
$xopusLicenseDomain= Get-ISHBootstrapperContextValue -ValuePath "Configuration.XOPUS.Domain"

$externalId=Get-ISHBootstrapperContextValue -ValuePath "Configuration.ExternalID"
#endegion

$setUIFeaturesScirptBlock= {
    # Set the license and enable the Content Editor
    Set-ISHContentEditor -ISHDeployment $DeploymentName -LicenseKey "$xopusLicenseKey" -Domain $xopusLicenseDomain
    Enable-ISHUIContentEditor -ISHDeployment $DeploymentName
    Write-Host "Content editor enabled and licensed"

    # Enable the Quality Assistant
    Enable-ISHUIQualityAssistant -ISHDeployment $DeploymentName
    Write-Host "Quality assistant enabled"

    # Enable the External Preview using externalid
    Enable-ISHExternalPreview -ISHDeployment $DeploymentName -ExternalId $externalId
    Write-Host "External preview enabled"
}


#Install the packages
try
{
    Invoke-CommandWrap -ComputerName $Computer -Credential $Credential -ScriptBlock $setUIFeaturesScirptBlock -BlockName "Set UI Features on $DeploymentName" -UseParameters @("DeploymentName","xopusLicenseKey","xopusLicenseDomain","externalId")
}
finally
{

}

Write-Separator -Invocation $MyInvocation -Footer -Name "Configure"