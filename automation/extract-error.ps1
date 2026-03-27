param(
  [Parameter(Mandatory=$true)][string]$LogFile
)

if (-not (Test-Path $LogFile)) {
  Write-Error "Log file not found"
  exit 1
}

$raw = Get-Content $LogFile -Raw

if (-not $raw -or $raw.Trim() -eq "") {
  Write-Output "workflow failed but log file is empty"
  exit 0
}

$lines = $raw -split "`r?`n"

# 先抓明显错误行
$errors = $lines | Where-Object { $_ -match "Error|ERROR|FAILED|Exception|ENOENT|quota|insufficient_quota" }

if ($errors -and $errors.Count -gt 0) {
  ($errors -join "`n")
  exit 0
}

# 没抓到错误行，就返回最后 100 行
$tail = $lines | Select-Object -Last 100

if ($tail -and $tail.Count -gt 0) {
  ($tail -join "`n")
  exit 0
}

Write-Output "workflow failed but no extractable error text was found"