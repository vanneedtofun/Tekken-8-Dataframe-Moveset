$ErrorActionPreference = 'Stop'
$python = Join-Path $PSScriptRoot '.venv\Scripts\python.exe'
if (-not (Test-Path -LiteralPath $python)) {
    $python = Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
}
if (-not (Test-Path -LiteralPath $python)) {
    throw 'Python 3.12 tidak ditemukan. Jalankan dari lingkungan Codex yang menyediakan Python 3.12, atau pasang Python 3.12 terlebih dahulu.'
}
$env:PYTHONPATH = (Join-Path $PSScriptRoot 'vendor') + [IO.Path]::PathSeparator + $env:PYTHONPATH
Push-Location $PSScriptRoot
try {
    & $python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}