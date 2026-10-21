$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$bin='C:\Program Files\Microsoft Power BI Desktop\bin'
foreach($name in @('Newtonsoft.Json.dll','Microsoft.PowerBI.Amo.Core.dll','Microsoft.PowerBI.Tabular.dll','Microsoft.PowerBI.Tabular.Json.dll')) {
    $file=Join-Path $bin $name
    if(Test-Path -LiteralPath $file){[void][System.Reflection.Assembly]::LoadFrom($file)}
}
$file=Join-Path $root 'dashboards\powerbi\Observatoire\Observatoire.SemanticModel\model.bim'
$json=[System.IO.File]::ReadAllText($file,[System.Text.Encoding]::UTF8)
$database=[Microsoft.AnalysisServices.Tabular.JsonSerializer]::DeserializeDatabase($json)
$result=[ordered]@{statut='valide';validateur='Tabular Object Model fourni par Power BI Desktop';tables=$database.Model.Tables.Count;relations=$database.Model.Relationships.Count;mesures=($database.Model.Tables | ForEach-Object {$_.Measures.Count} | Measure-Object -Sum).Sum}
$result | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $root 'outputs\powerbi-qa\recette-modele.json') -Encoding UTF8
$result | ConvertTo-Json
