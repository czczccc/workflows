param(
  [Parameter(Mandatory=$true)][string]$JobId,
  [string]$OutputFile = ""
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

# GitHub 这个接口会返回 302 跳转到一个短时有效的日志下载地址
$response = Invoke-WebRequest `
  -Method Get `
  -Uri "https://api.github.com/repos/$owner/$repo/actions/jobs/$JobId/logs" `
  -Headers $headers `
  -MaximumRedirection 0 `
  -ErrorAction SilentlyContinue

$logUrl = $response.Headers.Location

if (-not $logUrl) {
  Write-Error "Failed to get redirect URL for job logs"
  exit 1
}

$logText = Invoke-RestMethod `
  -Method Get `
  -Uri $logUrl

if ($OutputFile -and $OutputFile.Trim() -ne "") {
  $logText | Out-File -FilePath $OutputFile -Encoding utf8
  Write-Host "Saved to $OutputFile"
} else {
  $logText
}