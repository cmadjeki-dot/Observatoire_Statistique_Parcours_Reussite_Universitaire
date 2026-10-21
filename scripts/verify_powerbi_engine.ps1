$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$bin='C:\Program Files\Microsoft Power BI Desktop\bin'
foreach($name in @('Newtonsoft.Json.dll','Microsoft.PowerBI.Amo.Core.dll','Microsoft.PowerBI.Tabular.dll','Microsoft.PowerBI.Tabular.Json.dll','Microsoft.PowerBI.AdomdClient.dll')){
    $file=Join-Path $bin $name
    if(Test-Path -LiteralPath $file){[void][Reflection.Assembly]::LoadFrom($file)}
}
$workspace=Join-Path $env:LOCALAPPDATA 'Microsoft\Power BI Desktop\AnalysisServicesWorkspaces'
$ports=Get-ChildItem -LiteralPath $workspace -Filter msmdsrv.port.txt -Recurse | Sort-Object LastWriteTime -Descending
$server=$null;$database=$null;$port=$null
foreach($file in $ports){
    $candidate=([IO.File]::ReadAllText($file.FullName,[Text.Encoding]::Unicode) -replace '[^0-9]','')
    if(-not $candidate){continue}
    $connection=New-Object Microsoft.AnalysisServices.Tabular.Server
    try{
        $connection.Connect("localhost:$candidate")
        $match=$connection.Databases | Where-Object {$_.Model.Tables.Find('FactScolarite') -and $_.Model.Tables.Find('Indicateurs')}
        if($match){$server=$connection;$database=@($match)[0];$port=$candidate;break}
        $connection.Disconnect()
    }catch{if($connection.Connected){$connection.Disconnect()}}
}
if(-not $database){throw 'Modele Observatoire non trouve dans le moteur Desktop ouvert.'}
Write-Output "Modele Observatoire trouve sur localhost:$port ; actualisation des exports locaux proteges."
$database.Model.RequestRefresh([Microsoft.AnalysisServices.Tabular.RefreshType]::Full)
[void]$database.Model.SaveChanges()
$adomd=New-Object Microsoft.AnalysisServices.AdomdClient.AdomdConnection("Data Source=localhost:$port;Initial Catalog=$($database.Name)")
$adomd.Open()
function Invoke-DaxScalar([string]$query){
    $command=$adomd.CreateCommand();$command.CommandText=$query
    $reader=$command.ExecuteReader()
    try{if($reader.Read()){if($reader.IsDBNull(0)){return $null};return $reader.GetValue(0)}}finally{$reader.Close();$command.Dispose()}
}
$latest=Invoke-DaxScalar 'EVALUATE ROW("Inscrits", CALCULATE([Inscrits], TREATAS({"2025-2026"}, DimAnnee[annee])))'
if([int]$latest -ne 10222){throw "Effectif inattendu : $latest"}
$reference=Import-Csv -LiteralPath (Join-Path $root 'outputs\tables\recette_filtres_powerbi.csv')
$count=0
foreach($row in $reference){
    $measure=switch($row.indicateur){
        'validation' {'Validation eligibles'}
        'passage' {'Passage'}
        'participation' {'Participation evaluation'}
        'satisfaction' {'Satisfaction'}
        'emploi' {'Emploi six mois'}
        'insertion_actifs' {'Insertion actifs'}
        default {throw "Indicateur inconnu : $($row.indicateur)"}
    }
    $forms=($row.formations -split '\|' | ForEach-Object {'"'+$_+'"'}) -join ','
    $query='EVALUATE ROW("Valeur", CALCULATE(['+$measure+'], TREATAS({"'+$row.annee+'"}, DimAnnee[annee]), TREATAS({'+$forms+'}, DimFormation[formation_id])))'
    $value=Invoke-DaxScalar $query
    if($row.valeur_attendue_R -eq ''){
        if($null -ne $value){throw "Une valeur protegee/non calculable a ete divulguee : $measure"}
        $row.valeur_observee_PowerBI=''
    }else{
        $expected=[double]::Parse($row.valeur_attendue_R,[Globalization.CultureInfo]::InvariantCulture)
        if($null -eq $value -or [math]::Abs([double]$value-$expected) -gt 1e-10){throw "Ecart R/DAX : $measure $($row.annee) $($row.filtre)"}
        $row.valeur_observee_PowerBI=([double]$value).ToString('R',[Globalization.CultureInfo]::InvariantCulture)
    }
    $row.statut='VALIDE_MOTEUR_DESKTOP'
    $count++
}
$reference | Export-Csv -LiteralPath (Join-Path $root 'outputs\tables\recette_filtres_powerbi.csv') -NoTypeInformation -Encoding UTF8
$result=[ordered]@{statut='valide';actualisation='exports_proteges';effectif_2025_2026=[int]$latest;comparaisons_R_DAX=$count;ecarts=0;validation_visuelle='distincte_de_cette_recette_moteur'}
$result | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $root 'outputs\powerbi-qa\recette-moteur.json') -Encoding UTF8
$result | ConvertTo-Json
$adomd.Close();$server.Disconnect()
