{-
windowsRegistry
-}

let types = ./types.dhall

let mkRegistryFile = ./mkRegistryFile.dhall

let mkActivationHook =
      λ(registryFilePath : Text) →
        { command = "reg", args = [ "import", registryFilePath ] }

let example0 =
        assert
      :   mkRegistryFile
            [ { path =
                  "HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced"
              , name = "HideFileExt"
              , value = types.Value.DWORD 2
              }
            ]
        ≡ ''
          Windows Registry Editor Version 5.00

          [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
          "HideFileExt"=dword:2
          ''

let example1 =
        assert
      :   mkActivationHook "c:/path/to/key.reg"
        ≡ { command = "reg", args = [ "import", "c:/path/to/key.reg" ] }

in  { mkRegistryFile, mkActivationHook } ⫽ types
