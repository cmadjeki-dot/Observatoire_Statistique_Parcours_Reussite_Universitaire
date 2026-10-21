# Journal d'initialisation — 21 octobre 2026

- Dossier initial : `.vscode/` uniquement ; aucun fichier utilisateur remplacé.
- Création du projet RStudio, de la structure, du cadrage et des prompts des huit phases.
- Git 2.55.0 : dépôt local initialisé, sans commit ni dépôt distant.
- R 4.6.1 utilisé via `C:/Program Files/R/R-4.6.1/bin/Rscript.exe` ; Rscript absent du PATH. R 4.6.0 également présent, non utilisé.
- Quarto 1.10.18 détecté ; exécutable RStudio présent, interface non lancée.
- Première tentative renv interrompue après absence de progression ; reprise avec accès élargi. Bibliothèque de projet ensuite explicitement activée et dépendances installées avec succès. La reprise initiale avait aussi installé des dépendances dans la bibliothèque utilisateur R.
- `renv.lock` créé à partir des versions effectivement installées. Diagnostic détaillé dans `outputs/environment_check.txt`, ignoré par Git.
- Avertissements de locale au démarrage de R : repli sur C. À traiter avant de dépendre de tris linguistiques ou de dates localisées.
- Aucune donnée synthétique encore générée ; prochaine étape : modèle détaillé et simulation, phase 2.
