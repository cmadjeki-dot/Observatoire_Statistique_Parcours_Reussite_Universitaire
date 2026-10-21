# Fiche d’identité du projet

| Rubrique | Référence du projet |
|---|---|
| Intitulé | Observatoire statistique des parcours et de la réussite universitaire |
| Nature | Démonstrateur professionnel et pédagogique ; aucune statistique officielle |
| Contexte | Mission universitaire simulée, inspirée des besoins d’un observatoire UPEC / DEVE / SPOF, sans affiliation officielle |
| Problématique | Comment transformer des données de scolarité et d’enquêtes en indicateurs fiables, compréhensibles et reproductibles pour le pilotage ? |
| Utilisateurs visés | Chargés d’études, responsables de formation et responsables du pilotage |
| Données | Huit tables relationnelles entièrement synthétiques, générées par le code du projet |
| Population simulée | 15 000 personnes distinctes à la génération, cinq formations fictives, licences et masters |
| Fenêtre | Années 2023-2024 à 2025-2026 ; clôture d’observation au 30 septembre 2026 |
| Unités | Personne, inscription principale annuelle, résultat annuel, diplôme et réponse à une vague d’enquête |
| Axes d’étude | Inscriptions, validation, diplomation, transitions, satisfaction, participation et devenir à six mois |
| Méthodes | Statistiques descriptives, suivi de cohortes, analyse de la non-réponse et modèle logistique exploratoire |
| Livrables | Données préparées et journal qualité ; indicateurs documentés ; tableaux de bord web, Shiny et Power BI ; rapports et site Quarto |
| Socle technique | R et renv pour les dépendances, targets pour le pipeline, testthat pour les contrôles, Git pour les sources |
| Éditeur principal | VS Code ; le fichier RStudio existant reste une commodité facultative |
| Reproductibilité | Graine et dates dans `config/parameters.yml`, versions R et packages dans `renv.lock`, dépendances de calcul dans `_targets.R` |
| Diffusion | Sources et agrégats sélectionnés ; tables individuelles et caches exclus par défaut |
| Statut | Calculs et livrables locaux réalisés ; aucune publication GitHub ni Power BI Service annoncée |

## Responsabilités dans la simulation

Le chargé d’études maintient les définitions, les contrôles et le journal des
décisions. Le commanditaire métier simulé arbitre les populations et les usages
attendus. Une utilisation institutionnelle réelle exigerait une validation par
les responsables compétents ; elle ne fait pas partie du démonstrateur.

## Critères de réussite

Les clés et les temporalités sont contrôlées ; les anomalies sont tracées ;
chaque taux possède une population de référence explicite ; les censures,
valeurs manquantes et petits effectifs sont traités sans fabrication de
résultats. Le pipeline, les tests et les restitutions doivent être exécutables
depuis la racine, avec des preuves de validation identifiables.

## Références uniques

- [Cahier des charges](01_cahier_des_charges.md) : questions métier et livrables.
- [Protocole statistique](02_protocole_statistique.md) : unités, temporalité, manquants et limites.
- [Dictionnaire des données](03_dictionnaire_donnees.md) et [des indicateurs](04_dictionnaire_indicateurs.md).
- [Plan de validation](06_plan_validation.md) : critères de recette par jalon.
- [Architecture et utilisation de VS Code](19_architecture_vscode.md).

Les résultats chiffrés restent dans les livrables calculés : cette fiche ne les
recopie pas pour éviter une seconde source à actualiser.
