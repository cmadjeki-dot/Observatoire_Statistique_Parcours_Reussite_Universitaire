# Revue de cohérence — fiche d’identité, VS Code et cadrage

**Suivi :** cette revue décrit le premier contrôle de structure. La
[validation finale](23_validation_technique.md) la complète : renv est maintenant
synchronisé avec un sandbox local, 104 assertions passent et les réserves
actuelles sont recensées dans l’[audit sur 100](22_audit_final.md).

## Périmètre

La liste fournie décrit un cycle complet en 37 étapes. Cette revue traite les
trois besoins demandés : fiche d’identité, architecture adaptée à VS Code et
cadrage méthodologique initial. Elle réutilise les analyses et les livrables
déjà réalisés ; elle ne relance pas les phases historiques comme un projet neuf.

| Besoin | État initial | Décision |
|---|---|---|
| Fiche d’identité | Informations dispersées dans le README et le cahier des charges | Ajouter une synthèse liée aux références, sans recopier les résultats |
| Architecture VS Code | Arborescence fonctionnelle ; paramètres VS Code vides | Documenter l’existant et ajouter paramètres, recommandations et tâches |
| Cadrage initial | Cahier des charges, protocole, dictionnaires et recette déjà présents | Les conserver ; ajouter un notebook introductif sans analyse |
| Chemins | `project_path()` et marqueur `.here` déjà disponibles | Aucun nouvel utilitaire ni dépendance `here`/`fs` |
| Indicateurs | Dictionnaire et `config/indicator_definitions.yml` existants | Aucun second fichier `indicators.yml` |
| Tableaux de bord | Versions web, Shiny et Power BI dans `dashboards/` | Aucun dossier concurrent `dashboard/` |
| Environnement R | Activation, DESCRIPTION et lockfile existants | Conserver les versions ; ajouter une commande de restauration explicite |

## Simplifications

- Remplacer le démarrage imposé dans RStudio par l’ouverture du dossier VS Code.
- Conserver le `.Rproj` existant comme option, sans en créer un nouveau.
- Retirer l’échéance d’entretien obsolète du cahier des charges courant.
- Supprimer l’entrée `.quarto/` redondante de `.gitignore`.
- Ignorer les quatre copies générées des rapports à la racine : les sources
  canoniques restent dans `reports/`.
- Exclure les livrables et copies de diffusion de la découverte des dépendances
  avec `.renvignore` ; aucun package ou changement de lockfile nécessaire.
- Inclure la configuration VS Code et les pages sources du site dans l’archive
  de sources, qui ne les sélectionnait pas auparavant.

Le portail antérieur est encore utilisé comme source des ressources du site
Quarto. Il n’est pas supprimé : ce serait rompre une dépendance de construction.
Les journaux historiques sont conservés comme preuves datées, sans les présenter
comme l’état courant du projet.

## Vérifications de cette revue

| Contrôle | Statut constaté |
|---|---|
| JSON des trois fichiers VS Code | Valide |
| Tâches et chemins de scripts | Neuf tâches ; références aux scripts présentes |
| Liens documentaires contrôlés | 46 liens locaux valides |
| Syntaxe PowerShell du lanceur | Valide |
| Exécution R par le lanceur utilisé dans les tâches | Réussie sur `scripts/verify_structure.R` |
| Fichiers de structure attendus | 15 présents |
| Syntaxe des sources R, y compris les nouveaux scripts | 32 sources analysables |
| R sélectionné / version du lockfile | 4.6.1 / 4.6.1 |
| Git / Quarto CLI / VS Code | 2.55.0 / 1.10.18 / 1.142.0 détectés |
| Extension R | Installation locale 3.2.0 détectée |
| Extension Quarto | Non détectée ; recommandée dans VS Code, non installée par cette revue |
| Ignorés Git : données, sorties, `.env`, copies des rapports | Vérifié sur des chemins témoins |
| Sources et tâches VS Code | Non ignorées sur les chemins témoins |
| Dépôt distant | Aucun configuré ; aucune publication effectuée |
| Archive des sources actualisée | Intègre VS Code, le cadrage et les pages sources du site ; intégrité ZIP vérifiée |
| Site existant après actualisation des ressources | Dix pages, 244 liens locaux et treize chapitres vérifiés |

Les avertissements R de locale `C.UTF-8` subsistent au démarrage.
Les essais de vérification complète via `renv::status()` n’ont pas fourni de
bilan final dans le temps de cette revue ; ils ne sont pas déclarés validés.
Les succès antérieurs de tests et de calculs restent des preuves historiques.
Cette revue n’a pas recalculé les statistiques ni renouvelé les 85 assertions.
La preuve des contrôles documentaires et de structure de l’archive est enregistrée
dans `outputs/cadrage-architecture-qa/verification.json`.

## Refaire les contrôles

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_r.ps1 -Script scripts/verify_structure.R
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_r.ps1 -Script scripts/02_verify_setup.R
```

Les tâches sont configurées pour Windows et fixent le répertoire à la racine.
Leur lancement a été reproduit depuis PowerShell ; le déclenchement graphique
dans l’interface de VS Code n’a pas été automatisé.
