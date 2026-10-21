$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$folder=Join-Path $root 'outputs\shiny-qa'
New-Item -ItemType Directory -Path $folder -Force | Out-Null
$profile=Join-Path $folder 'browser-profile'
$browser='C:\Program Files\Google\Chrome\Application\chrome.exe'
$argsList=@('--headless','--disable-gpu','--no-first-run','--remote-debugging-address=127.0.0.1','--remote-debugging-port=9226',"--user-data-dir=`"$profile`"",'about:blank')
$process=Start-Process -FilePath $browser -ArgumentList $argsList -WindowStyle Hidden -PassThru -RedirectStandardError (Join-Path $folder 'chrome.log')
$process.Id | Set-Content -LiteralPath (Join-Path $folder 'browser.pid')
Write-Output "Navigateur de verification en arriere-plan, PID $($process.Id)"
