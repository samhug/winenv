
Set-StrictMode -Version 3


Set-Location "${PSScriptRoot}"

Install-Module -Name ComputerManagementDsc

Start-Service WinRM

. ./DSC-Configuration1.ps1

Configuration1

Start-DscConfiguration -Path Configuration1 -ComputerName localhost -Wait -Verbose -Force

# check configuration
Get-DscConfiguration