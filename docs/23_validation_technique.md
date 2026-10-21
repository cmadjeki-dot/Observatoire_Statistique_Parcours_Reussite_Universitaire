# Validation technique finale

Exécution du 2026-10-21 13:50 UTC. Statut global : **validation technique locale réussie sur le périmètre contrôlé**.

| Contrôle | Statut réel | Preuve |
|---|---|---|
| Pipeline targets | VALIDE : 10 cibles déclarées, aucune obsolète ; calculs réexécutés | `outputs/validation_finale/validation_R.log`, `targets_meta.csv` |
| Tests testthat | VALIDE : 104 assertions, 13 cas, 0 échec, 0 warning, 0 ignoré | `outputs/validation_finale/tests.csv` |
| renv | VALIDE : synchronized=TRUE, packages disponibles ; lockfile actualisé pour lintr | `outputs/validation_finale/renv_status.rds`, `audit_code.log` |
| Syntaxe et chemins R | VALIDE : aucune erreur de parse ni chemin Windows absolu dans R/ | `scripts/verify_structure.R`, `chemins_absolus_metier.csv` |
| Notebooks | VALIDE pour les calculs : 18 supports exécutés via knitr | `outputs/validation_finale/notebooks.csv` et `notebooks_knit/` |
| Rendu HTML Quarto actuel | VALIDE : rapports, notebooks et site rendus avec le cache CSS accessible | `rendu_rapports.log`, `rendu_notebooks.log`, `rendu_site.log` |
| HTML/PDF | Nouveaux rendus, intégrité et mentions vérifiées ; note de deux pages | `scripts/verify_artifacts.py`, `outputs/tables/recette_pdf.json` |
| lintr 3.4.0 | VALIDE : 0 style, 0 warning, 0 error sur R/, règles par défaut conservées | `outputs/validation_finale/lintr.csv` et `lintr.txt` |
| Shiny | VALIDE : serveur de recette accessible en HTTP sur 3847, puis arrêté ; 30 assertions dans la suite | `shiny_smoke.json`, `shiny_stderr.log` |
| Tableau web | VALIDE : 18 contrôles JavaScript après correction du chemin du test | `dashboards/interactive/test-dashboard.cjs` |
| Site | Nouveau rendu ; navigation, ressources et treize chapitres contrôlés ; apparence conservée | `outputs/site-classique-qa/verification.json` |
| Modèle Power BI TOM | VALIDE : 7 tables, 6 relations, 35 mesures | `outputs/powerbi-qa/recette-modele.json` |
| Schémas PBIR Python | VALIDE : 79 fichiers, 0 erreur, dépendances Python figées | `outputs/validation_finale/schemas_powerbi.log` |
| Exports protégés | VALIDE : six fichiers strictement identiques avant/après correction (SHA-256) | `outputs/validation_finale/corrections_validees.json` |
| Moteur DAX et canvas Desktop | Recette historique conservée ; pas de nouvelle recette moteur ni de contrôle visuel exhaustif | `docs/16_recette_powerbi.md` |
| Git | Dépôt local sur master, fichiers non suivis, aucun commit ni remote ; aucun push | `outputs/validation_finale/git.txt` |
| CI GitHub et LimeSurvey | NON EXECUTES dans leurs services respectifs | `docs/11_publication.md`, `surveys/protocols/protocole.md` |

## Corrections réalisées pendant la revue

Le sandbox renv a été isolé dans `renv/sandbox/`, sans désactiver l’isolation.
Les dépendances lintr sont figées. Les notebooks manquants, la faisabilité
causale, le discours court et les trente questions sont ajoutés. Le test web
utilise son propre dossier au lieu du répertoire courant. Les rapports et les
notebooks ont désormais leur sous-projet Quarto, séparé du site.

## Refaire les contrôles

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_r.ps1 -Script scripts/validate_final.R
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_r.ps1 -Script scripts/audit_code.R
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_r.ps1 -Script scripts/validate_notebooks.R
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_r.ps1 -Script scripts/smoke_shiny.R
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_r.ps1 -QuartoCommand render -Reports
.venv-powerbi/Scripts/python.exe scripts/validate_powerbi_project.py
python scripts/verify_classic_website.py
```

Le rendu requiert un cache CSS accessible. Après une nouvelle autorisation,
les rendus normaux réussissent ; le thème n’a pas été remplacé pour contourner
le problème. Les anciens échecs restent des preuves historiques, pas le statut
actuel. Le validateur Power BI s’installe avec `scripts/setup_powerbi_validation.ps1`.
La CI comprend désormais des contrôles lintr et Power BI, sans exécution distante
revendiquée dans cette session.

Les journaux PowerShell peuvent étiqueter la sortie stderr de R comme
`NativeCommandError` lors des warnings de locale. Le résultat du contrôle
est établi à partir du code de sortie, des fichiers structurés et des assertions,
pas de cette étiquette seule.

[Matrice des 37 étapes](21_verification_37_etapes.md) · [Audit sur 100](22_audit_final.md).
