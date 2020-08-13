#requires -RunAsAdministrator

param (
    [switch]$renderOnly = $false
)

Set-StrictMode -Version 3
$ErrorActionPreference = "Stop"


function CheckExitStatus {
    if (-not $?)
    {
        throw 'Command failed'
    }
}

Write-Output 'Rendering Dhall configuration to a JSON declaration...'

# Render Dhall configuration to a JSON declaration
& "${PSScriptRoot}/dhall-config/tools/dhall-to-json.exe" `
    --file "${PSScriptRoot}/dhall-config/system-config.dhall" `
    --output "${PSScriptRoot}/system-config.json"
CheckExitStatus

if (!$renderOnly) {
    Write-Output 'Realising JSON declaration in the system environment...'

    # Instantiate the JSON declaration
    & cargo run `
        --manifest-path "${PSScriptRoot}/decwinc/Cargo.toml" `
        --release `
        -- `
        --config "${PSScriptRoot}/system-config.json"
    CheckExitStatus
}

Write-Output 'Done!'
