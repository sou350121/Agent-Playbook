# 阿里云 CLI 自动安装脚本 (PowerShell)
# 适用于 Windows
# 由 Agent 生成，人类审核后执行

Write-Host "=========================================" -ForegroundColor Green
Write-Host "阿里云 CLI 自动安装脚本" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

# 检查是否以管理员身份运行
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "错误: 请以管理员身份运行此脚本" -ForegroundColor Red
    Write-Host "右键点击 PowerShell，选择'以管理员身份运行'" -ForegroundColor Yellow
    exit 1
}

# 创建临时目录
$tempDir = "$env:TEMP\aliyun-cli-install"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
Set-Location $tempDir

Write-Host "正在下载阿里云 CLI..." -ForegroundColor Yellow

# 下载最新版本
$downloadUrl = "https://aliyuncli.alicdn.com/aliyun-cli-windows-latest.zip"
$outputFile = "$tempDir\aliyun-cli.zip"

try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $outputFile -UseBasicParsing
    Write-Host "✅ 下载完成" -ForegroundColor Green
} catch {
    Write-Host "❌ 下载失败: $_" -ForegroundColor Red
    exit 1
}

Write-Host "正在解压文件..." -ForegroundColor Yellow

try {
    Expand-Archive -Path $outputFile -DestinationPath "$tempDir\aliyun-cli" -Force
    Write-Host "✅ 解压完成" -ForegroundColor Green
} catch {
    Write-Host "❌ 解压失败: $_" -ForegroundColor Red
    exit 1
}

# 安装到 Program Files
$installDir = "C:\Program Files\Aliyun\CLI"

Write-Host "正在安装到 $installDir..." -ForegroundColor Yellow

if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}

Copy-Item -Path "$tempDir\aliyun-cli\*" -Destination $installDir -Recurse -Force

# 添加到 PATH
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
$pathValue = [Environment]::GetEnvironmentVariable("Path", "Machine")

if ($pathValue -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$pathValue;$installDir", "Machine")
    Write-Host "✅ 已添加到系统 PATH" -ForegroundColor Green
} else {
    Write-Host "ℹ️  已存在于 PATH 中" -ForegroundColor Yellow
}

# 清理临时文件
Set-Location $env:TEMP
Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "✅ 清理完成" -ForegroundColor Green
Write-Host ""

# 刷新环境变量
Write-Host "请重新启动 PowerShell 以使环境变量生效" -ForegroundColor Yellow
Write-Host ""

Write-Host "=========================================" -ForegroundColor Green
Write-Host "安装完成！" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "下一步：配置 Access Key" -ForegroundColor Cyan
Write-Host "运行命令: aliyun configure" -ForegroundColor Cyan
Write-Host ""
Write-Host "获取 Access Key:" -ForegroundColor Cyan
Write-Host "1. 访问 https://ram.console.aliyun.com/manage/ak" -ForegroundColor White
Write-Host "2. 创建 Access Key" -ForegroundColor White
Write-Host "3. 复制 Access Key ID 和 Secret" -ForegroundColor White
Write-Host ""
