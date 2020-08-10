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


        # ==== Remove "Folders" shortcuts from "This PC" ====

        Registry RemoveMusicLink1 {
            Ensure = "Absent"
            Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}"
            ValueName = ""
        }
        Registry RemoveMusicLink2 {
            Ensure = "Absent"
            Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}"
            ValueName = ""
        }
        Registry RemoveMusicLink3 {
            Ensure = "Absent"
            Key = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}"
            ValueName = ""
        }
        Registry RemoveMusicLink4 {
            Ensure = "Absent"
            Key = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}"
            ValueName = ""
        }

        Registry RemovePicturesLink1 {
            Ensure = "Absent"
            Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}"
            ValueName = ""
        }
        Registry RemovePicturesLink2 {
            Ensure = "Absent"
            Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}"
            ValueName = ""
        }
        Registry RemovePicturesLink3 {
            Ensure = "Absent"
            Key = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}"
            ValueName = ""
        }
        Registry RemovePicturesLink4 {
            Ensure = "Absent"
            Key = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}"
            ValueName = ""
        }

        Registry RemoveVideosLink1 {
            Ensure = "Absent"
            Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}"
            ValueName = ""
        }
        Registry RemoveVideosLink2 {
            Ensure = "Absent"
            Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}"
            ValueName = ""
        }
        Registry RemoveVideosLink3 {
            Ensure = "Absent"
            Key = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}"
            ValueName = ""
        }
        Registry RemoveVideosLink4 {
            Ensure = "Absent"
            Key = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}"
            ValueName = ""
        }

        Registry Remove3DObjectsLink1 {
            Ensure = "Absent"
            Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
            ValueName = ""
        }
        # Registry Remove3DObjectsLink2 {
        #     Ensure = "Absent"
        #     Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}"
        #     ValueName = ""
        # }
        Registry Remove3DObjectsLink3 {
            Ensure = "Absent"
            Key = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
            ValueName = ""
        }
        # Registry Remove3DObjectsLink4 {
        #     Ensure = "Absent"
        #     Key = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}"
        #     ValueName = ""
        # }

    }

}