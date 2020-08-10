#requires -RunAsAdministrator

Set-StrictMode -Version 3

$REPO = (git -C "${PSScriptRoot}" rev-parse --show-toplevel)

Write-Host $REPO

git -C "${REPO}" fetch origin master
git -C "${REPO}" rebase --autostash origin/master

# TODO: Wait until Microsoft makes this not suck
# # Install winget
# $outputPath = "${env:TEMP}/winget.appxbundle"
# Invoke-WebRequest -Uri 'https://github.com/microsoft/winget-cli/releases/download/v0.1.42101-preview/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.appxbundle' -OutFile $outputPath
# Add-AppxPackage -Path $outputPath

choco install `
    --confirm `
    --limit-output `
    "${REPO}/chocolatey/packages.config"

Register-ScheduledTask `
    -TaskName "Host - Update" `
    -Xml (get-content "${REPO}/scheduled-tasks/update-host.xml" | out-string) `
    -Force
