-- 
-- Language Reference: https://docs.dhall-lang.org/

let lib = ./lib/package.dhall

let context = ./user-context.dhall


let filesystem: List lib.types.FilesystemDecl = [
    {
      ensure = lib.types.EnsureType.Present,
      path = "${context.user.profilePath}",
      name = ".gitconfig",
      text = ''
      [user]
        email = s@m-h.ug
        name = Sam Hug
      '',
    },
    {
      ensure = lib.types.EnsureType.Present,
      path = "${context.storePath}",
      name = "registry.reg",
      -- text = lib.windowsRegistry.makeRegistryFile (lib.prelude.List.concat lib.windowsRegistry.RegistryEntryType [
      text = lib.windowsRegistry.makeRegistryFile [

          -- Show driver letters before names - https://winaero.com/blog/show-drive-letters-before-drive-names-in-this-pc-computer-folder/ 
          { path = "HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer"
          , name = "ShowDriveLettersFirst"
          , type = "dword"
          , value = "00000004"
          },

          -- Show hidden files
          { path = "HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced"
          , name = "Hidden"
          , type = "dword"
          , value = "00000001"
          },

          -- Don't hide file extensions
          { path = "HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced"
          , name = "HideFileExt"
          , type = "dword"
          , value = "00000000"
          },
          
          -- Disable Aero Shake - https://winaero.com/blog/disable-aero-shake-in-windows-10-windows-8-and-windows-7/
          { path = "HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced"
          , name = "DisallowShaking"
          , type = "dword"
          , value = "00000001"
          },

          -- Disable start menu live tiles - https://winaero.com/blog/disable-live-tiles-all-at-once-in-windows-10-start-menu/
          { path = "HKEY_CURRENT_USER\\SOFTWARE\\Policies\\Microsoft\\Windows\\CurrentVersion\\PushNotifications"
          , name = "NoTileApplicationNotification"
          , type = "dword"
          , value = "00000001"
          },

          -- Hide people bar - https://winaero.com/blog/disable-people-windows-10-group-policy/
          { path = "HKEY_CURRENT_USER\\Software\\Policies\\Microsoft\\Windows\\Explorer"
          , name = "HidePeopleBar"
          , type = "dword"
          , value = "00000001"
          },

        -- -- Set user scoped environment variables
        -- [

        --   { path = "HKEY_CURRENT_USER\\Environment"
        --   , name = "GIT_GET_ROOT"
        --   , type = "sz"
        --   , value = "${context.user.profilePath}/wksp"
        --   },

        --   { path = "HKEY_CURRENT_USER\\Environment"
        --   , name = "RUST_BACKTRACE"
        --   , type = "sz"
        --   , value = "${context.user.profilePath}/wksp"
        --   }

        -- ],
      ]
    },
    {
      ensure = lib.types.EnsureType.Present,
      path = "${context.storePath}",
      name = "activation-hook.ps1",
      text = "Write-Host 'Hello from ps1 file'",
    },
    {
      ensure = lib.types.EnsureType.Present,
      path = "${context.storePath}",
      name = "cleanup-downloads.ps1",
      text =
        ''
        $Path = "$env:USERPROFILE\Downloads"
        $Daysback = "-60"

        $CurrentDate = Get-Date
        $DatetoDelete = $CurrentDate.AddDays($Daysback)
        Get-ChildItem $Path | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item -Recurse -Force -Confirm:$false
        '',
    },
    {
      ensure = lib.types.EnsureType.Present,
      path = "${context.storePath}",
      name = "updater-script.ps1",
      text =
        ''
        '',
    },
    {
      ensure = lib.types.EnsureType.Present,
      path = "${context.storePath}",
      name = "scheduled_task-cleanup-downloads.xml",
      text =
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
        '',
    },
    {
      ensure = lib.types.EnsureType.Present,
      path = "${context.storePath}",
      name = "scheduled_task-updater.xml",
      text =
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
              <Arguments>-File "${context.storePath}/updater-script.ps1"</Arguments>
            </Exec>
          </Actions>
        </Task>
        '',
    },
  ]

  let activationHooks: List lib.types.ActivationHookDecl = [
    {
      command = "cmd",
      args = [ "/C", "echo hello" ],
    },
    {
      command = "powershell.exe",
      args = [ "-Command", "Write-Host 'hello'" ],
    },
    {
      command = "powershell.exe",
      args = [
        "-File",
        "${context.storePath}/activation-hook.ps1"
      ],
    },

    -- Activation hooks to register scheduled tasks
    {
      command = "powershell.exe",
      args = [ "-Command", "Register-ScheduledTask -TaskName 'DecWinC - User Updater' -Xml (get-content '${context.storePath}/scheduled_task-updater.xml' | out-string) -Force" ],
    },
    {
      command = "powershell.exe",
      args = [ "-Command", "Register-ScheduledTask -TaskName 'Cleanup old Downloads' -Xml (get-content '${context.storePath}/scheduled_task-cleanup-downloads.xml' | out-string) -Force" ],
    },

    (lib.windowsRegistry.makeActivationHook "${context.storePath}/registry.reg"),
  ]

let declaration: lib.types.RootType =
    { filesystem = filesystem
    , activationHooks = activationHooks
    }

in declaration