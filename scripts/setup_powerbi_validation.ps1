$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location -LiteralPath $projectRoot
$python = Join-Path $projectRoot '.venv-powerbi/Scripts/python.exe'
if (-not (Test-Path -LiteralPath $python)) {
    & python -m venv .venv-powerbi
    if ($LASTEXITCODE -ne 0) { throw 'Creation du venv impossible.' }
}
& $python -m pip install -r requirements-powerbi.txt
if ($LASTEXITCODE -ne 0) { throw 'Installation des dependances Power BI impossible.' }
& $python scripts/validate_powerbi_project.py
exit $LASTEXITCODE
