
param (
    [switch]$evalOnly = $false
)
    
# requires -RunAsAdministrator
Set-StrictMode -Version 3
$ErrorActionPreference = "Stop"

$context = @{
    storePath = "$env:PROGRAMDATA\winenv\store";
}

$contextFile = "$PSScriptRoot/winenv-config/system-context.dhall"
$configFile = "$PSScriptRoot/winenv-config/system-config.dhall"

# Create a temporary file to save our JSON context object to
$tempJSONFile = New-TemporaryFile
trap { Remove-Item $tempJSONFile -Confirm:$false }

[System.IO.File]::WriteAllLines($tempJSONFile, @((ConvertTo-Json -Compress $context)))


# Translate the JSON file to Dhall
$proc = Start-Process "$PSScriptRoot/tools/dhall-to-json/json-to-dhall-x86_64.exe" @(
    "--file", "$tempJSONFile",
    "--output", "$contextFile"
) -NoNewWindow -PassThru -Wait

if ($proc.ExitCode -ne 0) {
    throw 'Command failed'
}

if ($evalOnly) {
    throw 'FIXME: broken'
}

# Instantiate the Dhall config
$proc = Start-Process "powershell" @("-File", "$PSScriptRoot/tools/wrapper-script.ps1", "-Config", "$configFile") -Verb RunAs -PassThru -Wait
if ($proc.ExitCode -ne 0) {
    throw 'Command failed'
}

# Clean up temporary files
Remove-Item $tempJSONFile -Confirm:$false
