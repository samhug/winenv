{-
windowsRegistry
-}
let concatMapSep = https://prelude.dhall-lang.org/Text/concatMapSep

-- https://support.microsoft.com/en-us/help/310516/how-to-add-modify-or-delete-registry-subkeys-and-values-by-using-a-reg


-- let RegistryValueType = < `dword` | `sz` >
let RegistryEntryType = { path: Text, name: Text, type: Text, value: Text }
let makeRegistryFile = \(registryEntries: List RegistryEntryType) -> 
    let renderedEntries = concatMapSep "\n" RegistryEntryType (\(registryEntry: RegistryEntryType) ->
        -- let renderValue : RegistryValueType → Text
        --     renderValue = \(r: RegistryValueType) merge { dword = "dword:${r.value}" sz = "\"${r.value}\"" } r.type
        -- let valueString = renderValue registryEntry
        ''
            [${registryEntry.path}]
            "${registryEntry.name}"=${registryEntry.type}:${registryEntry.value}
            ''
        ) registryEntries
    in ''
    Windows Registry Editor Version 5.00

    ${renderedEntries}''

let makeActivationHook = \(registryFilePath: Text) ->
    { command = "reg"
    , args = [ "import", registryFilePath ]
    }


let example0 = assert : makeRegistryFile [
        { path = "HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced"
        , name = "HideFileExt"
        , type = "dword"
        , value = "00000000"
        }
    ] ≡ ''
    Windows Registry Editor Version 5.00

    [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
    "HideFileExt"=dword:00000000
    ''

let example1 = assert : makeActivationHook "c:/path/to/key.reg" ≡ { command = "reg", args = [ "import", "c:/path/to/key.reg" ]}


in { makeRegistryFile = makeRegistryFile
   , makeActivationHook = makeActivationHook

   , RegistryEntryType = RegistryEntryType
   }