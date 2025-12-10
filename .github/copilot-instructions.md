# Copilot Instructions for Intersight PowerShell Repository

## Project Overview
This repository contains PowerShell examples for Cisco Intersight API automation using the `Intersight.PowerShell` module. Each example in `Examples/` is a standalone script with its own README demonstrating specific Intersight automation scenarios.

## PowerShell Environment Requirements
- **PowerShell 7.1+** is required (not Windows PowerShell 5.1)
- Scripts use cross-platform path handling: `$env:USERPROFILE\Downloads` (Windows) and `$env:HOME/Downloads` (macOS/Linux)
- Always check `$env:OS -eq "Windows_NT"` for OS-specific logic

## Authentication Pattern
All scripts assume pre-authentication via environment variables:
```powershell
$env:ApiKeyId = "xxxxx27564612d30dxxxxx/5f21c9d97564612d30dd575a/5f9a8b877564612xxxxxxxx"
$env:ApiKeyFilePath = "C:\SecretKey.txt"
```

Authentication is established once per session using:
```powershell
Set-IntersightConfiguration -BasePath "https://intersight.com" -ApiKeyId $env:ApiKeyId -ApiKeyFilePath $env:ApiKeyFilePath -HttpSigningHeader @("(request-target)", "Host", "Date", "Digest")
```

**Never prompt for credentials inline** - scripts assume `Set-IntersightConfiguration` was called before execution.

## Module Dependencies
Every script requires these modules imported:
```powershell
Import-Module Intersight.PowerShell
Import-Module ImportExcel  # For report generation
```

## Script Structure Pattern
All example scripts follow this structure:
1. **Parameters** - CmdletBinding with mandatory/validated parameters
2. **Report Configuration** - Output file path with timestamp
3. **Module Imports** - `Intersight.PowerShell` and `ImportExcel`
4. **Data Collection** - API calls using `Get-Intersight*` cmdlets
5. **Processing Loop** - Iterate over results, build report objects
6. **Excel Export** - Use `Export-Excel` with `-AutoSize -AutoFilter -BoldTopRow`

See `Examples/CpuUsageReport/CpuUsageReport.ps1` for the canonical pattern.

## Report Generation Standards
- **Filename pattern**: `$reportName.$date.xlsx` where `$date = Get-Date -Format "yyyy-MM-dd_hh-mm"`
- **Output location**: User's Downloads folder (cross-platform aware)
- **Excel formatting**: Always include `-AutoSize -AutoFilter -BoldTopRow`
- **Multi-sheet reports**: Use `-WorksheetName` parameter for each dataset (e.g., `FabricReport.ps1` has Overview, Ethernet, FC sheets)

## Intersight API Patterns

### Query Filtering
Use `-Top` for pagination and `Where-Object` for client-side filtering:
```powershell
$poweredOnHosts = Get-IntersightComputePhysicalSummary | Where-Object { 
    $_.OperPowerState -eq 'on' -and 
    $_.ManagementMode -eq 'Intersight' -and 
    $_.Model -notlike 'UCSB*'
}
```

### Expand Nested Objects
Use `-Expand` for related entities and `-Select` to limit fields:
```powershell
Get-IntersightServerProfile -Top 1000 -Expand 'AssociatedServer($select=Name,Serial)' -Select 'Name,AssociatedServer'
```

### Telemetry Queries
CPU/hardware metrics use the Druid-style telemetry API via `New-IntersightManagedObject`:
- Construct JSON query string with filters, aggregations, intervals
- Convert to hashtable: `$query | ConvertFrom-Json -AsHashTable`
- Execute: `New-IntersightManagedObject -ObjectType telemetry.TimeSerie -AdditionalProperties $queryHash`
- Parse results from `.event` array

See `CpuUsageReport.ps1` lines 60-170 for telemetry query examples.

## Common Data Transformations
### Adding Computed Properties
Use calculated properties with `Select-Object`:
```powershell
Select-Object Name, Size, @{n="From";e={$_.MacBlocks.from}}, @{n="To";e={$_.MacBlocks.to}}
```

### Enriching Data with Cross-References
Pattern for adding related entity names (see `FabricReport.ps1` lines 44-48):
```powershell
$updated_epp = $epp_results | ForEach-Object {
    $currentKey = $_.moid
    $newValue = ($nes | Where-Object { $_.moid -eq $currentKey }).Name
    $_ | Add-Member -NotePropertyName "FI_Name" -NotePropertyValue $newValue -Force -PassThru
}
```

## Key Intersight Object Types
- `ComputePhysicalSummary` - Server inventory and state
- `ServerProfile` - Server profile configurations and associations
- `NetworkElementSummary` - Fabric Interconnect overview
- `EtherPhysicalPort` / `FcPhysicalPort` - Port configurations
- `MacpoolPool` - MAC address pool management

## Example-Specific Notes
- **CpuUsageReport**: Only works with X-Series/M6+ rack servers in IMM mode (firmware 5.2(2.240080)+). Blade servers (`UCSB*`) are explicitly filtered out.
- **FabricReport**: Generates 3-tab Excel report (Overview, Ethernet, FC). Uses `Ancestors` property to link ports back to parent Fabric Interconnect.
- **MacPool**: Demonstrates CRUD operations - Create with `New-`, Read with `Get-`, Delete with `Remove-` cmdlets. Always requires organization reference.

## Creating New Examples
1. Create new folder under `Examples/` with script name
2. Include `<ScriptName>.ps1` and `README.md` in folder
3. README must document: purpose, requirements (modules + auth), parameters, and usage example
4. Link to main README authentication section: `[here](/README.md#authentication-to-intersight)`
5. Add script-specific platform/firmware requirements if applicable
