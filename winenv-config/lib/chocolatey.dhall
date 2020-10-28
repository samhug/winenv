{-
chocolatey
-}

let Prelude = ./prelude.dhall

let makeConfig
    : List Text → Text
    = λ(packages : List Text) →
        let pkgsList =
              Prelude.Text.concatMap
                Text
                ( λ(package : Text) →
                    ''

                    ${"    "}<package id="${package}" />''
                )
                packages

        in  ''
            <?xml version="1.0" encoding="utf-8"?>
            <packages>${pkgsList}
            </packages>
            ''

let example0 =
        assert
      :   makeConfig [ "7zip", "sudo" ]
        ≡ ''
          <?xml version="1.0" encoding="utf-8"?>
          <packages>
              <package id="7zip" />
              <package id="sudo" />
          </packages>
          ''

in  { makeConfig }
