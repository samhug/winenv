let Prelude = ../prelude.dhall

let mkConfig
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

in  mkConfig
