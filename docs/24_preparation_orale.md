# Préparation orale — démonstrateur sur données fictives

## Discours de trois à cinq minutes

Ce projet répond à une question simple : comment transformer des données de
scolarité et des enquêtes en informations fiables pour le pilotage d’une
formation ? J’ai construit un observatoire de démonstration inspiré d’un contexte
universitaire. Toutes les données sont fictives : aucun résultat ne décrit
l’UPEC et le projet n’a pas d’affiliation officielle avec cet établissement.

La simulation suit quinze mille personnes sur trois années universitaires et
cinq formations. Il faut distinguer une personne, son inscription annuelle,
son diplôme et sa réponse à une enquête. Cette distinction détermine les clés
de jointure et les dénominateurs : un étudiant présent trois années ne doit pas
être compté comme trois personnes dans une population distincte.

J’ai commencé par définir les questions métier et les règles de calcul. J’ai
ensuite généré les tables, introduit des anomalies contrôlées et construit une
chaîne de contrôle et de préparation. Les données brutes sont conservées.
Les doublons exacts sont traités et les conflits non arbitrables sont isolés
avec leurs dépendances. Chaque correction est traçable. Les tests couvrent
les dénominateurs nuls, les manquants, les cohortes et les règles de diffusion.

Sur la dernière année de la simulation, le périmètre préparé comprend 10 222
inscrits et 7 478 validations connues, soit 73,2 % des inscrits éligibles.
Ce taux doit être lu avec les 288 résultats inconnus ; ceux-ci ne constituent
pas des échecs individuels établis. Le taux parmi les seuls résultats connus
est un autre indicateur. Pour les enquêtes, je distingue aussi la participation
parmi les personnes sollicitées et la satisfaction parmi les avis exprimés.

Le suivi des parcours exige une précaution supplémentaire : ne plus observer
une réinscription ne signifie pas automatiquement un abandon. Je distingue
la réorientation, la sortie documentée et la situation inconnue. La dernière
année est censurée pour les transitions futures. De même, le devenir à six mois
des diplômés récents n’est pas observable au 30 septembre 2026 ; je l’affiche
comme tel au lieu de produire un zéro trompeur.

J’ai également estimé un modèle logistique exploratoire. Je réserve des personnes
pour l’évaluation et j’exclus les variables qui révéleraient déjà le résultat,
comme les ECTS ou la décision de jury. Son AUC d’environ 0,607 indique une
discrimination limitée. Il sert à expliquer la démarche statistique, pas à
prendre une décision individuelle ni à mesurer un effet causal.

Enfin, les calculs sont organisés avec targets, les versions des packages sont
figées avec renv, et les restitutions sont proposées dans Quarto, Shiny et
Power BI. L’intérêt professionnel est de rendre chaque chiffre explicable :
d’où vient-il, quelle population décrit-il et jusqu’où peut-on l’interpréter ?
Pour une application réelle, je commencerais par faire valider ces définitions,
les règles d’accès et le calendrier d’observation avec les responsables métier.

Chiffres à rapprocher des sorties courantes avant chaque présentation. La durée
visée dépend du débit de parole ; elle n’a pas été mesurée en situation d’oral.

## Trente questions de jury

| Nº | Question | Réponse courte | Développement et piège à éviter |
|---|---|---|---|
| 1 | Quel besoin métier ? | Produire des indicateurs explicables pour le pilotage. | Identifier utilisateurs et décisions avant de choisir des graphiques. Ne pas promettre une action réelle sur ces simulations. |
| 2 | Pourquoi des données synthétiques ? | Démontrer la chaîne sans données personnelles réelles. | Le mécanisme simulé détermine les associations. Ne pas attribuer les résultats à l’UPEC. |
| 3 | Quelle unité statistique ? | Elle dépend de l’indicateur. | Personne, inscription annuelle, diplôme et réponse à une vague ont des clés différentes. Ne pas additionner les inscrits annuels comme des personnes distinctes. |
| 4 | Comment gérer les jointures ? | Vérifier clés, cardinalités et intégrité référentielle. | Une jointure plusieurs-à-plusieurs non prévue peut multiplier les lignes. Contrôler les volumes et les totaux avant et après. |
| 5 | Pourquoi garder les données brutes ? | Pour préserver la traçabilité. | Corriger une copie et journaliser la décision. Ne pas effacer les anomalies à la source. |
| 6 | Que faire d’un doublon contradictoire ? | Arbitrer par une règle défendable ou isoler. | Les dépendances peuvent aussi devoir être mises en quarantaine. Ne pas conserver arbitrairement la première ligne. |
| 7 | Une valeur manquante vaut-elle zéro ? | Non. | Distinguer inconnu, non applicable, sans avis et non-réponse. Une imputation doit être justifiée, pas automatique. |
| 8 | Comment définir la réussite ? | Comme une validation annuelle dans ce périmètre. | La diplomation terminale est distincte. Toujours préciser population éligible et période. |
| 9 | Quel dénominateur pour la validation ? | Tous les inscrits éligibles pour l’indicateur principal. | Publier la couverture et le taux parmi résultats connus séparément. Ne pas changer silencieusement de population. |
| 10 | Comment calculer une évolution ? | Différence relative à l’année précédente. | Vérifier un dénominateur non nul et un périmètre comparable. Des points de pourcentage ne sont pas une variation relative. |
| 11 | Comment agréger plusieurs taux ? | Recomposer les numérateurs et dénominateurs. | Une moyenne simple de pourcentages pondère mal des groupes différents. Respecter aussi les masquages. |
| 12 | Qu’est-ce qu’une cohorte ? | Une population définie par un événement d’entrée commun. | Les entrants observés ne sont pas tous les primo-entrants historiques. Fixer la définition et l’horizon. |
| 13 | Une absence de réinscription est-elle un abandon ? | Pas sans information complémentaire. | Elle peut refléter mobilité, fin de cycle ou situation inconnue. Ne pas fabriquer un statut. |
| 14 | Qu’est-ce que la censure ? | Le devenir dépasse la fenêtre observable. | Exclure du dénominateur de suivi selon la règle documentée. Ne pas coder la dernière année comme un échec de passage. |
| 15 | Quel taux de participation ? | Répondants substantiels sur invitations délivrées. | Les personnes non effectivement sollicitées ne doivent pas gonfler le dénominateur. Une réponse partielle peut compter. |
| 16 | Quel taux de satisfaction ? | Satisfaits sur avis valides exprimés. | Sans-avis et items vides sont exclus et dénombrés. Ne pas confondre satisfaction et participation. |
| 17 | Comment examiner la non-réponse ? | Comparer les profils connus des répondants et des sollicités. | Cela décrit un risque de sélection sans le supprimer. Ne pas généraliser automatiquement aux absents. |
| 18 | Pourquoi pas un alpha de Cronbach ? | L’indicateur global repose sur un seul item. | Une échelle multi-item demanderait une justification conceptuelle et des contrôles adaptés. Ne pas calculer un coefficient par réflexe. |
| 19 | Comment mesurer l’emploi ? | À un horizon et sur une population explicitement retenus. | Emploi parmi situations connues et insertion parmi actifs ont des dénominateurs différents. Vérifier la maturité à six mois. |
| 20 | Le questionnaire est-il opérationnel dans LimeSurvey ? | Les matrices sont préparées, sans import validé. | Il faut transposer les codes, tester le routage, les refus et les réponses partielles. Ne pas annoncer une collecte réalisée. |
| 21 | Pourquoi une régression logistique ? | La cible de validation est binaire. | Le modèle estime des associations conditionnelles ; une inscription par personne évite ici la répétition. Ne pas assimiler un odds ratio à un risque relatif. |
| 22 | Pourquoi pas un modèle mixte ? | Il faut d’abord justifier l’unité et la dépendance. | Les mesures répétées ou groupes peuvent le motiver ; le modèle initial a une observation par personne. Cinq groupes fictifs ne rendent pas ce choix automatique. |
| 23 | Qu’est-ce qu’une fuite de cible ? | Utiliser une information qui révèle déjà le résultat. | Les ECTS finaux ou la décision de jury ne sont pas des prédicteurs antérieurs légitimes. Contrôler aussi la séparation des personnes entre échantillons. |
| 24 | Comment lire l’AUC ? | Comme une mesure de classement des deux classes. | Environ 0,607 indique ici une discrimination limitée. Examiner également calibration et Brier, sans promettre un usage individuel. |
| 25 | Le modèle démontre-t-il une causalité ? | Non. | Une intervention, une stratégie d’identification et des hypothèses défendables manquent. Ne pas appeler « effet » une association conditionnelle. |
| 26 | Que garantit renv ? | Des versions de packages documentées et restaurables. | `restore()` rejoue le lockfile ; `snapshot()` enregistre un changement volontaire. Le système et les outils externes restent à documenter. |
| 27 | Que garantit targets ? | Un graphe de dépendances et un recalcul sélectif. | Le code et les entrées déterminent les cibles à refaire. Une cible à jour n’est pas recalculée et un pipeline vert ne valide pas un rapport distant. |
| 28 | Pourquoi dplyr, Shiny et Quarto ? | Transformer, explorer et restituer des résultats cohérents. | dplyr traite les tables ; Shiny nécessite un serveur R ; Quarto produit le site et les rapports. Un site statique n’exécute pas Shiny. |
| 29 | Comment traiter RGPD et petits effectifs ? | Distinguer simulation et exigences d’une collecte réelle. | Aucun contact réel n’est présent ; le seuil de démonstration ne prouve pas une conformité juridique. Prévoir accès, minimisation et validation compétente pour un vrai dispositif. |
| 30 | Le projet est-il publié et entièrement validé ? | Il faut consulter les statuts et preuves, pas seulement les fichiers. | Git local ne signifie pas GitHub ; PBIP ne signifie pas publication Service. Présenter les contrôles actuels et leurs limites, sans transformer une préparation en exécution. |

Pour une réponse détaillée, utiliser la dernière colonne puis montrer la preuve
correspondante dans le rapport ou le dictionnaire. Les trois domaines à ne jamais
confondre sont la validité technique, la validité statistique et l’usage métier.
