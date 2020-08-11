
let Prelude =
      https://prelude.dhall-lang.org/v17.1.0/package.dhall sha256:10db3c919c25e9046833df897a8ffe2701dc390fa0893d958c3430524be5a43e

-- let RegistryKeyType = < `dword` | `qword` >


let context = {
  storePath = "c:/ProgramData/decwinc/store",
}

-- let Module = { type : Text, config : Text, age : Natural }

-- let FilesystemDecl = { ensure : Text, path : Text, name : Natural, text: Text }


-- in  { filesystem = Prelude.List.map User Text toEmail users
--     , activationHook = Prelude.List.map User Bio toBio users
--     }

-- in {
--     a = "hello"
-- }

in {

  registry = [
--     {
--       ensure = "Present",
--       path = "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\TimeZoneInformation",
--       name = "RealTimeIsUniversal",
--       type = "Qword",
--       value = "00000001",
--     },
--     {
--       ensure = "Absent",
--       path = "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\MyComputer\\NameSpace\\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}"
--     }
  ] : List Natural,

  filesystem = [
    {
      ensure = "Present",
      path = "c:/windows/system32/drivers/etc",
      name = "hosts",
      text = "0.0.0.0    www.facebook.com",
    },
    {
      ensure = "Present",
      path = "${context.storePath}",
      name = "xxxxxxxxxxxxxxxxxxxxxxxx-activation-hook.ps1",
      text = "Write-Host 'Hello from ps1 file'",
    },
    {
      ensure = "Present",
      path = "${context.storePath}",
      name = "xxxxxxxxxxxxxxxxxxxxxxxx-chocolatey-packages.config",
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
    }
  ],

  activationHooks = [
    {
      command = "cmd",
      args = [ "/C", "echo hello"],
    },
    {
      command = "powershell.exe",
      args = [ "-Command", "Write-Host 'hello'"],
    },
    {
      command = "powershell.exe",
      args = [
        "-File",
        "${context.storePath}/xxxxxxxxxxxxxxxxxxxxxxxx-activation-hook.ps1"
      ],
    },
    {
      command = "choco",
      args = [
        "install",
        "--confirm",
        "${context.storePath}/xxxxxxxxxxxxxxxxxxxxxxxx-chocolatey-packages.config"
      ],
    }
  ]
}