#================================================================================================
# Parameters
#================================================================================================
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('1day','7days','30days')][string]$duration
)


#================================================================================================
# Report name & output file
#================================================================================================
$reportName = "CpuUsageReport"
$report       = @()
$date = Get-Date -Format "yyyy-MM-dd_hh-mm"

if ($env:OS -eq "Windows_NT") {
    $outFile = "$env:USERPROFILE\Downloads\$reportName.$date.xlsx"
} else {
    $outFile = "$env:HOME/Downloads/$reportName.$date.xlsx"
}

switch ($duration) {
    '1day' {
        $period   = "PT4H" # 4-hour granularity
        $timespan = -1
    }
    '7days' {
        $period   = "P1D" # 1-day granularity
        $timespan = -7
    }
    '30days' {
        $period   = "P7D" # 1-week granularity
        $timespan = -30
    }
}

#================================================================================================
# Time window (last 30 days)
#================================================================================================
$startTime = [DateTime]::UtcNow.AddDays($timespan)
$endTime   = [DateTime]::UtcNow

$startIso = $startTime.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
$endIso   = $endTime.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")

#================================================================================================
# Import Modules
#================================================================================================
Import-Module Intersight.PowerShell
Import-Module -Name ImportExcel

#================================================================================================
# Gather Powered-on hosts that are IMM mode, Server Profile Names
#================================================================================================
$poweredOnHosts = Get-IntersightComputePhysicalSummary | Where-Object { $_.OperPowerState -eq 'on' -and $_.ManagementMode -eq 'Intersight' -and $_.Model -notlike 'UCSB*'} | Select-Object DeviceMoId, Name, Model, Serial, Firmware #-First 10
$allProfiles = (Get-IntersightServerProfile -Top 1000 -Expand 'AssociatedServer($select=Name,Serial)' -Select 'Name,AssociatedServer')

#================================================================================================
# Build result objects with per-host CPUAvg
#================================================================================================
foreach ($server in $poweredOnHosts) {

  $serverName = $server.Name
  Write-Host "ServerName: $serverName"

    # Telemetry query JSON
    $query = @"
  {
    "queryType": "groupBy",
    "dataSource": "PhysicalEntities",
    "granularity": {
      "type": "period",
      "period": "$period",
      "timeZone": "America/Los_Angeles",
      "origin": "$startIso"
    },
    "intervals": [
      "$startIso/$endIso"
    ],
    "dimensions": [],
    "filter": {
      "type": "and",
      "fields": [
        {
          "type": "selector",
          "dimension": "host.name",
          "value": "$serverName"
        },
        {
          "type": "selector",
          "dimension": "instrument.name",
          "value": "hw.cpu"
        }
      ]
    },
    "aggregations": [
      {
        "type": "longSum",
        "name": "count",
        "fieldName": "hw.cpu.utilization_c0_count"
      },
      {
        "type": "doubleSum",
        "name": "hw.cpu.utilization_c0-Sum",
        "fieldName": "hw.cpu.utilization_c0"
      },
      {
        "type": "thetaSketch",
        "name": "endpoint_count",
        "fieldName": "host.id"
      }
    ],
    "postAggregations": [
      {
        "type": "expression",
        "name": "hw-cpu-utilization_c0-Avg",
        "expression": "(\"hw.cpu.utilization_c0-Sum\" / \"count\")"
      }
    ]
  }
"@

    # Convert JSON string to hashtable for the Intersight call
    $queryHash = $query | ConvertFrom-Json -AsHashTable

    # Run the query
    $results = New-IntersightManagedObject -ObjectType telemetry.TimeSerie -AdditionalProperties $queryHash | ConvertFrom-Json

    # Calculate CPU average for THIS server
    $cpuavg = ($results.event | Measure-Object -Property 'hw-cpu-utilization_c0-Avg' -Average).Average

    # Pull Server Profile Name
    $serverProfile = ($allProfiles.results | Where-Object {$_.AssociatedServer.ActualInstance.Name -eq $serverName}).name

    $reportRow = New-Object PSObject
    $reportRow | Add-Member -MemberType NoteProperty -Name "ServerName" -Value $serverName
    $reportRow | Add-Member -MemberType NoteProperty -Name "ServerProfile" -Value $serverProfile
    $reportRow | Add-Member -MemberType NoteProperty -Name "PID" -Value $server.Model
    $reportRow | Add-Member -MemberType NoteProperty -Name "Serial" -Value $server.Serial
    $reportRow | Add-Member -MemberType NoteProperty -Name "Firmware" -Value $server.Firmware
    $reportRow | Add-Member -MemberType NoteProperty -Name "DeviceMoId" -Value $server.DeviceMoId
    $reportRow | Add-Member -MemberType NoteProperty -Name "CPUAvg" -Value $cpuavg
    $report += $reportRow
}

#================================================================================================
# Export to Excel
#================================================================================================
$report | Sort-Object Name | Export-Excel -Path $outFile -WorksheetName 'Overview' -AutoFilter -BoldTopRow