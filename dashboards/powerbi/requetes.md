# Requêtes Power Query

Créer chaque requête vide sous le nom indiqué et coller son expression dans l'éditeur avancé. `DossierExports` doit être un paramètre texte de dossier absolu finissant par `/`.

DimFormation :
```powerquery
let Source = fxCsv("dim_formation.csv", {"formation_id", "libelle_fictif", "composante_fictive", "cycle"}, false) in Source
```

DimAnnee :
```powerquery
let Source = fxCsv("dim_annee.csv", {"annee"}, false) in Source
```

FactScolarite :
```powerquery
let Source = fxCsv("fait_scolarite.csv", {"annee", "formation_id", "masque"}, true) in Source
```

FactEvaluation :
```powerquery
let Source = fxCsv("fait_evaluation.csv", {"annee", "formation_id", "masque"}, true) in Source
```

FactInsertion :
```powerquery
let Source = fxCsv("fait_insertion.csv", {"annee", "formation_id", "masque"}, true) in Source
```
