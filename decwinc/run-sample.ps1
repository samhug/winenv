#requires -RunAsAdministrator
Set-StrictMode -Version 3
$ErrorActionPreference = "Stop"

function CheckExitStatus {
    if (-not $?)
    {
        throw 'Command failed'
    }
}

# Render Dhall configuration to a JSON declaration
& "${PSScriptRoot}/dhall-config/dhall-to-json.exe" `
    --file "${PSScriptRoot}/dhall-config/decwinc.dhall" `
    --output "${PSScriptRoot}/decwinc-config.json"
CheckExitStatus


# Instantiate the JSON declaration
& cargo run `
    --manifest-path "${PSScriptRoot}/decwinc/Cargo.toml" `
    --release `
    -- `
    --config "${PSScriptRoot}/decwinc-config.json"
CheckExitStatus
