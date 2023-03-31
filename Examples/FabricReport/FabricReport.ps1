#================================================================================================
# Variables
#================================================================================================
$reportName = "FabricReport"
$date = Get-Date -Format "yyyy-MM-dd_hh-mm"
if ($env:OS -eq "Windows_NT") {
    $outFile = "$env:userprofile\Downloads\$ReportName.$date.xlsx"
} else {
    $outFile = "$env:HOME/Downloads/$ReportName.$date.xlsx"
}


#================================================================================================
# Import Required Modules
#================================================================================================
Import-Module -Name Intersight.PowerShell
Import-Module -Name ImportExcel


#================================================================================================
# Collect Overview data
#================================================================================================
$nes = Get-IntersightNetworkElementSummary
$nes | Select-Object Name, SwitchID, Model, ManagementMode, BundleVersion, OutOfBandIpAddress, NumEtherPorts, NumEtherPortsConfigured, NumEtherPortsLinkUp, NumFcPorts, NumFcPortsConfigured, NumFcPortsLinkUp | Sort-Object Name, SwitchID | Export-Excel $outFile -WorksheetName 'Overview' -AutoSize -AutoFilter -BoldTopRow


#================================================================================================
# Collect Ethernet port data
#================================================================================================
$epp = Get-IntersightEtherPhysicalPort
$epp_results = $epp | Select-Object PortId, SwitchId, Role, AdminState, OperState, OperSpeed, TransceiverType, @{n="Moid";e={($_.Ancestors | Select-Object -ExpandProperty ActualInstance | Where-Object {$_.ObjectType -eq "NetworkElement"} | Select-Object -ExpandProperty Moid)}} | Where-Object {$_.AdminState -eq "enabled"} | Sort-Object SwitchID, PortId

$updated_epp = $epp_results | ForEach-Object {
    $currentKey = $_.moid
    $newValue = ($nes | Where-Object { $_.moid -eq $currentKey }).Name

    $_ | Add-Member -NotePropertyName "FI_Name" -NotePropertyValue $newValue -Force -PassThru
}

$display_epp = $updated_epp | Select-Object FI_Name, SwitchID, PortId, Role, AdminState, OperState, OperSpeed, TransceiverType | Sort-Object FI_Name, PortId | Export-Excel $outFile -WorksheetName 'Ethernet' -AutoSize -AutoFilter -BoldTopRow


#================================================================================================
# Collect FC port data
#================================================================================================
$fpp = Get-IntersightFcPhysicalPort
$fpp_results = $fpp | Select-Object PortId, SwitchID, AdminState, OperState, MaxSpeed, OperSpeed, Wwn, @{n="Moid";e={($_.Ancestors | Select-Object -ExpandProperty ActualInstance | Where-Object {$_.ObjectType -eq "NetworkElement"} | Select-Object -ExpandProperty Moid)}} | Where-Object {$_.AdminState -eq "enabled"} | Sort-Object SwitchID, portid

$updated_fpp = $fpp_results | ForEach-Object {
    $currentKey = $_.moid
    $newValue = ($nes | Where-Object { $_.moid -eq $currentKey }).Name

    $_ | Add-Member -NotePropertyName "FI_Name" -NotePropertyValue $newValue -Force -PassThru
}

$display_fpp = $updated_fpp | Select-Object FI_Name, SwitchID, PortId, AdminState, OperState, MaxSpeed, OperSpeed, Wwn | Sort-Object FI_Name, PortId | Export-Excel $outFile -WorksheetName 'FC' -AutoSize -AutoFilter -BoldTopRow


#================================================================================================
# Output
#================================================================================================
Write-Output "Report exported here: $outFile"