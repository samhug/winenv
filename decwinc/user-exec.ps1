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
    --file "${PSScriptRoot}/dhall-config/user-config.dhall" `
    --output "${PSScriptRoot}/user-config.json"
CheckExitStatus

if (!$renderOnly) {
    Write-Output 'Realising JSON declaration in the user environment...'

    # Instantiate the JSON declaration
    & cargo run `
        --manifest-path "${PSScriptRoot}/decwinc/Cargo.toml" `
        --release `
        -- `
        --config "${PSScriptRoot}/user-config.json"
        # --config "${PSScriptRoot}/dhall-config/user-config.dhall"
        
    CheckExitStatus
}

Write-Output 'Done!'
