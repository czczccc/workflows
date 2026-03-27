param(
  [Parameter(Mandatory=$true)][string]$LogFile
)

if (-not (Test-Path $LogFile)) {
  Write-Error "Log file not found"
  exit 1
}

$lines = Get-Content $LogFile

# 取最后100行
$tail = $lines | Select-Object -Last 100

# 再筛 Error 行
$errors = $tail | Where-Object { $_ -match "Error|FAILED|Exception" }

if ($errors.Count -gt 0) {
  $errors | Out-String
} else {
  $tail | Out-String
}