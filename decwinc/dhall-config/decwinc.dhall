-- 
-- Language Reference: https://docs.dhall-lang.org/

let Prelude =
      https://prelude.dhall-lang.org/v17.1.0/package.dhall sha256:10db3c919c25e9046833df897a8ffe2701dc390fa0893d958c3430524be5a43e

let lib = ./lib/package.dhall

let context = ./context.dhall

let EnsureType = < `Absent` | `Present` >

let FilesystemDecl = { ensure : EnsureType, path : Text, name : Text, text: Text }

let RegistryValueType = < `Dword` | `Qword` >
let RegistryDecl = { ensure : EnsureType, path : Text, name : Text, type: RegistryValueType, value: Text }

let ActivationHookDecl = { command : Text, args : List Text }

-- let writeStorePath = \(x : Natural) -> x + 1

-- in  { filesystem = Prelude.List.map User Text toEmail users
--     , activationHook = Prelude.List.map User Bio toBio users

let filesystem: List FilesystemDecl = [
    {
      ensure = EnsureType.Present,
      path = "c:/windows/system32/drivers/etc",
      name = "hosts",
      text = lib.hostsFile.makeHostsFile [
        -- Block Facebook by resolving the domain to 0.0.0.0
        { ip = "0.0.0.0", name = "www.facebook.com" },
        { ip = "10.90.0.1", name = "workspace-home.snet.sa.m-h.ug" },
      ],
    },
    {
      ensure = EnsureType.Present,
      path = "${context.storePath}",
      name = "activation-hook.ps1",
      text = "Write-Host 'Hello from ps1 file'",
    },
    {
      ensure = EnsureType.Present,
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
        "rustup.install",
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
    {
      ensure = EnsureType.Present,
      path = "${context.storePath}",
      name = "hostupdater-script.ps1",
      text =
        ''
        '',
    },
    {
      ensure = EnsureType.Present,
      path = "${context.storePath}",
      name = "scheduled_task-hostupdater.xml",
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
            <UserId>S-1-5-18</UserId>
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
            <Arguments>-File "${context.storePath}/hostupdater-script.ps1"</Arguments>
            </Exec>
        </Actions>
        </Task>
        '',
    }
  ]

  let registry = [] : List RegistryDecl
  -- let registry = [
  --     -- Make Windows expect the hardware clock to be set to UTC, linux
  --     -- typically expects this so when dual-booting it's nice to be consistent
  --     {
  --       ensure = EnsureType.Present,
  --       path = "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\TimeZoneInformation",
  --       name = "RealTimeIsUniversal",
  --       type = RegistryValueType.Qword,
  --       value = "00000001",
  --     },
  --     {
  --       ensure = "Absent",
  --       path = "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\MyComputer\\NameSpace\\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}"
  --     }
  -- ]

  let activationHooks: List ActivationHookDecl = [
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
      args = [ "-Command", "Register-ScheduledTask -TaskName 'DecWinC - Host Updater' -Xml (get-content '${context.storePath}/scheduled_task-hostupdater.xml' | out-string) -Force" ],
    },

    {
      command = "choco",
      args = [
        "install",
        "--confirm",
        "${context.storePath}/chocolatey-packages.config"
      ],
    }
  ]

let RootType = { filesystem: List FilesystemDecl
               , registry: List RegistryDecl
               , activationHooks: List ActivationHookDecl
               }

let declaration: RootType =
    { filesystem = filesystem
    , registry = registry
    , activationHooks = activationHooks
    }

in declaration