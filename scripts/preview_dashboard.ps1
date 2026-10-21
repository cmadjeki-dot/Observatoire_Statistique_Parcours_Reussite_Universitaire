$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$qa=Join-Path $root 'outputs\dashboard-qa'
New-Item -ItemType Directory -Path $qa -Force | Out-Null
$browser='C:\Program Files\Google\Chrome\Application\chrome.exe'
$url=([System.Uri](Join-Path $root 'dashboards\interactive\dist\index.html')).AbsoluteUri
$profile=Join-Path $qa 'chrome-profile'
$screenshot=Join-Path $qa 'dashboard.png'
$argsList=@('--headless','--disable-gpu','--no-first-run',"--user-data-dir=`"$profile`"",'--window-size=1450,1200',"--screenshot=`"$screenshot`"",'--dump-dom',"`"$url`"")
$p=Start-Process -FilePath $browser -ArgumentList $argsList -WindowStyle Hidden -Wait -PassThru -RedirectStandardOutput (Join-Path $qa 'dom.html') -RedirectStandardError (Join-Path $qa 'chrome.log')
if($p.ExitCode -ne 0){throw 'Echec du controle navigateur'}
$html=Get-Content -LiteralPath (Join-Path $qa 'dom.html') -Raw -Encoding UTF8
if($html -notmatch '73,2' -or $html -notmatch '71,4' -or $html -notmatch 'Non observable'){throw 'Cartes initiales non rendues'}
Write-Output 'Rendu navigateur initial verifie ; capture dans outputs/dashboard-qa/dashboard.png'
