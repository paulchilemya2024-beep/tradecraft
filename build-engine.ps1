$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
New-Item -ItemType Directory -Force build | Out-Null
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (!(Test-Path $vswhere)) { throw 'Install Visual Studio Build Tools with the C++ workload, or use CMake.' }
$installation = & $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if (!$installation) { throw 'The Visual Studio C++ workload is required.' }
$setup = Join-Path $installation 'VC\Auxiliary\Build\vcvars64.bat'
$source = Join-Path $PSScriptRoot 'engine\engine.cpp'
$dll = Join-Path $PSScriptRoot 'build\tradecraft_engine.dll'
$obj = Join-Path $PSScriptRoot 'build\engine.obj'
$implib = Join-Path $PSScriptRoot 'build\tradecraft_engine.lib'
$batch = "@echo off`r`ncall `"$setup`"`r`nif errorlevel 1 exit /b 1`r`ncl /nologo /std:c++17 /EHsc /W4 /LD `"$source`" /Fo:`"$obj`" /link /OUT:`"$dll`" /IMPLIB:`"$implib`"`r`n"
Set-Content -LiteralPath 'build/compile.cmd' -Value $batch -Encoding ascii
& cmd.exe /d /c build\compile.cmd
if ($LASTEXITCODE -ne 0) { throw 'C++ compilation failed.' }
