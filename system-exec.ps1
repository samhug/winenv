#requires -RunAsAdministrator

param (
    [switch]$renderOnly = $false
)

Set-StrictMode -Version 3
$ErrorActionPreference = "Stop"

$environmentName = "system"

$dhallConfigPath = "${PSScriptRoot}/winenv-config/$environmentName-config.dhall"
$jsonConfigPath = "${PSScriptRoot}/$environmentName-config.json"


Write-Output 'Rendering Dhall configuration to a JSON declaration...'

# Render Dhall configuration to a JSON declaration
$proc = Start-Process "${PSScriptRoot}/winenv-config/tools/dhall-to-json.exe" @( `
        '--file', $dhallConfigPath, `
        '--output', $jsonConfigPath `
    ) -NoNewWindow -PassThru -Wait

if ($proc.ExitCode -ne 0) {
    throw 'Command failed'
}


if (!$renderOnly) {
    Write-Output "Realising JSON declaration in the $environmentName environment..."

    # Build winenv-exec
    $proc = Start-Process "cargo" @( 'build', `
            '--manifest-path', "${PSScriptRoot}/winenv-exec/Cargo.toml", `
            '--release'
        ) -NoNewWindow -PassThru -Wait

    if ($proc.ExitCode -ne 0) {
        throw 'Command failed'
    }


    # Instantiate the JSON declaration
    $proc = Start-Process "${PSScriptRoot}/winenv-exec/target/release/winenv-exec.exe" `
        @( '--config', $jsonConfigPath ) `
        -NoNewWindow -PassThru -Wait

    if ($proc.ExitCode -ne 0) {
        throw 'Command failed'
    }
}

Write-Output 'Done!'
