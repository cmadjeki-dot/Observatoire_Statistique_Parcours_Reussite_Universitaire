$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$project=Join-Path $root 'dashboards\powerbi\Observatoire\Observatoire.pbip'
$desktop='C:\Program Files\Microsoft Power BI Desktop\bin\PBIDesktop.exe'
if(-not(Test-Path -LiteralPath $desktop)){throw 'Power BI Desktop absent.'}
$process=Start-Process -FilePath $desktop -ArgumentList "`"$project`"" -WindowStyle Hidden -PassThru
$process.Id | Set-Content -LiteralPath (Join-Path $root 'outputs\powerbi-qa\desktop.pid')
Write-Output "Ouverture du projet PBIP demandee, PID $($process.Id)."
