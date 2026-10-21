param(
    [Parameter(ParameterSetName = 'Script')]
    [string]$Script = 'scripts/02_verify_setup.R',
    [Parameter(Mandatory, ParameterSetName = 'Console')]
    [switch]$Console,
    [Parameter(Mandatory, ParameterSetName = 'Quarto')]
    [ValidateSet('render', 'preview')]
    [string]$QuartoCommand,
    [Parameter(ParameterSetName = 'Quarto')]
    [switch]$Reports,
    [Parameter(ParameterSetName = 'Quarto')]
    [switch]$Notebooks
)
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location -LiteralPath $projectRoot
$requiredVersion = (Get-Content -LiteralPath 'renv.lock' -Raw | ConvertFrom-Json).R.Version
$rOnPath = Get-Command Rscript.exe -ErrorAction SilentlyContinue
$candidates = @(
    $env:OBSERVATOIRE_RSCRIPT
    (Join-Path $env:ProgramFiles "R\R-$requiredVersion\bin\Rscript.exe")
    $(if ($rOnPath) { $rOnPath.Source })
)
$rscript = $candidates | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) } | Select-Object -First 1
if (-not $rscript) {
    throw "Rscript introuvable. Installer R $requiredVersion ou definir OBSERVATOIRE_RSCRIPT vers Rscript.exe."
}
Write-Output "Rscript : $rscript ; version du lockfile : $requiredVersion"
if ($Console) {
    $rConsole = Join-Path (Split-Path -Parent $rscript) 'R.exe'
    & $rConsole --no-save --no-restore
} elseif ($QuartoCommand) {
    $env:QUARTO_R = $rscript
    if ($Reports -and $Notebooks) { throw 'Choisir Reports ou Notebooks.' }
    if ($Reports) {
        if ($QuartoCommand -ne 'render') { throw 'Reports exige QuartoCommand render.' }
        & quarto render reports --execute-dir $projectRoot
    } elseif ($Notebooks) {
        if ($QuartoCommand -ne 'render') { throw 'Notebooks exige QuartoCommand render.' }
        & quarto render notebooks --execute-dir $projectRoot
    } else {
        & quarto $QuartoCommand
    }
} else {
    if (-not (Test-Path -LiteralPath $Script -PathType Leaf)) { throw "Script absent : $Script" }
    # Les scripts d'entree activent renv explicitement. Ignorer les profils
    # personnels et l'historique de session pour eviter leurs effets de bord.
    & $rscript --vanilla $Script
}
exit $LASTEXITCODE
