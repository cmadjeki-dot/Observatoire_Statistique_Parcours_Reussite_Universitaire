# Tableau de bord Power BI natif — 21 octobre 2026

Le livrable est `dashboards/powerbi/Observatoire/Observatoire.pbip`, avec ses dossiers Report, SemanticModel et Data. Trois pages et 70 visuels natifs sont générés : synthèse, parcours/devenir et huit définitions. Le thème vert et les quatre cartes reprennent les versions HTML et Shiny. Les filtres année/formation sont synchronisés entre les deux pages analytiques.

## Contrôles réellement exécutés

- Génération des fichiers PBIP, PBIR et TMSL ; données limitées aux agrégats protégés.
- **79 fichiers validés contre les schémas publics Microsoft, zéro erreur.**
- Modèle désérialisé par Tabular Object Model fourni avec Desktop : sept tables, six relations, 35 mesures ; références des colonnes et mesures vérifiées.
- Ouverture du projet dans **Power BI Desktop 2.146.1454.0**, titre de fenêtre Observatoire, moteur Analysis Services local détecté.
- Actualisation complète des partitions depuis les CSV protégés réussie.
- **126 comparaisons R/DAX dans le moteur Desktop : zéro écart**, sur chaque année, chaque formation, toutes formations et deux formations sélectionnées ensemble.
- Les valeurs numériques attendues manquantes restent BLANK : les comptes masqués ne sont pas reconstitués. La carte d'emploi utilise un libellé distinct « Non observable » pour les non-éligibles, « Masqué » pour les suppressions.

Les preuves locales se trouvent dans `outputs/powerbi-qa/recette-projet.json`, `recette-modele.json` et `recette-moteur.json`. La matrice `outputs/tables/recette_filtres_powerbi.csv` est renseignée avec les observations DAX et le statut `VALIDE_MOTEUR_DESKTOP`.

La vérification des calculs par le moteur et la validation des schémas ne constituent pas une inspection exhaustive du rendu visuel et de toutes les interactions dans Desktop. Le rapport a été ouvert en arrière-plan ; aucune capture du canvas natif n'est revendiquée.

## Ouvrir et actualiser

Double-cliquer sur le PBIP ou sur `ouvrir_observatoire.cmd`. Conserver les dossiers voisins. Aucun cache ABF n'est livré : cliquer sur **Accueil → Actualiser** à la première ouverture si les cartes sont vides. Sur un autre poste ou après extraction ailleurs, régler le paramètre `DossierExports` vers le dossier `Data` extrait, avec un `/` final.

Pour produire un `.pbix`, utiliser **Fichier → Enregistrer sous** dans Desktop. Le PBIP est un format de projet natif, pas une archive renommée en PBIX. Aucun PBIX ni déploiement dans le service Power BI n'est annoncé.

La dimension `DimAnneeGraph` ne filtre pas les faits directement : les mesures du graphique appliquent son année avec TREATAS après retrait du filtre d'année principal. La courbe conserve donc les trois années en respectant la formation sélectionnée. Les cartes restent sur l'année choisie.

Le jeu 2025-2026 affiche 10 222 inscrits, 73,2 % de validation annuelle et 71,4 % de satisfaction. Les diplômés de juillet 2026 n'ont pas encore atteint six mois au 30 septembre 2026. Tous les chiffres sont fictifs, sans résultat réel ni affiliation à l'UPEC.

## Reproduction

`python scripts/build_powerbi_project.py` régénère les sources et copie les CSV protégés. `scripts/validate_powerbi_project.py` vérifie les schémas et les références ; `scripts/validate_powerbi_model.ps1` valide le TMSL avec la bibliothèque Desktop ; `scripts/verify_powerbi_engine.ps1` actualise et compare le modèle ouvert aux sorties R. Une nouvelle production R remet la matrice de rapprochement à vérifier ; relancer alors la recette moteur.

Références : [PBIP](https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-overview), [PBIR](https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-report), [modèle de projet](https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-dataset).
