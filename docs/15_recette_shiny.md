# Application R Shiny — recette du 21 octobre 2026

Application dans `dashboards/shiny/`, lancement par `source("scripts/run_shiny.R")` depuis le projet RStudio. Le port 3838 était occupé ; l'application a été démarrée et vérifiée sur **http://127.0.0.1:3839**. Aucun processus existant n'a été arrêté pour libérer un port.

## Fonctionnalités

Même thème vert et mêmes trois vues que la version HTML : synthèse, parcours/devenir et huit fiches méthodologiques. Filtres année/formation, quatre cartes, évolution commutable, tableau des valeurs du graphique, couverture des résultats, transitions, distinction non observable/masqué et réinitialisation. Les calculs sont des réactifs R exécutés par Shiny ; l'application ne se limite pas à embarquer l'ancienne page HTML.

## Vérifications exécutées

- Dépendance Shiny installée et enregistrée dans `renv.lock`.
- 30 assertions Shiny réussies : agrégats attendus, dénominateurs, sélection, censure, masquage, données absentes et serveur réactif avec `shiny::testServer`.
- Suite complète : **85 assertions, zéro échec, zéro avertissement de test, zéro test ignoré**.
- Contrôle Chrome avec connexion réelle au serveur : cartes initiales, changements de formation et d'année, masquage, navigation parcours, censure, réinitialisation, graphique effectifs, navigation méthodes, huit fiches, ouverture d'une fiche et absence de débordement horizontal à 390 px.
- Captures bureau/mobile examinées dans `outputs/shiny-qa/`. Preuve des interactions : `recette-navigateur.json` dans ce dossier.

La session de lancement active la locale UTF-8 Windows pour lire correctement les accents. Les avertissements initiaux de locale, déjà présents dans l'environnement, sont distincts des résultats de tests. Le lanceur ne modifie pas la configuration système.

## Données et limites

Seuls les fichiers agrégés protégés de `outputs/exports/powerbi/` sont lus. Les comptes masqués sont absents avant le chargement de l'application et ne peuvent être retrouvés par filtre. Aucun identifiant individuel n'est transmis. Les données sont entièrement fictives et n'ont aucune portée institutionnelle sur l'UPEC.

L'année de diplôme est le filtre utilisé pour l'emploi. Les diplômés de juillet 2026 ne sont pas encore observables à six mois à la clôture du 30 septembre 2026. Les millésimes antérieurs sont masqués selon la règle conservatrice du paquet de diffusion.

L'application est **locale**. Aucun déploiement shinyapps.io, Posit Connect ou autre serveur Shiny n'a été fait. La version HTML Sites privée reste distincte ; elle n'a pas été remplacée. Redémarrer Shiny après une actualisation du pipeline pour recharger les exports.
