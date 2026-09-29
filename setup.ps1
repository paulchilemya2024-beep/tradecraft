$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
if (!(Test-Path '.venv/Scripts/python.exe')) { python -m venv .venv }
& .venv/Scripts/python.exe -m pip install -r requirements.txt
if ($LASTEXITCODE -ne 0) { throw 'Python dependency installation failed.' }
& npm.cmd ci
if ($LASTEXITCODE -ne 0) { throw 'Frontend dependency installation failed.' }
& ./build-engine.ps1
& npm.cmd run build
if ($LASTEXITCODE -ne 0) { throw 'Dashboard build failed.' }
& .venv/Scripts/python.exe -m unittest discover -s tests -v
if ($LASTEXITCODE -ne 0) { throw 'Tests failed.' }
Write-Host 'Ready. Run ./start.ps1 and open http://127.0.0.1:5178'
