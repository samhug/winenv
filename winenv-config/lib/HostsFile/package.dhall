{-
hostsFile
-}

let mkHostsFile = ./mkHostsFile.dhall

let example0 =
        assert
      :   mkHostsFile [ { ip = "0.0.0.0", names = [ "www.facebook.com" ] } ]
        ≡ "0.0.0.0 www.facebook.com"

in  { mkHostsFile }
