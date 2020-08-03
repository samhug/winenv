configuration Configuration1 #Configuration1 is the name of the configuration
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    # https://github.com/dsccommunity/ComputerManagementDsc
    Import-DSCResource -ModuleName ComputerManagementDsc


    node ("localhost") #List the servers you'll be targeting. It'll deploy the settings within node {}
    {

        WindowsCapability OpenSSHClient
        {
            Name     = 'OpenSSH.Client~~~~0.0.1.0'
            Ensure   = 'Present'
        }

        WindowsCapability XPSViewer
        {
            Name   = 'XPS.Viewer~~~~0.0.1.0'
            Ensure = 'Absent'
        }

        # File InstallerFile #File is a DSC Resource
        # {
        #     Ensure = "Present"
        #     SourcePath = "\\contchisql01\Software\Installer.msi"
        #     DestinationPath = "C:\Software\Installer.msi"          
        # }

        # Disable the inital screen at the login/lock screen. Eliminates needing to press a key
        # before typing login credentials
        Registry DisableLockScreen {
            Ensure = "Present"
            Key = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
            ValueName = "NoLockScreen"
            ValueData = "1"
            ValueType = "Dword"
        }

        Registry DisableCortana {
            Ensure = "Present"
            Key = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
            ValueName = "AllowCortana"
            ValueData = "0"
            ValueType = "Dword"
        }

        Registry DisableTelemetry {
            Ensure = "Present"
            Key = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
            ValueName = "AllowTelemetry"
            ValueData = "0"
            ValueType = "Dword"
        }

        Registry SetHardwareClockToUTC {
            Ensure = "Present"
            Key = "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation"
            ValueName = "RealTimeIsUniversal"
            ValueData = "1"
            ValueType = "Dword"
        }

    }

}