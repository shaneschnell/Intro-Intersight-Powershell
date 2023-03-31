# Introduction to Intersight PowerShell
The purpose of the reposititory is to show how easy it is to get started with the Intersight PowerShell module.

## Requirements
* PowerShell 7.1 or later is [required](https://github.com/CiscoDevNet/intersight-powershell#11-requirements)
* Download PowerShell 7 for Windows [here](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows)
* Download PowerShell 7 for MacOS [here](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos?view=powershell-7.3#installation-via-direct-download)
* Alternatively, here is a one-liner to download and install PowerShell 7 on Windows
```powershell
iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"
```

## Install Intersight PowerShell Module
```PowerShell
Install-Module -Name Intersight.PowerShell
```

## Update Intersight PowerShell Module *(Optional)*
```PowerShell
Update-Module -Name Intersight.Powershell
```

## Import Intersight PowerShell Module
```PowerShell
Import-Module -Name Intersight.PowerShell
```

## Generate API credentials and import as environment variables:

* Create an API key and secret key file within Intersight.  You can [generate those credentials here.](https://intersight.com/an/settings/api-keys/)
* Import the Variables into your Environment:
```PowerShell
$env:ApiKeyId = "xxxxx27564612d30dxxxxx/5f21c9d97564612d30dd575a/5f9a8b877564612xxxxxxxx" #Changeme
$env:ApiKeyFilePath = "C:\SecretKey.txt" #Changeme
```

## Authentication to Intersight
https://github.com/CiscoDevNet/intersight-powershell#authenticate-the-user
```PowerShell
$onprem = @{
    BasePath = "https://intersight.com"
    ApiKeyId = $env:ApiKeyId
    ApiKeyFilePath = $env:ApiKeyFilePath
    HttpSigningHeader =  @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @onprem
```