# copy-assets.ps1
# 将 _posts 下所有 assets 目录拷贝到仓库根目录下（去掉 _posts 前缀）
# 例如: _posts\学习\阅读\2021\xxx\assets  ->  学习\阅读\2021\xxx\assets
#
# 运行方式:
#   powershell -NoProfile -ExecutionPolicy Bypass -File copy-assets.ps1

$ErrorActionPreference = "Stop"

$root    = $PSScriptRoot
$srcBase = Join-Path $root "_posts"

if (-not (Test-Path $srcBase)) {
    Write-Error "未找到目录: $srcBase"
    exit 1
}

# 递归查找 _posts 下所有名为 assets 的目录
$assetsDirs = @(Get-ChildItem -Path $srcBase -Directory -Recurse -Filter "assets")

if ($assetsDirs.Count -eq 0) {
    Write-Host "未在 _posts 下找到任何 assets 目录。"
    exit 0
}

$copied = 0
foreach ($dir in $assetsDirs) {
    # 计算相对路径，例如 学习\阅读\2021\xxx\assets
    $rel  = $dir.FullName.Substring($srcBase.Length).TrimStart('\')
    $dest = Join-Path $root $rel

    if (Test-Path $dest) {
        Remove-Item -Path $dest -Recurse -Force
    }
    Copy-Item -Path $dir.FullName -Destination $dest -Recurse -Force

    Write-Host "已拷贝: _posts\$rel"
    $copied++
}

Write-Host ""
Write-Host "完成！共处理 $copied 个 assets 目录。"
