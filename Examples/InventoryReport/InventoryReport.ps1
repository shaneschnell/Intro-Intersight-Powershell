#================================================================================================
# Parameters
#================================================================================================
[CmdletBinding()]
param()


#================================================================================================
# Report name & output file
#================================================================================================
$reportName = "InventoryReport"
$report     = @()
$date = Get-Date -Format "yyyy-MM-dd_hh-mm"

if ($env:OS -eq "Windows_NT") {
    $outFile = "$env:USERPROFILE\Downloads\$reportName.$date.xlsx"
} else {
    $outFile = "$env:HOME/Downloads/$reportName.$date.xlsx"
}


#================================================================================================
# Import Modules
#================================================================================================
Import-Module Intersight.PowerShell
Import-Module -Name ImportExcel


#================================================================================================
# Gather Powered-on hosts and Server Profile Names
#================================================================================================
$poweredOnHosts = Get-IntersightComputePhysicalSummary | Where-Object { $_.OperPowerState -eq 'on' }
$allProfiles = (Get-IntersightServerProfile -Top 1000 -Expand 'AssociatedServer($select=Name,Serial)' -Select 'Name,AssociatedServer')


#================================================================================================
# Build result objects with inventory data
#================================================================================================
foreach ($server in $poweredOnHosts) {

    $serverName = $server.Name
    Write-Host "Processing: $serverName"

    # Pull Server Profile Name
    $serverProfile = ($allProfiles.results | Where-Object {$_.AssociatedServer.ActualInstance.Name -eq $serverName}).name

    $reportRow = New-Object PSObject
    $reportRow | Add-Member -MemberType NoteProperty -Name "Name" -Value $serverName
    $reportRow | Add-Member -MemberType NoteProperty -Name "ServerProfile" -Value $serverProfile
    $reportRow | Add-Member -MemberType NoteProperty -Name "Model" -Value $server.Model
    $reportRow | Add-Member -MemberType NoteProperty -Name "Serial" -Value $server.Serial
    $reportRow | Add-Member -MemberType NoteProperty -Name "Firmware" -Value $server.Firmware
    $reportRow | Add-Member -MemberType NoteProperty -Name "ManagementMode" -Value $server.ManagementMode
    $reportRow | Add-Member -MemberType NoteProperty -Name "DeviceMoId" -Value $server.DeviceMoId
    $report += $reportRow
}


#================================================================================================
# Export to Excel
#================================================================================================
$report | Sort-Object Name | Export-Excel -Path $outFile -WorksheetName 'Inventory' -AutoSize -AutoFilter -BoldTopRow

Write-Output "Report exported to: $outFile"
