


## https://stackoverflow.com/questions/573817/where-are-environment-variables-stored-in-registry
    HKEY_CURRENT_USER\Environment
    HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment


## https://www.technipages.com/show-hidden-files-windows
    [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
    "Hidden"=dword:00000001
    "HideFileExt"=dword:00000000
