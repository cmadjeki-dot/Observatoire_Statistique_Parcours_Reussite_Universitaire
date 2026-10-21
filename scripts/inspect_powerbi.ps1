$ErrorActionPreference='Stop'
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
$desktop=Get-Process PBIDesktop -ErrorAction SilentlyContinue
$desktop | Select-Object Id,MainWindowTitle,MainWindowHandle | Format-List
foreach($process in $desktop){
    $condition=New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ProcessIdProperty,$process.Id)
    $windows=[System.Windows.Automation.AutomationElement]::RootElement.FindAll([System.Windows.Automation.TreeScope]::Children,$condition)
    foreach($window in $windows){
        Write-Output "WINDOW: $($window.Current.Name)"
        $children=$window.FindAll([System.Windows.Automation.TreeScope]::Descendants,[System.Windows.Automation.Condition]::TrueCondition)
        $children | Select-Object -First 65 | ForEach-Object {"$($_.Current.ControlType.ProgrammaticName) : $($_.Current.Name)"}
    }
}
$folder=Join-Path $env:LOCALAPPDATA 'Microsoft\Power BI Desktop\AnalysisServicesWorkspaces'
Get-ChildItem -LiteralPath $folder -Recurse -Filter msmdsrv.port.txt -ErrorAction SilentlyContinue | ForEach-Object {Write-Output "PORT: $($_.FullName)";Get-Content -LiteralPath $_.FullName}
