# Observatoire étudiant — R Shiny

Même thème et mêmes indicateurs que le tableau de bord HTML. Trois vues : synthèse, parcours/devenir et huit fiches méthodologiques. Filtres année/formation, graphique validation/effectifs/satisfaction, valeurs accessibles en tableau, couverture des résultats et réinitialisation.

## Lancer depuis RStudio

Ouvrir `Observatoire.Rproj`, puis dans la console :

```r
source("scripts/run_shiny.R")
```

L'application écoute sur **http://127.0.0.1:3839** (3838 était déjà occupé lors de la vérification). Le navigateur s'ouvre dans une session interactive. Pour arrêter : bouton Stop de RStudio ou Échap. Pour utiliser un autre port : `Sys.setenv(OBS_SHINY_PORT = "3840")` avant le lancement.

Sur une nouvelle machine : restaurer `renv::restore()`, exécuter le pipeline R si les exports sont absents, puis lancer l'application. `source("scripts/setup_shiny.R")` sert à installer Shiny dans l'environnement existant ; la version est enregistrée dans `renv.lock`.

## Données et périmètre

L'application lit seulement `outputs/exports/powerbi/` : agrégats déjà protégés, sans identifiants individuels. Aucun accès aux tables brutes, aucune valeur masquée transmise au navigateur. Après actualisation du pipeline, redémarrer l'application pour recharger les fichiers. Les sources sont vérifiées au démarrage : grain, types, identifiants interdits et comptes masqués réellement absents.

Les proportions sont recalculées après filtrage. La dernière année est censurée pour les transitions ; le devenir des diplômés 2025-2026 est non observable à six mois à la clôture du 30 septembre 2026. L'insertion des années antérieures est masquée selon la règle conservatrice du projet. Aucun zéro ne remplace ces états.

## Vérifier

```r
source("scripts/test_shiny.R")
```

Les tests couvrent les calculs attendus, masquage, censure, filtres et sorties réactives avec `shiny::testServer`. Lancement local uniquement ; aucun déploiement shinyapps.io ou Posit Connect n'est effectué. Le site HTML privé reste une version distincte.
