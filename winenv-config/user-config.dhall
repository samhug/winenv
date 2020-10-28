--
-- Language Reference: https://docs.dhall-lang.org/

-- import our library of types and functions
let lib = ./lib/package.dhall

let context = ./user-context.dhall

let registryEntries
    : List lib.windowsRegistry.RegistryEntry
    = [ { path =
            "HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer"
        , name = "ShowDriveLettersFirst"
        , value = lib.windowsRegistry.RegistryValue.DWORD "00000004"
        }
      , { path =
            "HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced"
        , name = "Hidden"
        , value = lib.windowsRegistry.RegistryValue.DWORD "00000001"
        }
      , { path =
            "HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced"
        , name = "HideFileExt"
        , value = lib.windowsRegistry.RegistryValue.DWORD "00000000"
        }
      , { path =
            "HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced"
        , name = "DisallowShaking"
        , value = lib.windowsRegistry.RegistryValue.DWORD "00000001"
        }
      , { path =
            "HKEY_CURRENT_USER\\SOFTWARE\\Policies\\Microsoft\\Windows\\CurrentVersion\\PushNotifications"
        , name = "NoTileApplicationNotification"
        , value = lib.windowsRegistry.RegistryValue.DWORD "00000001"
        }
      , { path =
            "HKEY_CURRENT_USER\\Software\\Policies\\Microsoft\\Windows\\Explorer"
        , name = "HidePeopleBar"
        , value = lib.windowsRegistry.RegistryValue.DWORD "00000001"
        }
      ]

let filesystem
    : List lib.types.FilesystemDecl
    = [ { ensure = lib.types.EnsureType.Present
        , path = "${context.user.profilePath}"
        , name = ".gitconfig"
        , text =
            ''
            [user]
              email = s@m-h.ug
              name = Sam Hug
            ''
        }
      , { ensure = lib.types.EnsureType.Present
        , path = "${context.storePath}"
        , name = "registry.reg"
        , text = lib.windowsRegistry.makeRegistryFile registryEntries
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
        , name = "cleanup-downloads.ps1"
        , text =
            ''
            $Path = "$env:USERPROFILE\Downloads"
            $Daysback = "-60"

            $CurrentDate = Get-Date
            $DatetoDelete = $CurrentDate.AddDays($Daysback)
            Get-ChildItem $Path | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item -Recurse -Force -Confirm:$false
            ''
        }
      , { ensure = lib.types.EnsureType.Present
        , path = "${context.storePath}"
        , name = "scheduled_task-cleanup-downloads.xml"
        , text =
            ''
            <?xml version="1.0" encoding="UTF-16"?>
            <Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
              <Triggers>
                <CalendarTrigger>
                  <StartBoundary>2020-08-10T00:00:00</StartBoundary>
                  <Enabled>true</Enabled>
                  <ScheduleByDay>
                    <DaysInterval>1</DaysInterval>
                  </ScheduleByDay>
                </CalendarTrigger>
              </Triggers>
              <Principals>
                <Principal id="Author">
                  <LogonType>InteractiveToken</LogonType>
                  <RunLevel>LeastPrivilege</RunLevel>
                </Principal>
              </Principals>
              <Settings>
                <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
                <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
                <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
                <AllowHardTerminate>true</AllowHardTerminate>
                <StartWhenAvailable>true</StartWhenAvailable>
                <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
                <IdleSettings>
                  <StopOnIdleEnd>true</StopOnIdleEnd>
                  <RestartOnIdle>false</RestartOnIdle>
                </IdleSettings>
                <AllowStartOnDemand>true</AllowStartOnDemand>
                <Enabled>true</Enabled>
                <Hidden>false</Hidden>
                <RunOnlyIfIdle>false</RunOnlyIfIdle>
                <WakeToRun>false</WakeToRun>
                <ExecutionTimeLimit>PT4H</ExecutionTimeLimit>
                <Priority>7</Priority>
              </Settings>
              <Actions Context="Author">
                <Exec>
                  <Command>powershell.exe</Command>
                  <Arguments>-File "${context.storePath}/cleanup-downloads.ps1"</Arguments>
                </Exec>
              </Actions>
            </Task>
            ''
        }
      ]

let activationHooks
    : List lib.types.ActivationHookDecl
    = [ { command = "powershell.exe"
        , args = [ "-File", "${context.storePath}/example-activation-hook.ps1" ]
        }
      , { command = "powershell.exe"
        , args =
          [ "-Command"
          , "Register-ScheduledTask -TaskName 'Cleanup old Downloads' -Xml (get-content '${context.storePath}/scheduled_task-cleanup-downloads.xml' | out-string) -Force"
          ]
        }
      , lib.windowsRegistry.makeActivationHook
          "${context.storePath}/registry.reg"
      ]

let declaration
    : lib.types.RootType
    = { filesystem, activationHooks }

in  declaration
