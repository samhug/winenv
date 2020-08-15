{-
taskScheduler
-}
-- let concatMapSep = https://prelude.dhall-lang.org/Text/concatMapSep

-- https://docs.microsoft.com/en-us/windows/win32/taskschd/task-scheduler-schema
let ScheduledTaskType = { triggers: List TriggerType
                        , actions: List ActionType
                        }


let makeScheduledTaskConfig = \(task: ScheduledTaskType) -> 
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
    ''

-- let makeScheduledTaskConfig = assert : makeScheduledTaskConfig { triggers = [], actions = [] } ≡ ""

in { makeScheduledTaskConfig = makeScheduledTaskConfig
}