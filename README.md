# WinEnv


## Aspects of Microsoft Windows I want to manage declaratively:

- ### Computer Settings
    - [x] Chocolaty packages
    - [ ] Install & configure Wireguard
    - [ ] Set environment variables
        - `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment`

- ### User Settings
    - [ ] Set environment variables
        - `HKEY_CURRENT_USER\Environment`
    - [ ] Set wallpaper
    - [ ] Set Color Theme
    - [ ] Windows Taskbar
        - [ ] Dock taskbar on right side
            - https://www.tenforums.com/tutorials/57280-change-taskbar-location-screen-windows-10-a.html
        - [ ] Use small taskbar buttons
        - [ ] Pinned taskbar apps
            - https://4sysops.com/archives/configure-pinned-programs-on-the-windows-taskbar-with-group-policy/
        - [ ] Don't show contacts on the taskbar
        - [ ] Don't show search on the taskbar
    - [ ] Start Menu
        - Choose which folders appear on Start
            -   Remove "Documents" & "Pictures"
    - [ ] Windows Terminal configuration
    - [ ] VSCode config & extensions
    - [ ] Firefox config & extensions
    - [ ] Default Apps
        - [ ] Web Browser
    - [ ] Explorer settings
        - [x] Show hidden files
        - [x] Display extensions for known file types
        - [ ] Always use "Details" view
        - [ ] Quick access links
    - [ ] Disable clipboard history
    - [ ] AutoHotKey Custom Keyboard Shortcuts
        - [ ] Clipboard AutoTyper
    - [ ] Task Scheduler
        - [x] Delete old Downloads
        - [ ]  Facelog
        - [ ]  Auto chocolatey udpate?




--
## Links & Reference Materials:
*A mostly unorganized dumping ground —*

- [#dhall on  StackOverflow](https://stackoverflow.com/questions/tagged/dhall)

- IP Addresses in Dhall
    - https://github.com/dhall-lang/dhall-lang/issues/217
    - https://github.com/duairc/dhall-ip-address
    - https://stackoverflow.com/questions/54579764/how-do-i-represent-a-tuple-in-dhall
    
- Powershell Desired State Configuration
    - https://www.red-gate.com/simple-talk/sysadmin/powershell/powershell-desired-state-configuration-the-basics/
    - https://docs.microsoft.com/en-us/powershell/scripting/dsc/reference/resources/windows/registryresource?view=powershell-7
    - https://markgossa.blogspot.com/2017/08/learn-powershell-dsc-part-1.html
    - https://github.com/dsccommunity/ComputerManagementDsc
    - `Find-Module -Name ComputerManagementDsc -Repository PSGallery | Install-Module`