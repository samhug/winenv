-- 
-- Language Reference: https://docs.dhall-lang.org/

-- import our library of types and functions
let lib = ./lib/package.dhall

let context = ./system-context.dhall


let filesystem: List lib.types.FilesystemDecl = [

    -- Manage the system hosts file
    {
      ensure = lib.types.EnsureType.Present,
      path = "c:/windows/system32/drivers/etc",
      name = "hosts",
      text = lib.hostsFile.makeHostsFile [
        -- Block Facebook by resolving the domain to 0.0.0.0
        { ip = "0.0.0.0", name = "www.facebook.com" },
        { ip = "10.90.0.1", name = "workspace-home.snet.sa.m-h.ug" },
      ],
    },

    -- Generate a .reg file that we will import into the Windows Registry using an activation hook
    {
      ensure = lib.types.EnsureType.Present,
      path = "${context.storePath}",
      name = "registry.reg",
      text = lib.windowsRegistry.makeRegistryFile [

        -- Make Windows expect the hardware clock to be set to UTC, linux
        -- typically expects this so its when dual-booting
        { path = "HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\TimeZoneInformation"
        , name = "RealTimeIsUniversal"
        , type = "qword"
        , value = "00000001"
        },

        -- Disable Windows 10 Timeline - https://winaero.com/blog/disable-timeline-windows-10-group-policy/
        { path = "HKEY_LOCAL_MACHINE\\SOFTWARE\\Policies\\Microsoft\\Windows\\System"
        , name = "EnableActivityFeed"
        , type = "dword"
        , value = "00000000"
        },

        -- Disable logon screen background image - https://winaero.com/blog/disable-logon-screen-background-image-in-windows-10-without-using-third-party-tools/
        { path = "HKEY_LOCAL_MACHINE\\SOFTWARE\\Policies\\Microsoft\\Windows\\System"
        , name = "DisableLogonBackgroundImage"
        , type = "dword"
        , value = "00000001"
        },

        -- Disable cortana - https://winaero.com/blog/disable-cortana-in-windows-10-anniversary-update-version-1607/
        { path = "HKEY_LOCAL_MACHINE\\SOFTWARE\\Policies\\Microsoft\\Windows\\Windows Search"
        , name = "AllowCortana"
        , type = "dword"
        , value = "00000000"
        },

        -- Disable Windows Telemetry - https://winaero.com/blog/how-to-disable-telemetry-and-data-collection-in-windows-10/
        -- TODO: Need to also disable services
        { path = "HKEY_LOCAL_MACHINE\\SOFTWARE\\Policies\\Microsoft\\Windows\\DataCollection"
        , name = "AllowTelemetry"
        , type = "dword"
        , value = "00000000"
        },

        -- Disable clipboard history - https://www.majorgeeks.com/content/page/how_to_disable_clipboard_history_in_windows_10.html
        { path = "HKEY_LOCAL_MACHINE\\SOFTWARE\\Policies\\Microsoft\\Windows\\System"
        , name = "AllowClipboardHistory"
        , type = "dword"
        , value = "00000000"
        },

        -- TODO: Set system scoped environment variables
      ]
    },

    -- Example powershell script that we will execute with an activation hook
    {
      ensure = lib.types.EnsureType.Present,
      path = "${context.storePath}",
      name = "example-activation-hook.ps1",
      text =
        ''
        Write-Host 'Hello from powershell script'
        '',
    },

    -- Generate a Chocolatey packages config file
    -- We will use an activation script to have Chocolatey install these packages
    {
      ensure = lib.types.EnsureType.Present,
      path = "${context.storePath}",
      name = "chocolatey-packages.config",
      text = lib.chocolatey.makeConfig [
        "7zip",
        "curl",
        "git",
        "keepass",
        "nmap",
        "openssh",
        "python",
        "qemu",
        "ripgrep",
        -- "rustup.install",
        "starship",
        "sudo",
        "sysinternals",
        "vlc",
        -- "vscode",
        "which",
        "winmerge",
        "winscp",
      ],
    },

  ]


  let activationHooks: List lib.types.ActivationHookDecl = [

    -- Activation hook to execute our example script
    {
      command = "powershell.exe",
      args = [
        "-File",
        "${context.storePath}/example-activation-hook.ps1"
      ],
    },

    -- Activation hook to install packages specified in our generated Chocolatey config 
    {
      command = "choco",
      args = [
        "install",
        "--confirm",
        "${context.storePath}/chocolatey-packages.config"
      ],
    },

    -- Activation hook to import our generated registry file
    (lib.windowsRegistry.makeActivationHook "${context.storePath}/registry.reg"),

  ]


let declaration: lib.types.RootType =
    { filesystem = filesystem
    , activationHooks = activationHooks
    }

in declaration