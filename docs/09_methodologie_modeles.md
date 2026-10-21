# Analyse exploratoire — cadre d'interprétation

Les comparaisons descriptives par cohorte d'entrée dans la fenêtre, formation et profil se trouvent dans `outputs/tables/modele_comparisons.csv`. Une cohorte d'entrée observée ne constitue pas une cohorte nationale de bacheliers. La composition (type de bac, bourse, âge, niveau) accompagne les taux ; aucun classement de valeur des formations n'en découle.

Le modèle principal conserve la première inscription chronologique de chaque personne, puis les résultats connus et profils bac/bourse complets. Cible : validation annuelle oui/non ; inconnus exclus et comptés. Variables disponibles avant le jury : formation, niveau, âge à l'inscription, bac, bourse et année. ECTS, diplôme, transition, jury et identifiant sont exclus. La répétition des personnes n'entre donc pas dans ce modèle initial.

Découpage aléatoire reproductible 70/30 entre étudiants, sans chevauchement. Il évalue une généralisation à d'autres étudiants de cette même simulation et **pas une prédiction temporelle sur une année future**. Vérifications : convergence, rang, erreurs standards finies, coefficients extrêmes, événements par paramètre, VIF des colonnes de la matrice. Pas de détection parfaite garantie de tous les biais ; un diagnostic défavorable bloque le modèle.

Les odds ratios et intervalles de Wald à 95 % sont des associations conditionnelles sous le modèle. Leur taille n'est pas une différence de probabilités. Les profils standardisés illustrent les probabilités prédites à âge 21, premier niveau, bac général, non-boursier et année initiale ; ils ne représentent pas un individu réel ou une moyenne de formation. Le Brier et l'AUC sont calculés sur l'échantillon réservé ; calibration en déciles et pente/intercept de calibration complètent l'évaluation. Pas d'intervalle de précision pour l'AUC dans cette version.

La table d'exclusions compare résultats, formation et année entre inclus et exclus. Une sensibilité conserve les profils manquants comme catégories explicites, sur tous les résultats connus. Elle change simultanément le périmètre et la paramétrisation ; elle n'est ni une imputation ni une preuve d'absence de biais. Le modèle ne corrige pas les résultats inconnus.

Toutes les associations proviennent du mécanisme artificiel décrit dans `08_simulation.md`. Aucune conclusion causale, aucun diagnostic individuel et aucune généralisation à l'UPEC. Les intervalles expriment les hypothèses de l'exercice statistique, pas une incertitude institutionnelle.
