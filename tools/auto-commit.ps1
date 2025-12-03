param(
    [string]$Message = "Auto: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
)
Set-Location "c:\MobileUygulama\uygulama\flutter_application_1" | Out-Null
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Write-Error "git not found in PATH"; exit 1 }
git add .
$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) { Write-Host "No changes to commit."; exit 0 }
git commit -m $Message
$branch = (git rev-parse --abbrev-ref HEAD).Trim()
git push -u origin $branch
Write-Host " Auto-commit completed and pushed to '$branch'" -ForegroundColor Green
