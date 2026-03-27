param(
  [Parameter(Mandatory=$true)][string]$RunId
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

$response = Invoke-RestMethod `
  -Method Get `
  -Uri "https://api.github.com/repos/$owner/$repo/actions/runs/$RunId/jobs" `
  -Headers $headers

if (-not $response.jobs) {
  Write-Error "No jobs found for run_id=$RunId"
  exit 1
}

$jobs = $response.jobs | ForEach-Object {
  [PSCustomObject]@{
    id = $_.id
    name = $_.name
    status = $_.status
    conclusion = $_.conclusion
    started_at = $_.started_at
    completed_at = $_.completed_at
  }
}

$jobs | ConvertTo-Json -Depth 5