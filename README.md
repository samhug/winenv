# WinEnv

*This project is a work in progress and I don't want to be responsible for what you do to your computer with it*


## Overview

This project has two primary components: the executor and the configuration library

- ### [Executor](https://github.com/samhug/winenv/tree/master/winenv-exec)
    - A small program written in [Rust](https://www.rust-lang.org/) whose goal is to implement a minimal set of primitives for declarativly managing a Windows system.

- ### [Configuration Library](https://github.com/samhug/winenv/tree/master/winenv-config)
    - A collection of expressions written in [Dhall](https://dhall-lang.org/) that can be composed to allow flexible and extensible declaration 

- The files `winenv-config/system-config.dhall` and `winenv-config/user-config.dhall` contain the base expressions for the system and user environments

- The two powershell scripts in the project root `system-exec.ps1` and `user-exec.ps1` are the entrypoints for instantiating the system and user environments
    - These scripts will generate a context object containing information about the environment and save it to `winenv-config/system-context.dhall` or `winenv-config/user-context.dhall`
    - They will then run `tools/wrapper-script.ps1` passing either `winenv-config/system-config.dhall` or `winenv-config/user-config.dhall` to be evaluated and instantiated


## Challenges:
- Windows Registry
    - Registry values containing an array of bytes where different subsets of the array control distinct features (See for [example](https://superuser.com/questions/253249/windows-registry-entries-for-default-explorer-view))
        - Currently there is no declarative granularity smaller than the registry value as a whole


## Aspects of Windows I want to manage declaratively:

- ### Computer Settings
    - [x] Chocolaty packages
    - [ ] Install & configure Wireguard
    - [ ] Set computer scoped environment variables
        - `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment`
    - [ ] Disable clipboard history
        - https://www.majorgeeks.com/content/page/how_to_disable_clipboard_history_in_windows_10.html
    - [ ] Scheduled tasks running as admin
        - [ ] Auto update chocolatey packages?

- ### User Settings
    - [ ] Set user scoped environment variables
        - `HKEY_CURRENT_USER\Environment`
    - [ ] Set wallpaper
    - [ ] Set color theme
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
        - `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`
    - [ ] VSCode config & extensions
        - `%APPDATA%\Code\User\settings.json`
    - [ ] Firefox config & extensions
    - [ ] Default Apps
        - [ ] Web Browser
    - [ ] Explorer settings
        - [x] Show hidden files
        - [x] Display extensions for known file types
        - [ ] Always use "Details" view
            - https://superuser.com/questions/253249/windows-registry-entries-for-default-explorer-view
        - [ ] Quick access links
    - [ ] AutoHotKey Custom Keyboard Shortcuts
        - [ ] Clipboard AutoTyper
    - [x] Scheduled tasks running as user
        - [x] Delete old Downloads
        - [ ] Facelog


---

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

---


*Inspired by [NixOS](https://nixos.org/), [Home Manager](https://github.com/rycee/home-manager), and [PowerShell Desired State Configuration](https://docs.microsoft.com/en-us/powershell/scripting/dsc/overview/overview?view=powershell-7)*