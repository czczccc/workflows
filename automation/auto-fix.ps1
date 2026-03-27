# 1) 获取状态
$check = .\automation\check-workflow.ps1 | ConvertFrom-Json

if ($check.status -ne "completed") {
  Write-Host "waiting"
  exit 0
}

if ($check.conclusion -eq "success") {
  Write-Host "success"
  exit 0
}

# 2) 获取失败 job
$jobs = .\automation\get-workflow-jobs.ps1 -RunId $check.run_id | ConvertFrom-Json
$failedJob = $jobs | Where-Object { $_.conclusion -eq "failure" } | Select-Object -First 1

if (-not $failedJob) {
  Write-Error "no failed job found"
  exit 1
}

# 3) 准备结果目录
$resultsDir = ".\automation\results"
if (-not (Test-Path $resultsDir)) {
  New-Item -ItemType Directory -Path $resultsDir -Force | Out-Null
}

# 4) 下载日志
$logFile = Join-Path $resultsDir "run-$($check.run_id)-job-$($failedJob.id).log"
.\automation\get-job-log.ps1 -JobId $failedJob.id -OutputFile $logFile

if (-not (Test-Path $logFile)) {
  Write-Error "log file was not created: $logFile"
  exit 1
}

# 5) 提取错误
$errorText = .\automation\extract-error.ps1 -LogFile $logFile

# 兜底：如果提取不到，就直接读原始日志最后 1000 个字符
if (-not $errorText -or $errorText.Trim() -eq "") {
  $rawLog = Get-Content $logFile -Raw
  if ($rawLog -and $rawLog.Trim() -ne "") {
    if ($rawLog.Length -gt 1000) {
      $errorText = $rawLog.Substring($rawLog.Length - 1000)
    } else {
      $errorText = $rawLog
    }
  }
}

if (-not $errorText -or $errorText.Trim() -eq "") {
  Write-Error "Failed to extract error text from log"
  exit 1
}

Write-Host "error text:"
Write-Host $errorText

# 6) 生成修复任务
$fixJson = .\automation\generate-fix-task.ps1 -ErrorText $errorText

if (-not $fixJson -or $fixJson.Trim() -eq "") {
  Write-Error "Failed to generate fix task JSON"
  exit 1
}

Write-Host "fix task json:"
Write-Host $fixJson

$fix = $fixJson | ConvertFrom-Json

if (-not $fix.task_id -or -not $fix.task_title -or -not $fix.acceptance) {
  Write-Error "Generated fix task is incomplete"
  exit 1
}

# 7) 触发修复任务
.\automation\trigger-workflow.ps1 `
  -TaskId $fix.task_id `
  -TaskTitle $fix.task_title `
  -Acceptance $fix.acceptance