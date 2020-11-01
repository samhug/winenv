{-
chocolatey
-}

let mkConfig = ./mkConfig.dhall

let example0 =
        assert
      :   mkConfig [ "7zip", "sudo" ]
        ≡ ''
          <?xml version="1.0" encoding="utf-8"?>
          <packages>
              <package id="7zip" />
              <package id="sudo" />
          </packages>
          ''

in  { mkConfig }
