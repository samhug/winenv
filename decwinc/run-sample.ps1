#requires -RunAsAdministrator
Set-StrictMode -Version 3


& "${PSScriptRoot}/dhall-config/dhall-to-json.exe" `
    --file "${PSScriptRoot}/dhall-config/decwinc.dhall" `
    --output "${PSScriptRoot}/decwinc-config.json"


& cargo run `
    --manifest-path "${PSScriptRoot}/decwinc/Cargo.toml" `
    --release `
    -- `
    --config "${PSScriptRoot}/decwinc-config.json"
