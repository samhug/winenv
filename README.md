


## https://stackoverflow.com/questions/573817/where-are-environment-variables-stored-in-registry
    HKEY_CURRENT_USER\Environment
    HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment


## https://www.technipages.com/show-hidden-files-windows
    [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
    "Hidden"=dword:00000001
    "HideFileExt"=dword:00000000

https://www.red-gate.com/simple-talk/sysadmin/powershell/powershell-desired-state-configuration-the-basics/
https://docs.microsoft.com/en-us/powershell/scripting/dsc/reference/resources/windows/registryresource?view=powershell-7

https://markgossa.blogspot.com/2017/08/learn-powershell-dsc-part-1.html
