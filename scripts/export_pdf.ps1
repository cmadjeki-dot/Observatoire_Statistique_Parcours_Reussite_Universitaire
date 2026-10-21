param([switch]$Screenshot)
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$browser = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
if (-not (Test-Path -LiteralPath $browser)) {
    $browser = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
}
if (-not (Test-Path -LiteralPath $browser)) { throw 'Navigateur Chromium absent : export PDF non realise.' }
$reportRoot = Join-Path $projectRoot 'outputs\reports\reports'
$profile = Join-Path $projectRoot 'outputs\browser-profile'
foreach ($name in @('rapport_final', 'note_pilotage', 'enquetes')) {
    $html = Join-Path $reportRoot ($name + '.html')
    if (-not (Test-Path -LiteralPath $html)) { throw "HTML absent : $html" }
    $pdf = Join-Path $reportRoot ($name + '.pdf')
    $url = ([System.Uri]$html).AbsoluteUri
    $arguments = @('--headless', '--disable-gpu', '--no-pdf-header-footer', '--no-first-run', '--disable-extensions',
        "--user-data-dir=`"$profile`"", "--print-to-pdf=`"$pdf`"", "`"$url`"")
    $process = Start-Process -FilePath $browser -ArgumentList $arguments -WindowStyle Hidden -Wait -PassThru -RedirectStandardError (Join-Path $reportRoot ($name + '_chrome.log'))
    if ($process.ExitCode -ne 0 -or -not (Test-Path -LiteralPath $pdf)) { throw "Echec PDF : $name" }
}
if ($Screenshot) {
    $url = ([System.Uri](Join-Path $reportRoot 'note_pilotage.html')).AbsoluteUri
    $png = Join-Path $reportRoot 'note_apercu.png'
    $arguments = @('--headless', '--disable-gpu', '--no-first-run', '--disable-extensions',
        "--user-data-dir=`"$profile`"", '--window-size=1050,2300', "--screenshot=`"$png`"", "`"$url`"")
    $process = Start-Process -FilePath $browser -ArgumentList $arguments -WindowStyle Hidden -Wait -PassThru -RedirectStandardError (Join-Path $reportRoot 'screenshot_chrome.log')
    if ($process.ExitCode -ne 0) { throw 'Echec de capture HTML.' }
}
python (Join-Path $PSScriptRoot 'verify_pdf.py')
if ($LASTEXITCODE -ne 0) { throw 'Verification de pagination echouee.' }
