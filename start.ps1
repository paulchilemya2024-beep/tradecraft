$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
if (!(Test-Path '.venv/Scripts/python.exe')) { throw 'Run setup.ps1 first.' }
if (!(Test-Path 'dist/index.html') -or !(Test-Path 'build/tradecraft_engine.dll')) { throw 'Run setup.ps1 first to build the dashboard and C++ engine.' }
Write-Host 'Open http://127.0.0.1:5178 to practise trading. Press Ctrl+C to stop.'
& .venv/Scripts/python.exe -m backend.app
