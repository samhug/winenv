
Set-StrictMode -Version 3

Install-Module -Name ComputerManagementDsc

Start-Service WinRM

. ./DSC-Configuration1.ps1

# Set-Location "C:\DSC\"

Configuration1

Start-DscConfiguration -Path Configuration1 -ComputerName localhost -Wait -Verbose -Force

# check configuration
Get-DscConfiguration