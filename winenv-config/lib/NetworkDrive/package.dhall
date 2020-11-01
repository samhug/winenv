

-- [HKEY_CURRENT_USER\Network\w]
-- "RemotePath"="\\\\workspace-home.snet.sa.m-h.ug\\shug"
-- "UserName"=""
-- "ProviderName"="Microsoft Windows Network"
-- "ProviderType"=dword:00020000
-- "ConnectionType"=dword:00000001
-- "ConnectFlags"=dword:00000000
-- "DeferFlags"=dword:00000004
-- "UseOptions"=hex:44,65,66,43,7c,00,00,00,04,00,74,00,00,00,02,00,03,00,01,00,\
--   01,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
--   00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,47,00,00,00,00,00,00,00,00,00,\
--   00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
--   00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
--   00,00,80,00

let types = ./types.dhall

let mkNetworkDrive = ./mkNetworkDrive.dhall

let Registry = ../Registry/package.dhall
let example0 =
        assert
      :   mkNetworkDrive types.NetworkDrive::{ letter = "w", remotePath = "\\\\workspace-home.snet.sa.m-h.ug\\shug" }
        ≡ [ { path = "HKEY_CURRENT_USER\\Network\\w"
              , name = "UserName"
              , value = Registry.Value.SZ ""
              }
            , { path = "HKEY_CURRENT_USER\\Network\\w"
              , name = "RemotePath"
              , value = Registry.Value.SZ "\\\\workspace-home.snet.sa.m-h.ug\\shug"
              }
            ]

in  { mkNetworkDrive } // types
