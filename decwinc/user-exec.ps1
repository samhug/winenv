param (
    [switch]$renderOnly = $false
)

Set-StrictMode -Version 3
$ErrorActionPreference = "Stop"

$dhallConfigPath = "${PSScriptRoot}/dhall-config/user-config.dhall"
$jsonConfigPath = "${PSScriptRoot}/user-config.json"


Write-Output 'Rendering Dhall configuration to a JSON declaration...'

# Render Dhall configuration to a JSON declaration
$proc = Start-Process "${PSScriptRoot}/dhall-config/tools/dhall-to-json.exe" @( `
        '--file', $dhallConfigPath, `
        '--output', $jsonConfigPath `
    ) -NoNewWindow -PassThru -Wait

if ($proc.ExitCode -ne 0) {
    throw 'Command failed'
}


if (!$renderOnly) {
    Write-Output 'Realising JSON declaration in the user environment...'

    # Instantiate the JSON declaration
    $proc = Start-Process "cargo" @( 'run', `
            '--manifest-path', "${PSScriptRoot}/decwinc/Cargo.toml", `
            '--release', '--', `
            '--config', $jsonConfigPath `
        ) -NoNewWindow -PassThru -Wait

    if ($proc.ExitCode -ne 0) {
        throw 'Command failed'
    }
}

Write-Output 'Done!'
