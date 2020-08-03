# WinEnv


## Notes:

### https://stackoverflow.com/questions/573817/where-are-environment-variables-stored-in-registry
    HKEY_CURRENT_USER\Environment
    HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment


### https://www.technipages.com/show-hidden-files-windows
    [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
    "Hidden"=dword:00000001
    "HideFileExt"=dword:00000000

https://www.red-gate.com/simple-talk/sysadmin/powershell/powershell-desired-state-configuration-the-basics/
https://docs.microsoft.com/en-us/powershell/scripting/dsc/reference/resources/windows/registryresource?view=powershell-7

https://markgossa.blogspot.com/2017/08/learn-powershell-dsc-part-1.html

- https://github.com/dsccommunity/ComputerManagementDsc
    ```powershell
    Find-Module -Name ComputerManagementDsc -Repository PSGallery | Install-Module
    ```


## Aspects of the Windows environment I want to manage declaratively:
-   Install Wireguard
-   Set wallpaper
-   Set Color Theme
-   Windows Taskbar
    -   Dock taskbar on right side
    -   Use small taskbar buttons
    -   Pinned taskbar apps
    -   Don't show contacts on the taskbar
    -   Don't show search on the taskbar
-   Start Menu
    -   Choose which folders appear on Start
        -   Remove "Documents" & "Pictures"
-   Windows Terminal configuration
-   VSCode config & extensions
-   Firefox config & extensions
-   Chocolaty packages?
-   Default Apps
    -   Web Browser
-   Explorer settings
    -   Show hidden files
    -   Display extensions for known file types
    -   Always use "Details" view
    -   Quick access links
-   Clipboard History
    -   Force off
-   AutoHotKey Custom Keyboard Shortcuts
    -   Clipboard AutoTyper
-   Task Scheduler
    -   Delete old Downloads
    -   Facelog
    -   Auto chocolatey udpate?
