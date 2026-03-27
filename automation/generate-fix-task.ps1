param(
  [Parameter(Mandatory=$true)][string]$ErrorText
)

$taskId = "task-fix-" + (Get-Date -Format "yyyyMMddHHmmss")

$title = "修复 GitHub Actions 执行失败"
$acceptance = "修复当前错误并让 workflow 成功完成"

if ($ErrorText -match "ENOENT") {
  $title = "修复文件不存在导致的执行失败（ENOENT）"
  $acceptance = "修复缺失文件或路径错误，并让 workflow 成功完成"
}
elseif ($ErrorText -match "quota|insufficient_quota") {
  $title = "修复 API 配额不足导致的失败"
  $acceptance = "处理 API 配额问题，或改为不依赖外部 API 的修复流程，并让 workflow 成功完成"
}
elseif ($ErrorText -match "prompt-file|prompt_file") {
  $title = "修复 Codex Action 参数配置错误"
  $acceptance = "修复 workflow 参数配置，并让 workflow 成功完成"
}

$result = @{
  task_id = $taskId
  task_title = $title
  acceptance = $acceptance
}

$result | ConvertTo-Json -Depth 5
