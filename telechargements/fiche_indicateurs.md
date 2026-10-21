# Maîtriser les huit indicateurs

Tous les exemples ci-dessous proviennent des données **entièrement fictives** préparées du projet. Ils ne représentent aucun résultat de l'UPEC. Clôture : 30 septembre 2026. Les pourcentages sont arrondis à une décimale ; les calculs conservent leur précision.

## Définitions et exemples calculés

| Indicateur | Définition opérationnelle dans ce projet | Exemple fictif et période |
|---|---|---|
| Effectifs inscrits | Nombre d'étudiants distincts avec une inscription principale dans le périmètre année–formation retenu | **10 222** en 2025-2026, toutes formations |
| Évolution des inscriptions | `(effectif courant − effectif précédent) / effectif précédent × 100` ; années consécutives et périmètre constant | `(10 222 − 8 026) / 8 026 × 100` = **+27,4 %**, de 2024-2025 à 2025-2026 |
| Réussite : validation annuelle | Validations connues / toutes les inscriptions éligibles ; les résultats inconnus restent au dénominateur, sans être qualifiés individuellement d'échecs | `7 478 / 10 222 × 100` = **73,2 %**, en 2025-2026 |
| Passage | Réinscrits au niveau immédiatement supérieur de la même formation / inscriptions de départ non terminales avec année suivante observable | `4 067 / 6 168 × 100` = **65,9 %**, de 2024-2025 à 2025-2026 |
| Réorientation | Réinscrits dans une autre formation / toutes les inscriptions de la cohorte de départ avec année suivante observable, terminales comprises | `193 / 8 026 × 100` = **2,4 %**, de 2024-2025 à 2025-2026 |
| Participation à l'évaluation | Répondants à au moins un item substantiel / invitations effectivement délivrées ; une inscription par vague | `4 967 / 9 805 × 100` = **50,7 %**, vague 2025-2026 |
| Satisfaction | Répondants ayant donné 4 ou 5 à l'item global / répondants ayant donné un avis valide de 1 à 5 | `2 942 / 4 120 × 100` = **71,4 %**, vague 2025-2026 |
| Emploi des diplômés à six mois | Diplômés éligibles répondants en emploi / diplômés éligibles répondants de situation connue, études comprises | `500 / 821 × 100` = **60,9 %**, diplômés 2024-2025, situation à six mois |

Le taux d'emploi des diplômés **2025-2026 est non observable à la clôture**, car six mois ne sont pas encore écoulés depuis les diplômes de juillet 2026. Il ne faut pas afficher 60,9 % sous un filtre « diplômés 2025-2026 ». Pour les transitions aussi, 2025-2026 ne peut être une cohorte de départ suivie dans cette fenêtre.

## Ce que signifie « réussite »

Choisir un libellé précis plutôt qu'alterner diplômés et validations dans un même indicateur :

- **Validation annuelle sur éligibles** : 7 478 / 10 222 = 73,2 %.
- **Couverture des résultats** : 9 934 / 10 222 = 97,2 %.
- **Validation parmi résultats connus** : 7 478 / 9 934 = 75,3 %.
- **Diplomation terminale** : 1 588 / 2 045 = 77,7 % parmi les inscrits de niveau terminal, en 2025-2026.

Ces résultats répondent à des questions différentes. Avec 288 résultats inconnus, la validation sur tous les éligibles est comprise entre 73,2 % et 76,0 % selon leur devenir hypothétique. Aucune valeur n'est imputée individuellement.

## Les pièges à expliquer à l'entretien

**Un total de personnes n'est pas toujours additif.** Dans une année, une inscription principale par étudiant permet de sommer les formations. Entre années, une personne peut réapparaître : la somme compte des inscriptions annuelles et ne donne pas l'effectif distinct sur trois ans.

**Une évolution relative diffère d'un écart en points.** Passer de 70 % à 75 % représente +5 points de pourcentage et environ +7,1 % en variation relative.

**Un taux agrégé se recalcule à partir des comptes.** Si une formation a 8 validations sur 10 et une autre 20 sur 100, le total est 28 / 110 = 25,5 %. La moyenne simple de 80 % et 20 % donnerait 50 %, ce qui est incorrect pour le taux global.

**Absence de réinscription ne signifie pas abandon.** Séparer réorientation, sortie documentée, fin de cycle diplômée et situation inconnue. La dernière année est censurée pour le suivi futur, pas égale à zéro passage.

**Non-réponse et insatisfaction sont distinctes.** Les avis absents et « sans avis » ne sont pas des notes défavorables. Une satisfaction élevée peut coexister avec une participation faible ; ne pas généraliser aux absents.

**Emploi et insertion parmi actifs ont des dénominateurs différents.** Pour les diplômés fictifs 2024-2025 : emploi = 500 / 821 = 60,9 % ; insertion parmi actifs = 500 / 612 = 81,7 %. Le second exclut études et inactivité ; aucune comparaison directe n'est justifiée sans expliciter le périmètre.

**Un dénominateur nul donne une valeur non calculable.** Afficher « Non observable », « Non calculable » ou « Masqué », selon le motif, plutôt que 0 %. Les petits comptes et leurs compléments sont protégés dans les exports Power BI.

## Lire la maquette proposée

Les cartes 5 000, 72 %, 81 % et 64 % étaient des nombres illustratifs. Une version alimentée par le projet afficherait pour 2025-2026 : **10 222 inscrits**, **73,2 % de validation annuelle**, **71,4 % de satisfaction parmi les avis exprimés** et **emploi à six mois non observable pour ces diplômés**.

Afficher la participation de 50,7 % à proximité de la satisfaction, la couverture de 97,2 % à proximité de la validation, et le numérateur/dénominateur en infobulle. Une carte d'emploi utilisant une autre cohorte doit porter explicitement son année de diplôme. Les filtres formation et année doivent s'appliquer aux comptes avant recalcul du taux.

Sources locales : `outputs/tables/scolarite_annuel.csv`, `outputs/tables/evaluation.csv`, `outputs/tables/insertion.csv`. Définitions détaillées dans `04_dictionnaire_indicateurs.md` ; règles de masquage et montage dans `dashboards/powerbi/README.md`.
