# Inventory Report
This report gathers basic inventory information for all powered on servers in your Intersight account.

It will export a xlsx file in the downloads directory.

## Collected Information
- Server Name
- Server Profile Name
- Model
- Serial Number
- Firmware Version
- Device MoID

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
.\InventoryReport.ps1
```
