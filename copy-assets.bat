@echo off
rem 双击运行: 将 _posts 下所有 assets 目录拷贝到仓库根目录
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0copy-assets.ps1"
pause
