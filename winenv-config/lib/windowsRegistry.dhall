{-
windowsRegistry
-}

let Prelude = ./prelude.dhall

-- https://en.wikipedia.org/wiki/Windows_Registry#.REG_files

-- https://support.microsoft.com/en-us/help/310516/how-to-add-modify-or-delete-registry-subkeys-and-values-by-using-a-reg


-- let RegistryValueType = < `dword` | `sz` >
let RegistryValue : Type = < DWORD: Text
                    | QWORD: Text
                    >

let RegistryEntry: Type = { path: Text, name: Text, value: RegistryValue }

let makeRegistryFile = \(registryEntries: List RegistryEntry) -> 
    let renderValue = \(value: RegistryValue) -> merge {
            DWORD = \(value: Text) -> "dword:${value}",
            QWORD = \(value: Text) -> "qword:${value}"
        } value
    let renderEntry = \(registryEntry: RegistryEntry) ->
        ''
        [${registryEntry.path}]
        "${registryEntry.name}"=${renderValue registryEntry.value}
        ''
    let renderEntries = Prelude.Text.concatMapSep "\n" RegistryEntry renderEntry
    in ''
    Windows Registry Editor Version 5.00

    ${renderEntries registryEntries}''

let makeActivationHook = \(registryFilePath: Text) ->
    { command = "reg"
    , args = [ "import", registryFilePath ]
    }


let example0 = assert : makeRegistryFile [
        { path = "HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced"
        , name = "HideFileExt"
        , value = RegistryValue.DWORD "00000000"
        }
    ] ≡ ''
    Windows Registry Editor Version 5.00

    [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
    "HideFileExt"=dword:00000000
    ''

let example1 = assert : makeActivationHook "c:/path/to/key.reg" ≡ { command = "reg", args = [ "import", "c:/path/to/key.reg" ]}


in { makeRegistryFile = makeRegistryFile
   , makeActivationHook = makeActivationHook

   , RegistryEntry = RegistryEntry
   , RegistryValue = RegistryValue
   }