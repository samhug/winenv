param (
    [switch]$evalOnly = $false
)

Set-StrictMode -Version 3
$ErrorActionPreference = "Stop"

$context = @{
    storePath = "$env:LOCALAPPDATA\winenv\store";
    user      = @{ profilePath = $env:USERPROFILE; };
}

$contextFile = "$PSScriptRoot/winenv-config/user-context.dhall"
$configFile = "$PSScriptRoot/winenv-config/user-config.dhall"

# Create a temporary file to save our JSON context object to
$tempJSONFile = New-TemporaryFile
trap { Remove-Item $tempJSONFile -Confirm:$false }

[System.IO.File]::WriteAllLines($tempJSONFile, @((ConvertTo-Json -Compress $context)))


# Translate the JSON file to Dhall
$proc = Start-Process "$PSScriptRoot/tools/dhall-to-json/json-to-dhall.exe" @(
    "--file", "$tempJSONFile",
    "--output", "$contextFile"
) -NoNewWindow -PassThru -Wait

if ($proc.ExitCode -ne 0) {
    throw 'Command failed'
}

# Instantiate the Dhall config
& "$PSScriptRoot/tools/wrapper-script.ps1" `
    -Config "$configFile" `
    -EvalOnly:$evalOnly

    
# Clean up temporary files
Remove-Item $tempJSONFile -Confirm:$false
