$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$folder=Join-Path $root 'outputs\site-presentation-qa'
New-Item -ItemType Directory -Path $folder -Force | Out-Null
$profile=Join-Path $folder 'browser-profile'
$argsList=@('--headless','--disable-gpu','--no-first-run','--remote-debugging-address=127.0.0.1','--remote-debugging-port=9230',"--user-data-dir=`"$profile`"",'about:blank')
$process=Start-Process -FilePath 'C:\Program Files\Google\Chrome\Application\chrome.exe' -ArgumentList $argsList -WindowStyle Hidden -PassThru -RedirectStandardError (Join-Path $folder 'chrome.log')
$process.Id | Set-Content -LiteralPath (Join-Path $folder 'browser.pid')
Write-Output "Navigateur de controle demarre, PID $($process.Id)."
