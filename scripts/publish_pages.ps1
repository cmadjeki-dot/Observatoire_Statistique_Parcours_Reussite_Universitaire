# Publie uniquement le site deja rendu et controle sur le depot de ce projet.
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location -LiteralPath $projectRoot
$repositoryUrl = 'https://github.com/cmadjeki-dot/Observatoire_Statistique_Parcours_Reussite_Universitaire.git'
$originUrl = git remote get-url origin
if ($LASTEXITCODE -ne 0 -or $originUrl -ne $repositoryUrl) { throw 'Destination Git inattendue.' }
python scripts/verify_classic_website.py
if ($LASTEXITCODE -ne 0) { throw 'Site non valide.' }
$releasePath = [IO.Path]::GetFullPath((Join-Path $projectRoot 'outputs\pages-release'))
if (-not $releasePath.StartsWith($projectRoot + '\outputs\')) { throw 'Chemin hors outputs.' }
New-Item -ItemType Directory -Path $releasePath -Force | Out-Null
Get-ChildItem -LiteralPath (Join-Path $projectRoot '_site') -Force | Copy-Item -Destination $releasePath -Recurse -Force
if (-not (Test-Path -LiteralPath (Join-Path $releasePath '.git'))) {
    git init -b gh-pages $releasePath
    if ($LASTEXITCODE -ne 0) { throw 'Initialisation impossible.' }
    git -C $releasePath remote add origin $repositoryUrl
}
git -C $releasePath add .
if ($LASTEXITCODE -ne 0) { throw 'Indexation impossible.' }
git -C $releasePath -c user.name='Cédric Madjeki' -c user.email='cmadjeki@gmail.com' commit -m 'Deployer le site Quarto valide'
if ($LASTEXITCODE -ne 0) { throw 'Aucun nouveau commit cree : verifier le depot de deploiement.' }
git -C $releasePath push -u origin gh-pages
if ($LASTEXITCODE -ne 0) { throw 'Publication Pages interrompue ; aucun envoi force.' }
