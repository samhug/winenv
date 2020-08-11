-- 
-- Language Reference: https://docs.dhall-lang.org/

let Prelude =
      https://prelude.dhall-lang.org/v17.1.0/package.dhall sha256:10db3c919c25e9046833df897a8ffe2701dc390fa0893d958c3430524be5a43e

let RegistryValueType = < `Dword` | `Qword` >

let EnsureType = < `Absent` | `Present` >

let context = { storePath = "c:/ProgramData/decwinc/store" }

let FilesystemDecl = { ensure : EnsureType, path : Text, name : Text, text: Text }
let RegistryDecl = { ensure : EnsureType, path : Text, name : Text, type: RegistryValueType, value: Text }
let ActivationHookDecl = { command : Text, args : List Text }

-- let writeStorePath = \(x : Natural) -> x + 1

-- in  { filesystem = Prelude.List.map User Text toEmail users
--     , activationHook = Prelude.List.map User Bio toBio users

in {

  filesystem = [
    -- Block Facebook by adding a "black-hole" route to the system hosts file
    {
      ensure = EnsureType.Present,
      path = "c:/windows/system32/drivers/etc",
      name = "hosts",
      text = "0.0.0.0    www.facebook.com",
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
      text =
        ''
        <?xml version="1.0" encoding="utf-8"?>
        <packages>
            <package id="7zip" />
            <package id="curl" />
            <package id="git" />
            <package id="keepass" />
            <package id="nmap" />
            <package id="openssh" />
            <package id="python" />
            <package id="qemu" />
            <package id="ripgrep" />
            <package id="rustup.install" />
            <package id="starship" />
            <package id="sudo" />
            <package id="sysinternals" />
            <package id="vlc" />
            <!-- <package id="vscode" /> -->
            <package id="which" />
            <package id="winmerge" />
            <package id="winscp" />

            <!--
            <package id="anotherPackage" version="1.1" />
            <package id="chocolateytestpackage" version="0.1" source="somelocation" />
            <package id="alloptions" version="0.1.1"
                    source="https://somewhere/api/v2/" installArguments=""
                    packageParameters="" forceX86="false" allowMultipleVersions="false"
                    ignoreDependencies="false"
                    />
            -->
        </packages>
        '',
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
  ] : List FilesystemDecl,
  
  registry = [
       -- Make Windows expect the hardware clock to be set to UTC, linux
       -- typically expects this so when dual-booting it's nice to be consistent
--     {
--       ensure = EnsureType.Present,
--       path = "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\TimeZoneInformation",
--       name = "RealTimeIsUniversal",
--       type = RegistryValueType.Qword,
--       value = "00000001",
--     },
--
--     {
--       ensure = "Absent",
--       path = "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\MyComputer\\NameSpace\\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}"
--     }
  ] : List RegistryDecl,

  activationHooks = [
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
  ] : List ActivationHookDecl
}