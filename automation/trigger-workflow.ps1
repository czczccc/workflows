param(
  [Parameter(Mandatory=$true)][string]$TaskId,
  [Parameter(Mandatory=$true)][string]$TaskTitle,
  [Parameter(Mandatory=$true)][string]$Acceptance
)

$token = $env:GITHUB_PAT
$owner = "czczccc"
$repo = "workflows"
$workflowFile = "deerflow-codex-task.yml"

if (-not $token) {
  Write-Error "Missing GITHUB_PAT environment variable"
  exit 1
}

$headers = @{
  Accept = "application/vnd.github+json"
  Authorization = "Bearer $token"
  "X-GitHub-Api-Version" = "2022-11-28"
}

$body = @{
  ref = "main"
  inputs = @{
    task_id = $TaskId
    task_title = $TaskTitle
    acceptance = $Acceptance
  }
} | ConvertTo-Json -Depth 5

try {
  Invoke-RestMethod `
    -Method Post `
    -Uri "https://api.github.com/repos/$owner/$repo/actions/workflows/$workflowFile/dispatches" `
    -Headers $headers `
    -Body $body `
    -ContentType "application/json"

  Write-Host "Workflow dispatched successfully"
  Write-Host "task_id=$TaskId"
  Write-Host "task_title=$TaskTitle"
}
catch {
  Write-Error $_
  exit 1
}