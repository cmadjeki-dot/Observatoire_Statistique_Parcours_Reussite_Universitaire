"""Ajoute uniquement les supports pedagogiques absents, sans copier les fonctions."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SETUP = '''```{r}
#| include: false
source("scripts/activate_environment.R")
source("R/functions/common.R", encoding = "UTF-8")
```
'''
BOOKS = {
'01_generation_des_donnees': ('Génération des données synthétiques', '''La référence propre est dans `data/synthetic/`. `data/raw/` conserve la copie dégradée après injection d’anomalies : ne pas écraser cette dernière avec une nouvelle génération propre.

```{r}
for (p in list.files("R", "[.]R$", full.names = TRUE)) source(p, encoding = "UTF-8")
cfg <- read_config()
x <- generate_data(cfg)
stopifnot(identical(x, generate_data(cfg)), nrow(validate_data(x, cfg)) == 0L)
knitr::kable(data.frame(table = names(x), lignes = vapply(x, nrow, integer(1))))
```

La graine est fixée dans la configuration. L’écriture des fichiers est assurée par targets, pas par ce notebook de lecture et de vérification.
'''),
'02_importation_description': ('Importation et description initiale', '''Les tables brutes sont conservées sans nettoyage. Les résumés ci-dessous décrivent leurs types, modalités et manquants. `summary()` complète `glimpse()` sans ajouter une dépendance `skimr` pour cette seule restitution.

```{r}
raw <- readRDS("data/raw/tables.rds")
dplyr::glimpse(raw$etudiants)
summary(raw$etudiants)
knitr::kable(as.data.frame(table(raw$resultats$validation, useNA = "ifany")))
```

Ces distributions contiennent les anomalies contrôlées. Elles ne décrivent pas encore le périmètre analytique et ne permettent aucune conclusion causale.
'''),
'03_controle_qualite': ('Contrôle qualité et traçabilité', '''Les règles sont dans `R/02_validate_data.R`. La correction ne consulte pas le registre d’injection comme une vérité permettant de reconstruire les lignes.

```{r}
q <- readRDS("data/interim/qualite.rds")
knitr::kable(readr::read_csv("outputs/tables/recette_injections.csv", show_col_types = FALSE))
knitr::kable(head(q$journal, 15))
```

[Plan qualité](../docs/05_plan_qualite.md). Les journaux détaillés et clés synthétiques restent des objets de travail locaux.
'''),
'04_nettoyage': ('Nettoyage et préparation', '''Les données brutes ne sont pas modifiées. Les doublons exacts sont supprimés, les conflits non arbitrables et leurs dépendances mis en quarantaine ; les manquants substantiels ne sont pas automatiquement imputés.

```{r}
q <- readRDS("data/interim/qualite.rds")
knitr::kable(q$volumes)
knitr::kable(as.data.frame(table(q$journal$controle, q$journal$statut)))
```

Les tables finales sont dans `data/processed/`. Consulter `R/03_prepare_data.R` et le journal pour les décisions exactes.
'''),
'05_analyse_descriptive': ('Analyse descriptive des étudiants', '''Les effectifs annuels ne s’additionnent pas pour obtenir un nombre de personnes distinctes. Comparer les formations suppose d’examiner la composition et la couverture des résultats.

```{r}
i <- readRDS("data/interim/indicateurs.rds")
knitr::kable(i$counts$annuel)
knitr::kable(i$counts$formation)
knitr::include_graphics(normalizePath("outputs/figures/validation.png", winslash = "/"), rel_path = FALSE)
```

La validation sur tous les éligibles, la validation parmi les résultats connus et la diplomation sont des indicateurs distincts. Les petits effectifs de travail ne sont pas destinés à la diffusion publique.
'''),
'06_modelisation': ('Modélisation exploratoire de la réussite', '''Le modèle existant est justifié dans [la méthodologie](../docs/09_methodologie_modeles.md). Une inscription par personne évite la répétition des observations dans ce premier modèle. Un modèle mixte demanderait une autre unité et une justification de la structure de dépendance ; cinq formations fictives ne suffisent pas à imposer ce choix.

```{r}
m <- readRDS("data/interim/modeles.rds")
knitr::kable(m$diagnostics)
knitr::kable(m$odds_ratios)
knitr::kable(m$calibration)
```

Les coefficients sont des associations conditionnelles du mécanisme simulé. Les intervalles de Wald reposent sur les hypothèses du modèle. L’AUC et le Brier concernent l’échantillon réservé. Le modèle ajusté est sauvegardé dans le composant `model` de l’objet RDS ; aucune décision individuelle n’est autorisée par ces résultats.
'''),
'07_evaluation_formations': ('Évaluation des formations et enquêtes', '''Les questionnaires et le protocole existent dans `surveys/`. Ils sont des matrices de transposition LimeSurvey, sans import natif validé. La satisfaction repose sur un item global : un alpha de cohérence interne ne serait pas justifié pour cet indicateur à item unique.

```{r}
e <- readRDS("data/interim/enquetes.rds")
knitr::kable(e$evaluation$counts)
knitr::kable(head(e$evaluation$profiles, 15))
knitr::kable(e$insertion)
```

La participation utilise les sollicitations délivrées ; la satisfaction utilise les avis valides. Les écarts de profil des répondants décrivent un risque de non-réponse sans fournir un redressement automatique. Le devenir n’est calculable que lorsque six mois sont observables.
'''),
'08_analyse_longitudinale': ('Parcours et suivi longitudinal', '''Une transition exige une année suivante observable. Les cohortes d’entrée observées ne représentent pas tous les primo-entrants historiques. Une absence de réinscription ne prouve pas un abandon.

```{r}
i <- readRDS("data/interim/indicateurs.rds")
knitr::kable(i$counts$cohorte)
knitr::kable(i$counts$annuel)
```

Les passages, redoublements, réorientations, sorties documentées, fins diplômées et situations inconnues doivent rester séparés. La dernière année est censurée pour le devenir ultérieur.
'''),
'09_analyse_causale': ('Faisabilité d’une analyse causale', '''## Question et effet d’intérêt

Une question comme « quel serait l’effet d’un accompagnement sur la validation ? » exige un traitement défini, un groupe de comparaison, une temporalité et une population cible. Ces informations ne sont pas observées ici.

## Association, prédiction et causalité

Une association conditionnelle du modèle ne mesure pas une intervention. Une probabilité prédite décrit une cible sous un modèle, pas le résultat contrefactuel du même étudiant sous un autre accompagnement.

## Hypothèses d’identification

L’échangeabilité demanderait de mesurer les causes communes de participation et de réussite. La positivité demanderait des étudiants comparables exposés et non exposés. La cohérence demanderait une intervention homogène. L’absence d’interférence, les manquants et les changements de population devraient aussi être examinés.

Les tables ne contiennent ni affectation randomisée, ni dispositif documenté, ni instrument crédible, ni seuil d’assignation, ni série avant/après permettant de défendre un tel dessin. Les paramètres du générateur sont connus par construction ; cela ne valide pas une identification sur des données institutionnelles.

## Décision

Aucun effet causal n’est estimé. Les comparaisons restent descriptives et le modèle exploratoire. Pour une étude réelle, définir le protocole avant collecte, les covariables antérieures au traitement, la stratégie d’identification et les analyses de sensibilité. Aucun résultat causal n’est fabriqué pour compléter une liste de livrables.
'''),
'10_indicateurs_decisionnels': ('Indicateurs décisionnels prioritaires', '''Les priorités sont les inscrits, leur évolution, la validation et sa couverture, le passage, la réorientation, la participation, la satisfaction, la diplomation et l’emploi à six mois lorsque calculable.

```{r}
i <- readRDS("data/interim/indicateurs.rds")
knitr::kable(i$metrics)
knitr::kable(i$evolution)
```

Les formules, dénominateurs, exclusions et millésimes sont centralisés dans `config/indicator_definitions.yml` et [le dictionnaire](../docs/04_dictionnaire_indicateurs.md). Ne pas moyenner les taux de formations ; recomposer les sommes de numérateurs et dénominateurs lorsque la diffusion l’autorise.
'''),
'11_restitution_decisionnelle': ('Restitution décisionnelle', '''```{r}
i <- readRDS("data/interim/indicateurs.rds")
e <- readRDS("data/interim/enquetes.rds")
knitr::kable(i$counts$annuel)
```

| Constat à vérifier dans les tables | Interprétation | Implication et recommandation |
|---|---|---|
| Résultats annuels inconnus | Couverture imparfaite de la validation | Documenter le circuit de remontée avant de comparer les formations |
| Participation variable selon les profils | Les avis peuvent être sélectionnés | Examiner les profils de non-réponse et le protocole de relance |
| Horizon récent non observable | Absence de recul, pas absence d’emploi | Programmer une observation à maturité et afficher « non observable » |
| Discrimination limitée du modèle | Prédiction individuelle peu informative | Conserver le modèle comme exercice exploratoire |

Ces recommandations illustrent une démarche sur données fictives ; elles ne prescrivent aucune action à un service réel de l’UPEC. [Note de pilotage](../reports/note_pilotage.qmd).
'''),
'12_pipeline_complet': ('Pipeline reproductible targets', '''Les fonctions restent dans `R/` et le graphe dans `_targets.R`. Le notebook inspecte les métadonnées et les fichiers présents ; il ne relance pas les calculs.

```{r}
knitr::kable(targets::tar_meta(fields = c(name, error, seconds)))
knitr::kable(data.frame(fichier = list.files("outputs/tables", pattern = "[.]csv$")))
```

Pour actualiser : `source("scripts/run_pipeline.R")`. targets recalcule les cibles dont le code, les paramètres ou les dépendances ont changé. Une cible sautée parce qu’à jour n’est pas une nouvelle exécution de son calcul.
'''),
}

def main():
    for name, (title, body) in BOOKS.items():
        path = ROOT / 'notebooks' / f'{name}.qmd'
        if path.exists():
            continue
        text = f'---\ntitle: "{title} — données entièrement fictives"\nlang: fr\nformat:\n  html:\n    toc: true\n---\n\n'
        text += 'Support pédagogique local. Exécuter le pipeline depuis la racine avant rendu. Les tables détaillées de travail ne sont pas des exports publics.\n\n'
        if '```{r}' in body:
            text += SETUP + '\n'
        path.write_text(text + body, encoding='utf-8')
        print(path.name)

if __name__ == '__main__':
    main()
