-- 
-- Language Reference: https://docs.dhall-lang.org/

let Prelude =
      https://prelude.dhall-lang.org/v17.1.0/package.dhall sha256:10db3c919c25e9046833df897a8ffe2701dc390fa0893d958c3430524be5a43e

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
      -- text = lib.windowsRegistry.makeRegistryFile (Prelude.List.concat lib.windowsRegistry.RegistryEntryType [
      text = lib.windowsRegistry.makeRegistryFile [

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
          }

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
      name = "updater-script.ps1",
      text =
        ''
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
    }
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

    -- Activation hook to register the scheduled task to update the host
    {
      command = "powershell.exe",
      args = [ "-Command", "Register-ScheduledTask -TaskName 'DecWinC - User Updater' -Xml (get-content '${context.storePath}/scheduled_task-updater.xml' | out-string) -Force" ],
    },

    (lib.windowsRegistry.makeActivationHook "${context.storePath}/registry.reg"),
  ]

let declaration: lib.types.RootType =
    { filesystem = filesystem
    , activationHooks = activationHooks
    }

in declaration