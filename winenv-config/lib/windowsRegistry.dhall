{-
windowsRegistry
-}

let Prelude = ./prelude.dhall

let RegistryValue
    : Type
    = < DWORD : Text | QWORD : Text >

let RegistryEntry
    : Type
    = { path : Text, name : Text, value : RegistryValue }

let makeRegistryFile =
      λ(registryEntries : List RegistryEntry) →
        let renderValue =
              λ(value : RegistryValue) →
                merge
                  { DWORD = λ(value : Text) → "dword:${value}"
                  , QWORD = λ(value : Text) → "qword:${value}"
                  }
                  value

        let renderEntry =
              λ(registryEntry : RegistryEntry) →
                ''
                [${registryEntry.path}]
                "${registryEntry.name}"=${renderValue registryEntry.value}
                ''

        let renderEntries =
              Prelude.Text.concatMapSep "\n" RegistryEntry renderEntry

        in  ''
            Windows Registry Editor Version 5.00

            ${renderEntries registryEntries}''

let makeActivationHook =
      λ(registryFilePath : Text) →
        { command = "reg", args = [ "import", registryFilePath ] }

let example0 =
        assert
      :   makeRegistryFile
            [ { path =
                  "HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced"
              , name = "HideFileExt"
              , value = RegistryValue.DWORD "00000000"
              }
            ]
        ≡ ''
          Windows Registry Editor Version 5.00

          [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
          "HideFileExt"=dword:00000000
          ''

let example1 =
        assert
      :   makeActivationHook "c:/path/to/key.reg"
        ≡ { command = "reg", args = [ "import", "c:/path/to/key.reg" ] }

in  { makeRegistryFile, makeActivationHook, RegistryEntry, RegistryValue }
