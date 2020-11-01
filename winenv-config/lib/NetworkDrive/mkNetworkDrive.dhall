let Prelude = ../prelude.dhall

let types = ./types.dhall

let Registry = ../Registry/package.dhall

let mkNetworkDrive =
      λ(drive : types.NetworkDrive.Type) →
        let keyPath = "HKEY_CURRENT_USER\\Network\\${drive.letter}"

        in  [ { path = keyPath
              , name = "UserName"
              , value = Registry.Value.SZ drive.userName
              }
            , { path = keyPath
              , name = "RemotePath"
              , value = Registry.Value.SZ drive.remotePath
              }
            ]

in  mkNetworkDrive
