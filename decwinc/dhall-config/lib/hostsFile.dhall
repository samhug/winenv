{-
hostsFile
-}
let concatMapSep = https://prelude.dhall-lang.org/Text/concatMapSep

let HostEntryType = { ip: Text, name: Text }
let makeHostsFile = \(hostEntries: List HostEntryType) -> 
    concatMapSep "\n" HostEntryType (\(hostEntry: HostEntryType) -> "${hostEntry.ip} ${hostEntry.name}") hostEntries

let example0 = assert : makeHostsFile [ { ip = "0.0.0.0", name = "www.facebook.com"} ] ≡ "0.0.0.0 www.facebook.com"

in { makeHostsFile = makeHostsFile
}