# Architecture et travail dans VS Code

## Principes

Conserver les fonctions métier dans `R/`, les commandes dans `scripts/` et les
règles dans `config/`. Les notebooks expliquent les traitements ; ils ne
remplacent pas le pipeline. Ne pas créer un second dossier `dashboard/` ou un
second dictionnaire `indicators.yml` : `dashboards/` et
`config/indicator_definitions.yml` remplissent déjà ces fonctions.

```text
.
├── .vscode/                 paramètres, extensions recommandées, tâches
├── config/                  paramètres de simulation et définitions
├── R/                       fonctions de simulation, qualité et analyse
│   └── functions/           utilitaires communs, dont project_path()
├── scripts/                 lanceurs, contrôles et construction des livrables
├── data/                    données régénérables, exclues de Git
│   ├── synthetic/           simulation de référence
│   ├── raw/                 copie dégradée, conservée sans correction
│   ├── reference/           registre des anomalies injectées
│   ├── processed/           tables préparées
│   └── interim/             objets d’analyse intermédiaires
├── notebooks/               cadrage et explorations pédagogiques
├── surveys/                 questionnaires et protocole des enquêtes
├── dashboards/              interactive/, shiny/ et powerbi/
├── reports/                 sources canoniques des rapports et styles
├── docs/                    méthodes, dictionnaires et preuves de recette
├── tests/testthat/          tests des fonctions et des indicateurs
├── renv/                    activation et configuration, bibliothèque ignorée
├── outputs/                 résultats, exports, PDF et preuves locales ignorés
├── sites/presentation/      assembleur et ressources du portail antérieur
├── _site/                   site Quarto généré, ignoré
├── _targets.R               graphe des calculs
├── renv.lock                versions figées de R et des packages
├── _quarto.yml              site principal
└── *.qmd                    pages du site ; copies des rapports générées
```

Le portail antérieur n’est pas un second point d’entrée : son assembleur fournit
encore les ressources téléchargées par le site Quarto. Il ne doit donc pas être
supprimé tant que cette dépendance existe. Les quatre copies de rapports à la
racine sont générées et ignorées ; modifier leurs sources dans `reports/`.

## Ouvrir et configurer

1. Ouvrir **le dossier racine** dans VS Code, avec `code .` ou « Ouvrir un dossier ».
2. Installer les extensions recommandées R et Quarto depuis `.vscode/extensions.json`.
3. Installer la version de R indiquée dans `renv.lock`, ainsi que Quarto CLI.
4. Dans « Terminal → Exécuter la tâche », lancer la restauration renv sur une
   nouvelle machine, puis la vérification de l’environnement.

Les tâches utilisent `scripts/run_r.ps1`. Il cherche `Rscript.exe` dans
`OBSERVATOIRE_RSCRIPT`, dans l’installation Windows correspondant au lockfile,
puis dans le PATH. Pour une installation différente, définir la variable dans
le terminal avant d’ouvrir VS Code :

```powershell
$env:OBSERVATOIRE_RSCRIPT = 'D:/Outils/R/bin/Rscript.exe'
code .
```

Ce chemin est une configuration de poste, pas une dépendance du code métier.
Le lanceur fixe le répertoire de travail à la racine et transmet le chemin R
à Quarto. Le terminal R interactif de l’extension se configure séparément dans
les paramètres utilisateur si sa détection automatique échoue ; la tâche
« ouvrir une console R » est également disponible.

Les tâches PowerShell autorisent l’exécution **pour leur processus seulement**
avec `-ExecutionPolicy Bypass`, sans modifier la stratégie du système.
L’extension Quarto facilite l’édition ; le rendu reste assuré par Quarto CLI.
Le fichier `.Rproj` déjà présent peut être conservé sans être requis par VS Code.

## Commandes de référence

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_r.ps1 -Script scripts/restore_environment.R
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_r.ps1 -Script scripts/02_verify_setup.R
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_r.ps1 -Script scripts/run_pipeline.R
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_r.ps1 -Script scripts/run_tests.R
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_r.ps1 -QuartoCommand render
```

`renv::restore()` réinstalle les versions du lockfile. `renv::snapshot()`
enregistre un changement volontaire de dépendances : ne pas l’utiliser pour
reproduire une version existante. `scripts/01_bootstrap.R` est réservé à
l’initialisation ou à une mise à jour explicite, pas au démarrage quotidien.

Les tâches de pipeline et de tests sont les commandes par défaut des groupes
« build » et « test ». Shiny et la prévisualisation Quarto restent actifs
jusqu’à leur arrêt dans le terminal. Rien n’est lancé à l’ouverture du dossier.

## Chemins et dépendances

`project_path()` dans `R/functions/common.R` recherche le marqueur `.here`.
Conserver cet utilitaire existant ; ajouter `R/utils/paths.R`, `here` ou `fs`
uniquement pour reproduire les noms d’une liste créerait une duplication.
Les fonctions métier ne doivent pas contenir de chemin personnel Windows.

L’activation passe par `scripts/activate_environment.R`, appelé par `.Rprofile`
et les scripts d’entrée. Il conserve renv et ses versions figées en utilisant
un sandbox dans `renv/sandbox/`, ignoré de Git, pour éviter le verrou du sandbox
global partagé avec d’autres sessions R. Une valeur `RENV_PATHS_SANDBOX` déjà
définie par l’utilisateur reste prioritaire.

R et les packages du lockfile suffisent au pipeline statistique. Python sert
aux assembleurs et vérificateurs web. Chrome ou Edge sert à l’export PDF.
Power BI Desktop sert à ouvrir le PBIP. Rtools devient nécessaire si une
dépendance R doit être compilée depuis ses sources ; ce n’est pas une raison
pour ajouter des packages sans usage dans le code.

## Versionner et diffuser

Versionner le code, les définitions, les sources documentaires, les tâches et
le lockfile. Les données générées, les sorties, les caches, les fichiers
personnels et les secrets restent ignorés. Les CSV publiables sont les exports
agrégés protégés sélectionnés par l’assembleur, pas l’ensemble de `data/`.

Le site complet requiert aussi ses archives, PDF et captures préalablement
préparés : voir [le guide de construction web](18_site_quarto.md). Un pipeline
R réussi ne prouve pas un rendu web, une validation Power BI ou une publication
distante. Les recettes doivent garder ces statuts distincts.
