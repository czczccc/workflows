$check = .\automation\check-workflow.ps1 | ConvertFrom-Json

if ($check.status -ne "completed") {
  Write-Error "Latest workflow has not completed yet"
  exit 1
}

if ($check.conclusion -eq "success") {
  Write-Host "Latest workflow succeeded, no failure log needed"
  exit 0
}

$jobs = .\automation\get-workflow-jobs.ps1 -RunId $check.run_id | ConvertFrom-Json

$failedJob = $jobs | Where-Object { $_.conclusion -eq "failure" } | Select-Object -First 1

if (-not $failedJob) {
  Write-Error "No failed job found"
  exit 1
}

$resultsDir = ".\automation\results"
if (-not (Test-Path $resultsDir)) {
  New-Item -ItemType Directory -Path $resultsDir | Out-Null
}

$logFile = Join-Path $resultsDir "run-$($check.run_id)-job-$($failedJob.id).log"

.\automation\get-job-log.ps1 -JobId $failedJob.id -OutputFile $logFile

Write-Host "run_id=$($check.run_id)"
Write-Host "job_id=$($failedJob.id)"
Write-Host "job_name=$($failedJob.name)"
Write-Host "log_file=$logFile"

$result = @{
  run_id = $check.run_id
  job_id = $failedJob.id
  job_name = $failedJob.name
  log_file = $logFile
}

$result | ConvertTo-Json -Depth 5