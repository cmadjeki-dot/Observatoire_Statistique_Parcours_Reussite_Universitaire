# Corrections de lintr, Power BI et Quarto

## Code R

Les règles lintr par défaut sont conservées : aucune règle désactivée, aucune
exclusion globale ajoutée. Le périmètre de l’audit reste `R/`.

Les fonctions partagées sont chargées avant l’analyse statique, comme dans le
pipeline. Les colonnes utilisées dans les masques dplyr et ggplot2 sont
explicitées avec `.data`, et les sélections de colonnes utilisent des noms de
colonnes explicites. Les accumulateurs des fonctions imbriquées utilisent
désormais un environnement local explicite plutôt que `<<-`. La calibration
logistique reçoit un tableau de données explicite. Ces changements ne modifient
ni les populations, ni les formules, ni la graine.

Le formatage utilise deux espaces et une largeur de 80 caractères. Les outils
formatR et styler sont figés dans renv, au même titre que lintr. Ils servent
au développement ; ils n’interviennent pas dans les calculs statistiques.
Le cache de styler est désactivé pour cette commande de formatage, pas les
contrôles lintr.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_r.ps1 -Script scripts/audit_code.R
```

Cette commande échoue désormais si une observation subsiste. Le contrôle est
également ajouté à la CI préparée, sans exécution GitHub revendiquée.

## Validateur des schémas Power BI

Le validateur ajoutait `outputs/powerbi-qa/python` au chemin de recherche des
modules. Ce répertoire incomplet fournissait un module `referencing` sans
`Registry`. Ce chargement forcé est supprimé.

L’environnement dédié `.venv-powerbi/` est ignoré par Git. Ses dépendances
exactes sont dans `requirements-powerbi.txt` : jsonschema 4.26.0 et referencing
0.37.0, avec leurs dépendances. La validation porte sur les schémas Microsoft
draft-07, les références du modèle, les relations et les exports agrégés protégés.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/setup_powerbi_validation.ps1
.venv-powerbi/Scripts/python.exe scripts/validate_powerbi_project.py
```

Résultat : 79 fichiers vérifiés, zéro erreur ; sept tables, six relations et
35 mesures. Cela ne constitue pas une nouvelle inspection visuelle exhaustive
du canvas ni une publication dans Power BI Service.

## Rendus Quarto

Le blocage provenait de l’accès au cache CSS dans le contexte restreint.
Une nouvelle exécution autorisée accède à ce cache et rend les documents avec
leur thème normal. Le thème et la navigation du site ne sont pas remplacés.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_r.ps1 -QuartoCommand render -Reports
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_r.ps1 -QuartoCommand render -Notebooks
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/export_pdf.ps1
python scripts/build_presentation_site.py
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_r.ps1 -QuartoCommand render
python scripts/verify_classic_website.py
```

Les sous-projets `reports/` et `notebooks/` ont leurs sorties locales séparées.
Les PDF sont régénérés avant l’assemblage du site. L’activation renv évite de
réactiver inutilement le même projet lorsque plusieurs contrôles sont lancés
dans une session R.

## Preuves et limites

Les fichiers structurés sont dans `outputs/validation_finale/` : tests, lintr,
schémas, journaux des rendus et empreintes SHA-256. Les 104 assertions passent
et les six exports protégés sont strictement identiques avant et après
correction. Les sources de la page d’accueil, du projet, des tableaux de bord
et le style du site sont inchangés.

Les avertissements de locale de Windows au démarrage de R restent distincts
des avertissements de tests ou de lintr. La restauration sur une machine vierge,
la CI distante, le terminal graphique VS Code et la publication GitHub restent
des contrôles ou opérations distincts.

[Validation technique courante](23_validation_technique.md) ·
[Audit courant](22_audit_final.md).
