# Site de présentation Quarto

Le site classique est intégré à la racine du dépôt et généré dans `_site/`.
Il comporte une navigation, une recherche, la présentation du projet, les trois
tableaux de bord, les rapports et les téléchargements.

## Construire et consulter

Depuis la racine, avec R, Quarto et Python disponibles :

```powershell
$env:QUARTO_R = 'C:\Program Files\R\R-4.6.1\bin\Rscript.exe'
quarto render
quarto preview
```

Les données intermédiaires R doivent avoir été calculées. Les PDF et archives
doivent avoir été préparés avec les scripts existants :

```powershell
quarto render reports --execute-dir .
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/export_pdf.ps1
python scripts/build_dashboard_data.py
python scripts/build_presentation_site.py
quarto render
```

Sur un clonage neuf, restaurer d'abord `renv::restore()`, puis exécuter
`Rscript --vanilla scripts/run_pipeline.R` avant cette séquence. Les captures
sont versionnées dans `assets/previews/`. L'assembleur crée l'archive Power BI
depuis le projet PBIP sans dépendre d'un ZIP local préexistant. Vérifier ensuite
avec `python scripts/verify_classic_website.py`.

Les PDF existants dans `outputs/reports/reports/` sont réutilisés. Leur
régénération est assurée par `scripts/export_pdf.ps1` après production des
HTML autonomes avec le sous-projet `reports/`. Le rendu web n'actualise pas automatiquement les PDF.

Les quatre fichiers de rapport à la racine sont générés par
`scripts/prepare_website.py` depuis `reports/`, qui conserve les sources
canoniques. Modifier ces dernières pour apporter une correction à un rapport.

Le script `scripts/finish_website.py` ajoute les tableaux de bord, PDF,
captures et archives. Le tableau de bord web est directement utilisable ;
Shiny nécessite R et Power BI nécessite Desktop.

## Hébergement

Le contenu de `_site/` peut être envoyé sur un hébergement statique ou GitHub
Pages. Les liens sont relatifs. Aucun déploiement GitHub n'est réalisé par
ces commandes et aucun dépôt distant n'est actuellement configuré.

Le rapport final est disponible à `rapport_final.html` avec ses treize
chapitres numérotés et sa table des matières.
