# Fabric Interconnect Port Configuration Report
This report gathers general information about all Fabric Interconnects in your Intersight account as well as ethernet and FC port information.

It will export a xlsx file in the downloads directory.

## Requirements
1. Authenticated to Intersight with API Key.  See instructions [here](/README.md#authentication-to-intersight)

2. Modules:
   1. ```PowerShell
      Install-Module -Name Intersight.PowerShell
      ```
   1. ```PowerShell
      Install-Module -Name ImportExcel
      ```

## Usage
```Powershell
.\FabricReport.ps1
```