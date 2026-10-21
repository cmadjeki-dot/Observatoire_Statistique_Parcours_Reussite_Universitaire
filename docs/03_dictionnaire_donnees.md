# Modèle relationnel initial

Les clés doivent être non nulles et uniques. Le relevé exhaustif des variables, types, modalités et manquants générés est disponible dans `dictionnaire_variables.csv`. Les règles sémantiques ci-dessous complètent ce relevé. Toutes les dates sont au format ISO et tous les identifiants sont des chaînes fictives.

| Table | Grain et clé | Relations et variables minimales |
|---|---|---|
| etudiants | personne ; etudiant_id | annee_naissance, type_bac, boursier, annee_entree_observee |
| formations | formation ; formation_id | libelle_fictif, composante_fictive, cycle, niveau_terminal |
| inscriptions | inscription ; inscription_id | etudiant_id, formation_id, annee, niveau, regime ; unicité étudiant–année |
| resultats | bilan annuel ; inscription_id | validation (oui/non/inconnue), ects, date_jury |
| parcours | transition ; inscription_id | statut, inscription_suivante_id nullable, source_information, date_observation, censure |
| evaluation | sollicitation ; evaluation_id | inscription_id, vague, sollicitation_delivree, reponse, satisfaction_1_5 nullable |
| diplomes | diplôme ; diplome_id | inscription_id, date_diplome, type_diplome |
| insertion | sollicitation ; insertion_id | diplome_id, vague, date_enquete, eligible, sollicitation_delivree, reponse, situation |

Les tables d'enquête contiennent aussi les sollicitations sans réponse afin de calculer la participation. Une personne peut obtenir plusieurs diplômes ; sélectionner explicitement l'unité d'analyse du devenir. La table parcours est dérivée des inscriptions et d'informations de suivi simulées, avec une seule règle de classification versionnée.

## Variables et valeurs manquantes

- `etudiant_id`, `formation_id`, `inscription_id`, `evaluation_id`, `diplome_id`, `insertion_id` : identifiants non nuls. Les clés étrangères sont obligatoires, sauf `inscription_suivante_id` lorsqu'aucune réinscription n'est observée. Cardinalités étudiant 1–N inscriptions, formation 1–N inscriptions ; inscription 1–1 résultat, parcours et invitation d'évaluation ; inscription 0–1 diplôme ; diplôme 1–1 ligne d'éligibilité/invitation à six mois.
- `annee_naissance` : entier sans manque, cohérent avec le cycle et niveau d'entrée. `type_bac` : général, technologique, professionnel ou NA inconnu ; `boursier` : entier 0/1 ou NA inconnu. Les profils manquants sont simulés indépendamment après génération des trajectoires.
- `annee_entree_observee` : première année d'inscription dans la fenêtre ; `primo_entrant_observe` : booléen d'entrée observée au premier niveau du cycle, ne décrit pas une première inscription nationale.
- `libelle_fictif`, `composante_fictive`, `cycle` : chaînes non nulles du référentiel ; `niveau_terminal` : 3 en licence, 2 en master. `niveau` : entier 1 à ce terminal ; `annee` : une des trois années configurées ; `regime` : initiale ou reprise.
- `validation` : oui, non, inconnue, jamais NA ; `ects` : entier 0–60, 60 si oui, moins de 60 si non, NA si inconnue ; `date_jury` : date de bilan annuel, y compris pour un résultat inconnu.
- `statut` : passage, redoublement, reorientation, fin_formation_diplomee, sortie_observee, inconnue ou censuree. `source_information` : inscriptions, diplome, suivi_fictif_explicite, absence_information ou fenetre_close ; `date_observation` : date du suivi ; `censure` : booléen de dernière année. La source fictive de sortie est explicite, aucune inférence d'abandon.
- `vague` : année pour l'évaluation, six_mois pour l'insertion ; unicité inscription–vague ou diplôme–vague. `sollicitation_delivree`, `reponse`, `consentement` : booléens sans manque. Le consentement concerne l'évaluation ; aucun envoi réel n'est effectué.
- `satisfaction_1_5`, `organisation_1_5` : entiers 1–5 ou NA ; `motif_satisfaction` : avis, sans_avis, item_manquant, non_reponse ou non_sollicite. L'organisation renseignée établit la réponse substantielle lorsque l'item global manque.
- `date_diplome` : date terminale, identique au jury dans cette simulation ; `type_diplome` : Licence ou Master.
- `date_reference` : diplôme + six mois calendaires ; `eligible` : référence atteinte à la clôture ; `date_enquete` : égale à la référence pour les éligibles, NA sinon. `situation` : emploi, recherche_emploi, etudes, inactif, inconnue ; NA si non-réponse ou non-éligibilité. Le motif de manque s'obtient par les indicateurs d'éligibilité, délivrance et réponse.
