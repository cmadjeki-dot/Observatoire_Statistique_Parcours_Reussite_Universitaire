# Vérification des 37 étapes

Revue du 2026-10-21 13:58 UTC. Les références équivalentes sont acceptées sans renommer les fonctions ou multiplier les dossiers. Une présence actuelle et une recette ne prouvent pas une chronologie historique exacte en 37 opérations.

**Statuts :** VALIDE = présence et vérification adaptées au besoin ; ADAPTE = fonction équivalente avec organisation conservée ; PARTIEL = preuve ou exigence restante ; NON_REALISE = opération non effectuée.

VALIDE : 23, ADAPTE : 13, PARTIEL : 1.

| Nº | Étape | Statut | Référence | Constat |
|---|---|---|---|---|
| 01 | Audit environnement | VALIDE | [scripts/audit_environment.R](../scripts/audit_environment.R) | Versions et packages controles ; renv coherent. Extension Quarto non detectee ; Rtools non detecte dans son emplacement standard, aucune compilation demandee. |
| 02 | Dossier projet | ADAPTE | [.here](../.here) | Dossier existant conserve ; aucun second projet Observatoire_Statistique_UPEC cree. |
| 03 | VS Code | PARTIEL | [.vscode/tasks.json](../.vscode/tasks.json) | Parametres et taches presents ; execution R reproduite par le lanceur. Extension Quarto recommandee, terminal graphique VS Code non automatise. |
| 04 | renv | VALIDE | [renv.lock](../renv.lock) | Activation et status executes. Sandbox local au projet pour eviter le verrou global partage. |
| 05 | Packages necessaires | ADAPTE | [DESCRIPTION](../DESCRIPTION) | Packages utilises charges et figes ; pas de metapackage tidyverse, here/fs/janitor ou package R quarto ajoutes sans usage. lintr 3.4.0 ajoute pour cet audit. |
| 06 | Architecture | ADAPTE | [docs/19_architecture_vscode.md](19_architecture_vscode.md) | Structure existante conservee : dashboards/ au pluriel, fonctions dans R/ ; pas de dossiers concurrents. |
| 07 | Chemins | ADAPTE | [R/functions/common.R](../R/functions/common.R) | project_path() et .here remplacent une seconde implementation here/fs. Aucun chemin Windows absolu dans R/. |
| 08 | Exclusions Git | VALIDE | [.gitignore](../.gitignore) | Donnees, sorties, caches, secrets et copies generees ignores ; exports publics selectionnes explicitement. |
| 09 | README initial | VALIDE | [README.md](../README.md) | Contexte, installation, architecture, reproduction, tableaux de bord et limites documentes. |
| 10 | Git local et premier commit | VALIDE | [.gitignore](../.gitignore) | Sources publiees sur main ; preuve et destination dans docs/26_publication_github.json. |
| 11 | Cadrage methodologique | VALIDE | [notebooks/00_cadrage_du_projet.qmd](../notebooks/00_cadrage_du_projet.qmd) | Fiche, protocole, populations, temporalite, indicateurs, limites et recette presents. |
| 12 | Simulation | ADAPTE | [R/01_generate_data.R](../R/01_generate_data.R) | generate_data() et inject_anomalies() remplissent les roles demandes ; 15000 personnes, huit tables, trois annees. |
| 13 | Tests des donnees | VALIDE | [tests/testthat/test-data.R](../tests/testthat/test-data.R) | 104 assertions dans la suite ; nouvelles verifications de dimensions, cles, relations et graine. Entree existante scripts/run_tests.R conservee. |
| 14 | Notebook generation | ADAPTE | [notebooks/01_generation_des_donnees.qmd](../notebooks/01_generation_des_donnees.qmd) | Generation et identite pour la meme graine executees. Reference propre dans data/synthetic/, copie degradee dans data/raw/ ; ecriture assuree par targets. |
| 15 | Notebook importation | ADAPTE | [notebooks/02_importation_description.qmd](../notebooks/02_importation_description.qmd) | glimpse(), types, summary() et distribution de la validation executes ; skimr non ajoute pour dupliquer ces resumes. |
| 16 | Controle qualite | ADAPTE | [notebooks/03_controle_qualite.qmd](../notebooks/03_controle_qualite.qmd) | R/02_validate_data.R, journal et recette des injections ; calculs du notebook executes. |
| 17 | Nettoyage | ADAPTE | [notebooks/04_nettoyage.qmd](../notebooks/04_nettoyage.qmd) | R/03_prepare_data.R et comparaison avant/apres ; bruts preserves, conflits isoles, tables processed produites. |
| 18 | Descriptif | VALIDE | [notebooks/05_analyse_descriptive.qmd](../notebooks/05_analyse_descriptive.qmd) | Tables de scolarite et figure produites par le pipeline, relues dans le notebook. |
| 19 | Choix du modele | VALIDE | [docs/09_methodologie_modeles.md](09_methodologie_modeles.md) | Cible binaire, observation par personne, glm et limites documentes ; discussion du modele mixte dans le notebook 06. |
| 20 | Modele de reussite | ADAPTE | [R/08_statistical_models.R](../R/08_statistical_models.R) | Coefficients, IC de Wald, diagnostics, calibration, separation apprentissage/evaluation et modele RDS produits ; notebook 06 execute. |
| 21 | Enquetes | ADAPTE | [notebooks/07_evaluation_formations.qmd](../notebooks/07_evaluation_formations.qmd) | Questionnaires et protocole dans surveys/ ; non-reponse et insertion calculees. LimeSurvey non importe ; alpha non pertinent pour un item global unique. |
| 22 | Longitudinal | VALIDE | [notebooks/08_analyse_longitudinale.qmd](../notebooks/08_analyse_longitudinale.qmd) | Cohortes et transitions executees ; censure, sortie documentee et inconnu distingues. |
| 23 | Faisabilite causale | VALIDE | [notebooks/09_analyse_causale.qmd](../notebooks/09_analyse_causale.qmd) | Hypotheses et donnees manquantes pour identifier un effet explicitees ; decision de ne pas estimer un effet causal. |
| 24 | Indicateurs decisionnels | ADAPTE | [notebooks/10_indicateurs_decisionnels.qmd](../notebooks/10_indicateurs_decisionnels.qmd) | Priorites et calculs presents ; config/indicator_definitions.yml reste la reference, aucun doublon indicators.yml. |
| 25 | Restitution decisionnelle | VALIDE | [notebooks/11_restitution_decisionnelle.qmd](../notebooks/11_restitution_decisionnelle.qmd) | Resultat, interpretation, implication et recommandation relies ; note de pilotage existante reutilisee. |
| 26 | Pipeline targets | VALIDE | [_targets.R](../_targets.R) | tar_make execute : 10 cibles declarees ; metadonnees controlees, aucune cible obsolete. |
| 27 | Notebook pipeline | VALIDE | [notebooks/12_pipeline_complet.qmd](../notebooks/12_pipeline_complet.qmd) | Lecture des metadonnees et des fichiers executee, sans second pipeline dans le notebook. |
| 28 | Audit technique | VALIDE | [scripts/audit_code.R](../scripts/audit_code.R) | 0 observation lintr sur R/, regles par defaut conservees ; tests, chemins et renv passent. Variables de donnees explicites, etat des closures explicite. |
| 29 | Shiny | ADAPTE | [dashboards/shiny/app.R](../dashboards/shiny/app.R) | Application existante conservee : trois vues regroupent les indicateurs. Demarrage HTTP et 30 assertions Shiny verifies ; pas de bslib ajoute ni six nouvelles pages dupliquees. |
| 30 | Rapport Quarto | VALIDE | [reports/rapport_final.qmd](../reports/rapport_final.qmd) | Nouveaux rendus HTML et PDF verifies ; 13 chapitres conserves. Acces au cache CSS autorise, theme et navigation conserves. |
| 31 | README final | VALIDE | [README.md](../README.md) | Liens vers l audit, preuves, reproduction et limites actualises. |
| 32 | Publication GitHub | VALIDE | [docs/11_publication.md](11_publication.md) | Sources publiees sur main ; preuve et destination dans docs/26_publication_github.json. |
| 33 | Presentation orale | VALIDE | [notebooks/13_presentation_orale.qmd](../notebooks/13_presentation_orale.qmd) | Afficher, dire, message cle, question et reponse renseignes ; support Markdown execute. Diaporama existant conserve. |
| 34 | Discours 3 a 5 minutes | VALIDE | [docs/24_preparation_orale.md](24_preparation_orale.md) | Discours redige a partir des chiffres verifies ; duree visee, non mesuree en situation orale. |
| 35 | Trente questions de jury | VALIDE | [docs/24_preparation_orale.md](24_preparation_orale.md) | 30 questions, reponses courtes, developpements et pieges ; pas de passage reel devant un jury revendique. |
| 36 | Audit sur 100 | VALIDE | [docs/22_audit_final.md](22_audit_final.md) | Evaluation argumentee selon le bareme demande ; autoevaluation documentaire, pas certification externe. |
| 37 | Validation finale | VALIDE | [docs/23_validation_technique.md](23_validation_technique.md) | Controles locaux R, lintr, renv, schemas Power BI et rendus passes. Publication distante et validation institutionnelle hors perimetre. |

[Audit sur 100](22_audit_final.md) · [Validation technique](23_validation_technique.md).
