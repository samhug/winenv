Set-StrictMode -Version 3

$REPO = (git -C "${PSScriptRoot}" rev-parse --show-toplevel)

# Write-Host $REPO

git -C "${REPO}" fetch origin master
git -C "${REPO}" rebase --autostash origin/master

# ==== SCHEDULED TASKS ====

Register-ScheduledTask `
    -TaskName "User - Update" `
    -Xml (get-content "${REPO}/scheduled-tasks/update-user.xml" | out-string) `
    -Force

Register-ScheduledTask `
    -TaskName "User - Cleanup Downloads" `
    -Xml (get-content "${REPO}/scheduled-tasks/user-cleanup-downloads.xml" | out-string) `
    -Force


