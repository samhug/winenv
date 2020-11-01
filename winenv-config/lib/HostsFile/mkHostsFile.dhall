let Prelude = ../prelude.dhall

let types = ./types.dhall

let mkHostsEntry =
      λ(entry : types.HostEntry) →
        let namesConcat =
              Prelude.Text.concatMapSep " " Text (λ(x : Text) → x) entry.names

        in  "${entry.ip} ${namesConcat}"

let mkHostsFile =
      λ(hostEntries : List types.HostEntry) →
        Prelude.Text.concatMapSep "\n" types.HostEntry mkHostsEntry hostEntries

in  mkHostsFile
