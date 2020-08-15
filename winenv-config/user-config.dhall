-- 
-- Language Reference: https://docs.dhall-lang.org/

-- import our library of types and functions
let lib = ./lib/package.dhall

let context = ./user-context.dhall


let filesystem: List lib.types.FilesystemDecl = [

    -- Manage my user git config
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

    -- Generate a .reg file that we will import into the Windows Registry using an activation hook
    {
      ensure = lib.types.EnsureType.Present,
      path = "${context.storePath}",
      name = "registry.reg",
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

        -- TODO: add support for more registry key types
        -- -- Set user scoped environment variables
        -- { path = "HKEY_CURRENT_USER\\Environment"
        -- , name = "GIT_GET_ROOT"
        -- , type = "sz"
        -- , value = "${context.user.profilePath}/wksp"
        -- },
        -- { path = "HKEY_CURRENT_USER\\Environment"
        -- , name = "RUST_BACKTRACE"
        -- , type = "sz"
        -- , value = "${context.user.profilePath}/wksp"
        -- }
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

    -- Script to delete files in ~/Downloads that are older than 60 days
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

    -- Windows Scheduled Task configuration to run our ~/Downloads cleanup script
    -- we will register this task using an activation hook
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

    -- Register scheduled task to cleanup ~/Downloads folder
    {
      command = "powershell.exe",
      args = [ "-Command", "Register-ScheduledTask -TaskName 'Cleanup old Downloads' -Xml (get-content '${context.storePath}/scheduled_task-cleanup-downloads.xml' | out-string) -Force" ],
    },

    -- Activation hook to import our generated registry file
    (lib.windowsRegistry.makeActivationHook "${context.storePath}/registry.reg"),

  ]

let declaration: lib.types.RootType =
    { filesystem = filesystem
    , activationHooks = activationHooks
    }

in declaration