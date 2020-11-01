--
-- Language Reference: https://docs.dhall-lang.org/

-- import our library of types and functions
let lib = ./lib/package.dhall

let context = ./system-context.dhall

let registryEntries
    : List lib.Registry.Entry
    = [ { path =
            "HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\TimeZoneInformation"
        , name = "RealTimeIsUniversal"
        , value = lib.Registry.Value.DWORD 1
        }
      , { path =
            "HKEY_LOCAL_MACHINE\\SOFTWARE\\Policies\\Microsoft\\Windows\\System"
        , name = "EnableActivityFeed"
        , value = lib.Registry.Value.DWORD 0
        }
      , { path =
            "HKEY_LOCAL_MACHINE\\SOFTWARE\\Policies\\Microsoft\\Windows\\System"
        , name = "DisableLogonBackgroundImage"
        , value = lib.Registry.Value.DWORD 1
        }
      , { path =
            "HKEY_LOCAL_MACHINE\\SOFTWARE\\Policies\\Microsoft\\Windows\\Windows Search"
        , name = "AllowCortana"
        , value = lib.Registry.Value.DWORD 0
        }
      , { path =
            "HKEY_LOCAL_MACHINE\\SOFTWARE\\Policies\\Microsoft\\Windows\\DataCollection"
        , name = "AllowTelemetry"
        , value = lib.Registry.Value.DWORD 0
        }
      , { path =
            "HKEY_LOCAL_MACHINE\\SOFTWARE\\Policies\\Microsoft\\Windows\\System"
        , name = "AllowClipboardHistory"
        , value = lib.Registry.Value.DWORD 0
        }
      ]

let filesystem
    : List lib.types.FilesystemDecl
    = [ { ensure = lib.types.EnsureType.Present
        , path = "c:/windows/system32/drivers/etc"
        , name = "hosts"
        , text =
            lib.HostsFile.mkHostsFile
              [ { ip = "10.90.0.1"
                , names = [ "workspace-home.snet.sa.m-h.ug" ]
                }
              , { ip = "10.0.1.20", names = [ "bootstrap.snet.sa.m-h.ug" ] }
              ]
        }
      , { ensure = lib.types.EnsureType.Present
        , path = "${context.storePath}"
        , name = "registry.reg"
        , text = lib.Registry.mkRegistryFile registryEntries
        }
      , { ensure = lib.types.EnsureType.Present
        , path = "${context.storePath}"
        , name = "example-activation-hook.ps1"
        , text =
            ''
            Write-Host 'Hello from powershell script'
            ''
        }
      , { ensure = lib.types.EnsureType.Present
        , path = "${context.storePath}"
        , name = "chocolatey-packages.config"
        , text =
            lib.Chocolatey.mkConfig
              [ "7zip"
              , "curl"
              , "git"
              , "keepass"
              , "nmap"
              , "openssh"
              , "processhacker"
              , "python"
              , "qemu"
              , "ripgrep"
              , "rufus"
              , "starship"
              , "sudo"
              , "sysinternals"
              , "vlc"
              , "which"
              , "winmerge"
              , "winscp"
              ]
        }
      ]

let activationHooks
    : List lib.types.ActivationHookDecl
    = [ { command = "powershell.exe"
        , args = [ "-File", "${context.storePath}\\example-activation-hook.ps1" ]
        }
      , { command = "choco"
        , args =
          [ "install"
          , "--confirm"
          , "${context.storePath}\\chocolatey-packages.config"
          ]
        }
      , lib.Registry.mkActivationHook "${context.storePath}\\registry.reg"
      ]

let declaration
    : lib.types.RootType
    = { filesystem, activationHooks }

in  declaration
