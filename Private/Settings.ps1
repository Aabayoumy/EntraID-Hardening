# Settings.ps1 - Handles loading, getting, and setting module settings

$script:SettingsFilePath = Join-Path $PSScriptRoot '..' 'EntraID-Hardening.settings.json'
$Global:EntraIDHardeningSettings = @{}

function Import-EntraIDHardeningSettings {
    if (Test-Path $script:SettingsFilePath) {
        $json = Get-Content $script:SettingsFilePath -Raw
        $Global:EntraIDHardeningSettings = $json | ConvertFrom-Json
    } else {
        $Global:EntraIDHardeningSettings = @{}
    }
}

function Get-EntraIDHardeningSettings {
    return $Global:EntraIDHardeningSettings
}

function Set-EntraIDHardeningSetting {
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        $Value
    )
    $Global:EntraIDHardeningSettings | Add-Member -NotePropertyName $Name -NotePropertyValue $Value -Force
    $Global:EntraIDHardeningSettings | ConvertTo-Json -Depth 5 | Set-Content -Path $script:SettingsFilePath
}

# Load settings on import
Import-EntraIDHardeningSettings
