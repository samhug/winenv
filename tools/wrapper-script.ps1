param (
    [switch]$evalOnly = $false,
    [Parameter(Mandatory)]$config
)

Set-StrictMode -Version 3

Write-Output 'Evaluating Dhall configuration...'

# Create a temporary file to hold the rendered JSON declaration
$tempJSONFile = New-TemporaryFile
trap { Remove-Item $tempJSONFile -Confirm:$false }

# Render Dhall configuration to a JSON declaration
$proc = Start-Process "$PSScriptRoot/dhall-to-json/dhall-to-json-x86_64.exe" @( `
        '--file', $config, `
        '--output', $tempJSONFile `
    ) -NoNewWindow -PassThru -Wait

if ($proc.ExitCode -ne 0) {
    throw 'Command failed'
}

# If the caller passed the -EvalOnly flag, output the rendered JSON declaration to stdout
if ($evalOnly) {
    Get-Content $tempJSONFile
}

# Otherwise instantiate the JSON declaration
else {
    Write-Output "Instantiating JSON declaration in environment..."

    # If Rust is installed, build winenv-exec from source
    if (Get-Command "cargo" -ErrorAction SilentlyContinue) {
        $proc = Start-Process "cargo" @( 'build', `
            '--manifest-path', "$PSScriptRoot/../winenv-exec/Cargo.toml", `
            '--release'
        ) -NoNewWindow -PassThru -Wait

        if ($proc.ExitCode -ne 0) {
            throw 'Command failed'
        }

        $execPath = "$PSScriptRoot/../winenv-exec/target/release/winenv-exec.exe"
    }

    # If Rust is NOT installed, use the bundled winenv-exec-x86_64.exe
    else {
        Write-Output "Unable to find a Rust toolchain in PATH, using bundled version of winenv-exec.exe"

        $execPath = "$PSScriptRoot/winenv-exec/winenv-exec-x86_64.exe"
    }

    # Instantiate the JSON declaration
    $proc = Start-Process $execPath @( '--config', $tempJSONFile ) -NoNewWindow -PassThru -Wait

    if ($proc.ExitCode -ne 0) {
        throw 'Command failed'
    }
}

# Clean up temporary files
Remove-Item $tempJSONFile -Confirm:$false

Write-Output 'Done!'
