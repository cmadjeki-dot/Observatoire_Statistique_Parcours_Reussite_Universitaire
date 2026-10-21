# Bilan d’exécution courant

Le bilan courant est fondé sur la [matrice des 37 étapes](21_verification_37_etapes.md),
l’[audit final sur 100](22_audit_final.md) et la [validation technique](23_validation_technique.md).
Les recettes des huit jalons initiaux restent disponibles dans `docs/recettes/`.

## Ce qui est exécuté et vérifié

- Pipeline targets recalculé : dix cibles déclarées, aucune obsolète.
- Suite testthat : 104 assertions, dont 30 Shiny ; aucun échec, warning ou test ignoré.
- Calculs des 18 notebooks exécutés via knitr, indépendamment du rendu HTML.
- renv synchronisé ; verrou global contourné par un sandbox isolé dans le projet,
  sans désactiver l’isolation des bibliothèques.
- lintr exécuté : aucune observation sur `R/`, règles par défaut conservées.
- Démarrage Shiny sur un port de recette, accès HTTP, puis arrêt du processus créé.
- Dix-huit contrôles JavaScript du tableau web réussis.
- Modèle Power BI vérifié avec TOM : sept tables, six relations, 35 mesures.
- 79 schémas Power BI validés avec un environnement Python dédié et figé.
- Rapports, 18 notebooks et site Quarto rendus à nouveau ; PDF régénérés,
  dont la note de pilotage de deux pages.
- Six exports protégés strictement identiques avant/après correction (SHA-256).

## Ce qui ne doit pas être annoncé comme terminé

Les anciennes réserves lintr, schémas Python et cache CSS Quarto sont levées ;
voir [les corrections et leurs preuves](25_corrections_validation.md).
La recette historique du moteur DAX est conservée ; elle n’a pas été renouvelée
pendant cet audit. Aucune inspection exhaustive du canvas Desktop n’est revendiquée.

Git est local, sans commit ni dépôt distant. Aucune publication GitHub ou Power BI
Service n’est effectuée. Les questionnaires sont des matrices non importées
dans LimeSurvey. La CI GitHub n’a pas été exécutée dans le service.

## Conclusion de recette

**89/100 : validation technique locale réussie sur le périmètre contrôlé.**
Les détails, commandes et preuves se trouvent dans les trois
documents de référence ci-dessus. Les données restent entièrement fictives et
aucun résultat ne décrit l’UPEC.
