param(
  [string]$WorkflowFile = "deerflow-codex-task.yml"
)

$token = $env:GITHUB_PAT
$owner = "czczccc"
$repo = "workflows"

if (-not $token) {
  Write-Error "Missing GITHUB_PAT"
  exit 1
}

$headers = @{
  Accept = "application/vnd.github+json"
  Authorization = "Bearer $token"
  "X-GitHub-Api-Version" = "2022-11-28"
}

# 1️⃣ 获取最近的 workflow run
$runs = Invoke-RestMethod `
  -Uri "https://api.github.com/repos/$owner/$repo/actions/workflows/$WorkflowFile/runs?per_page=1" `
  -Headers $headers

$run = $runs.workflow_runs[0]

if (-not $run) {
  Write-Error "No workflow run found"
  exit 1
}

$run_id = $run.id
$status = $run.status
$conclusion = $run.conclusion

Write-Host "run_id=$run_id"
Write-Host "status=$status"
Write-Host "conclusion=$conclusion"

# 2️⃣ 返回标准结构（给 DeerFlow2 用）
$result = @{
  run_id = $run_id
  status = $status
  conclusion = $conclusion
}

$result | ConvertTo-Json -Depth 5