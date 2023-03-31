# Create a Macpool using the Intersight PowerShell Module.

## View Existing Mac Pools:
```PowerShell
$myOrg = Get-IntersightOrganizationOrganization -name "default"

Get-IntersightMacpoolPool -Organization $myOrg | Select-Object Name, Size, Assigned, @{n="From";e={$_.MacBlocks.from}}, @{n="To";e={$_.MacBlocks.to}} | Sort-Object Name | Format-Table -AutoSize
```

## Create New Mac Pool:
```PowerShell
$mymacPool = Initialize-IntersightMacpoolBlock -From "00:25:B5:C0:FF:EE" -Size 128

New-IntersightMacpoolPool -AssignmentOrder Sequential -Description "Intro to pwsh Demo" -MacBlocks $mymacPool -Name "PwshDemo" -Organization $myOrg
```


## View Results
```PowerShell
Get-IntersightMacpoolPool -Organization $myOrg | Select-Object Name, Size, Assigned, @{n="From";e={$_.MacBlocks.from}}, @{n="To";e={$_.MacBlocks.to}} | Sort-Object Name | Format-Table -AutoSize
```

## Remove Macpool on Intersight
```PowerShell
Get-IntersightMacpoolPool -Name "PwshDemo" -Organization $myOrg | Remove-IntersightMacpoolPool
```