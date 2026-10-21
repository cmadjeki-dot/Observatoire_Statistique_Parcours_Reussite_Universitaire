# Audit final — 89/100

Autoévaluation technique et documentaire du 2026-10-21 13:50 UTC, selon le barème demandé. Cette note motive un jugement ; elle ne constitue pas une certification ni une mesure statistique de qualité.

| Domaine | Note | Justification |
|---|---|---|
| Cadrage | 10/10 | Unites, populations, questions et limites explicites. |
| Architecture | 9/10 | Sources uniques et taches VS Code ; dependances de diffusion encore complexes et poste Windows. |
| Donnees | 10/10 | Simulation relationnelle, graine, integrite et generation verifiees. |
| Qualite | 9/10 | Regles, journal, quarantaine et controles ; validation metier institutionnelle hors perimetre. |
| Statistiques | 13/15 | Denominateurs, couverture, cohortes et non-reponse ; precision et redressement des enquetes non developpes. |
| Modelisation | 12/15 | Evaluation reservee, calibration et sensibilite ; discrimination limitee et absence de validation externe ou IC d AUC. |
| Code R | 9/10 | 0 observation lintr sur R/, formatage coherent, .data explicite et etat local des closures ; scripts de poste et fonctions metier restent distincts. |
| Tests | 5/5 | 104 assertions, 13 cas, aucun echec, avertissement ou test ignore. |
| Reproductibilite | 5/5 | targets, renv, dependances Python figees, rendus et empreintes des exports verifies sur ce poste ; une machine vierge reste un controle distinct. |
| Restitution | 4/5 | Nouveaux rendus HTML/PDF et 79 schemas Power BI valides ; relecture exhaustive du canvas et validation institutionnelle hors perimetre. |
| Presentation | 3/5 | Diaporama, discours et 30 questions ; duree et prestation non evaluees en situation. |

**Total : 89/100.**

## Verdict

**Validation technique locale réussie sur le périmètre contrôlé.** Les trois réserves techniques de l’audit initial sont levées : lintr sans observation, 79 schémas Power BI valides et nouveaux rendus Quarto réussis. Les exports protégés sont strictement identiques à ceux d’avant correction. La publication GitHub n’est pas réalisée et n’est pas un préalable au fonctionnement local.

## Réserves levées

1. Règles lintr conservées : références de colonnes explicites, fonctions partagées chargées pour l’analyse, état local des closures et formatage corrigés. Aucun masquage global des avertissements.
2. Validateur Power BI isolé dans `.venv-powerbi/`, versions figées dans `requirements-powerbi.txt` ; ancien dossier Python incomplet exclu du chargement.
3. Accès au cache CSS Quarto autorisé : rendus normaux réussis sans changer le thème ni la navigation.

Pour une diffusion publique, choisir destination et licence, sélectionner les sources, créer les commits et publier uniquement dans le périmètre confirmé.

## Améliorations non bloquantes

Installer l’extension Quarto recommandée, vérifier le terminal intégré VS Code, chronométrer l’oral et réaliser une relecture visuelle exhaustive du canvas Power BI. Une nouvelle restauration renv sur une machine vierge reste un contrôle distinct de la synchronisation réussie sur ce poste.

Les warnings de locale au démarrage restent distincts des résultats de tests et de lintr : aucun avertissement de test ni aucune observation lintr dans la recette actuelle. La note initiale était de 84/100 ; elle est réévaluée après les corrections vérifiées.
