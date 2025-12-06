# CPU Usage Report
This report gathers the Average CPU Usage over the past month for all powered on servers that are using IMM

It will export a xlsx file in the downloads directory.

## Server CPU Metrics
The Server CPU Metrics (Physical Processor -> Active CPU Utilization) is supported only on X-Series, Rack-Servers M6+ platform only in IMM mode.  The minimum version is 5.2(2.240080)

## Parameters
There is a required parameter named duration.  There are three options: 1day, 7days, or 30days.  

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
.\CpuUsageReport.ps1 -duration 1day
```