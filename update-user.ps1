Set-StrictMode -Version 3

$REPO = (git -C "${PSScriptRoot}" rev-parse --show-toplevel)

# Write-Host $REPO

git -C "${REPO}" fetch origin master
git -C "${REPO}" rebase --autostash origin/master

# TODO

Register-ScheduledTask `
    -TaskName "Update User" `
    -Xml (get-content "${REPO}/scheduled-tasks/update-user.xml" | out-string) `
    -Force
