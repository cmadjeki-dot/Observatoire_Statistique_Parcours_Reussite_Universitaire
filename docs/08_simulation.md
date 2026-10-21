# Mécanisme de simulation

Données entièrement fictives, sans calage sur des statistiques de l'UPEC. Graine et hypothèses dans `config/parameters.yml`. La reproductibilité s'entend à version R et dépendances identiques (`renv.lock`).

15 000 personnes entrent dans la fenêtre selon des probabilités 40 %, 30 %, 30 %. La première année contient un stock de niveaux variés ; les années suivantes introduisent des entrants en première année de licence ou master. Le premier niveau observé ne suffit pas à définir une cohorte d'entrée dans l'enseignement supérieur. `primo_entrant_observe` désigne ici une entrée au premier niveau du cycle dans la fenêtre, pas une primo-inscription nationale.

Cinq formations fictives réparties dans trois composantes. La validation est tirée selon un modèle logistique artificiel : intercept 0,80, effets de formation configurables, +0,18 par niveau au-delà du premier, effets de type de bac (+0,30 général, −0,15 technologique, −0,45 professionnel), −0,10 boursier et +0,05 par année. Ces coefficients ne constituent aucune observation empirique. Les profils latents sont utilisés pour la simulation avant introduction de 4 % de manquants sur le bac et le statut boursier.

2,5 % des bilans annuels sont inconnus, ECTS manquants associés. Les autres bilans valent 60 ECTS si validation, 0 à 54 sinon. La réinscription a une probabilité de 94 % après validation non terminale, 70 % dans les autres cas, zéro après diplôme terminal. Les validants progressent d'un niveau ; parmi les autres réinscrits, 12 % se réorientent vers une autre formation du même cycle au premier niveau. Il n'y a pas de pause puis retour dans cette version. Les diplômes sont dérivés des validations terminales connues.

Le parcours classe dans l'ordre : censure de dernière année ; autre formation ; passage ; redoublement ; fin de formation diplômée ; sortie explicitement documentée (40 % des absences sans diplôme) ; situation inconnue. Le diplôme atteste la fin d'un cycle, pas la sortie de tout l'enseignement supérieur. Les dates de suivi n'excèdent pas la clôture.

Une invitation d'évaluation par inscription : délivrance 96 %, réponse logistique avec intercept 0,10, effets de formation configurables et effet boursier −0,20. Parmi les répondants, 5 % sans avis à l'item global et 12 % d'item manquant ; un item organisation reste renseigné, ce qui établit la réponse substantielle. Satisfaction tirée sur 1–5 avec probabilités 4 %, 8 %, 17 %, 40 %, 31 %. Aucune pondération appliquée.

Une ligne d'insertion par diplôme permet de compter aussi les non-éligibles et les non-répondants. Horizon de six mois calendaires, diplômes datés au 15 juillet. Parmi les éligibles : délivrance 94 %, réponse 61 %, puis emploi 57 %, recherche 13 %, études 24 %, inactivité 3 %, situation inconnue 3 %. Ces probabilités sont uniquement pédagogiques. L'unité d'analyse est le diplôme ; aucune personne ne peut obtenir deux diplômes dans ce scénario sans retour après diplôme.
