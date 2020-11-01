let Prelude = ../prelude.dhall

let types = ./types.dhall

let mkRegistryFile =
      λ(registryEntries : List types.Entry) →
        let renderValue =
              λ(value : types.Value) →
                let excapeStr = λ(input : Text) → Text/replace "\\" "\\\\" input

                in  merge
                      { DWORD =
                          λ(value : Natural) → "dword:${Natural/show value}"
                      , QWORD =
                          λ(value : Natural) → "qword:${Natural/show value}"
                      , SZ = λ(value : Text) → "\"${excapeStr value}\""
                      }
                      value

        let renderEntry =
              λ(registryEntry : types.Entry) →
                ''
                [${registryEntry.path}]
                "${registryEntry.name}"=${renderValue registryEntry.value}
                ''

        let renderEntries =
              Prelude.Text.concatMapSep "\n" types.Entry renderEntry

        in  ''
            Windows Registry Editor Version 5.00

            ${renderEntries registryEntries}''

in  mkRegistryFile
