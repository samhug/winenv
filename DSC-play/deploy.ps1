. ./DSC-Configuration1.ps1

Set-Location "C:\DSC\"

Configuration1

Start-DscConfiguration -Path Configuration1 -ComputerName localhost -Wait -Verbose -Force

# check configuration
Get-DscConfiguration