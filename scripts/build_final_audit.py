"""Synthese de l'audit : preuves courantes, equivalences et reserves explicites."""
import csv
import hashlib
import json
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'outputs/validation_finale'

def read_csv(name):
    with (OUT/name).open(encoding='utf-8', newline='') as stream:
        return list(csv.DictReader(stream))

def main():
    publication_path = ROOT/'docs/26_publication_github.json'
    publication = json.loads(publication_path.read_text(encoding='utf-8')) if publication_path.exists() else {}
    published = publication.get('sources_publiees') is True
    tests = read_csv('tests.csv')
    passed = sum(int(x['passed']) for x in tests)
    assert sum(int(x['failed']) for x in tests) == 0
    assert all(x['error'] in ('FALSE','False','false') for x in tests)
    notebooks = read_csv('notebooks.csv')
    assert all(x['statut'] == 'VALIDE_CALCULS' for x in notebooks)
    lint = read_csv('lintr.csv')
    kinds = Counter(x['type'] for x in lint)
    correction = json.loads((OUT/'corrections_validees.json').read_text(encoding='utf-8'))
    assert correction['statut'] == 'VALIDE' and not lint
    schemas = json.loads((ROOT/'outputs/powerbi-qa/recette-projet.json').read_text(encoding='utf-8'))
    assert schemas['schema_errors'] == 0 and schemas['schema_files_validated'] == 79
    assert json.loads((OUT/'shiny_smoke.json').read_text())['statut'] == 'VALIDE'
    assert (ROOT/'outputs/validation_finale/renv_status.rds').exists()
    rows = [
      (1,'Audit environnement','VALIDE','scripts/audit_environment.R','Versions et packages controles ; renv coherent. Extension Quarto non detectee ; Rtools non detecte dans son emplacement standard, aucune compilation demandee.'),
      (2,'Dossier projet','ADAPTE','.here','Dossier existant conserve ; aucun second projet Observatoire_Statistique_UPEC cree.'),
      (3,'VS Code','PARTIEL','.vscode/tasks.json','Parametres et taches presents ; execution R reproduite par le lanceur. Extension Quarto recommandee, terminal graphique VS Code non automatise.'),
      (4,'renv','VALIDE','renv.lock','Activation et status executes. Sandbox local au projet pour eviter le verrou global partage.'),
      (5,'Packages necessaires','ADAPTE','DESCRIPTION','Packages utilises charges et figes ; pas de metapackage tidyverse, here/fs/janitor ou package R quarto ajoutes sans usage. lintr 3.4.0 ajoute pour cet audit.'),
      (6,'Architecture','ADAPTE','docs/19_architecture_vscode.md','Structure existante conservee : dashboards/ au pluriel, fonctions dans R/ ; pas de dossiers concurrents.'),
      (7,'Chemins','ADAPTE','R/functions/common.R','project_path() et .here remplacent une seconde implementation here/fs. Aucun chemin Windows absolu dans R/.'),
      (8,'Exclusions Git','VALIDE','.gitignore','Donnees, sorties, caches, secrets et copies generees ignores ; exports publics selectionnes explicitement.'),
      (9,'README initial','VALIDE','README.md','Contexte, installation, architecture, reproduction, tableaux de bord et limites documentes.'),
      (10,'Git local et premier commit','PARTIEL','.gitignore','Depot initialise, branche master ; aucun commit ni remote. Aucun commit automatique sur les fichiers non suivis.'),
      (11,'Cadrage methodologique','VALIDE','notebooks/00_cadrage_du_projet.qmd','Fiche, protocole, populations, temporalite, indicateurs, limites et recette presents.'),
      (12,'Simulation','ADAPTE','R/01_generate_data.R','generate_data() et inject_anomalies() remplissent les roles demandes ; 15000 personnes, huit tables, trois annees.'),
      (13,'Tests des donnees','VALIDE','tests/testthat/test-data.R',f'{passed} assertions dans la suite ; nouvelles verifications de dimensions, cles, relations et graine. Entree existante scripts/run_tests.R conservee.'),
      (14,'Notebook generation','ADAPTE','notebooks/01_generation_des_donnees.qmd','Generation et identite pour la meme graine executees. Reference propre dans data/synthetic/, copie degradee dans data/raw/ ; ecriture assuree par targets.'),
      (15,'Notebook importation','ADAPTE','notebooks/02_importation_description.qmd','glimpse(), types, summary() et distribution de la validation executes ; skimr non ajoute pour dupliquer ces resumes.'),
      (16,'Controle qualite','ADAPTE','notebooks/03_controle_qualite.qmd','R/02_validate_data.R, journal et recette des injections ; calculs du notebook executes.'),
      (17,'Nettoyage','ADAPTE','notebooks/04_nettoyage.qmd','R/03_prepare_data.R et comparaison avant/apres ; bruts preserves, conflits isoles, tables processed produites.'),
      (18,'Descriptif','VALIDE','notebooks/05_analyse_descriptive.qmd','Tables de scolarite et figure produites par le pipeline, relues dans le notebook.'),
      (19,'Choix du modele','VALIDE','docs/09_methodologie_modeles.md','Cible binaire, observation par personne, glm et limites documentes ; discussion du modele mixte dans le notebook 06.'),
      (20,'Modele de reussite','ADAPTE','R/08_statistical_models.R','Coefficients, IC de Wald, diagnostics, calibration, separation apprentissage/evaluation et modele RDS produits ; notebook 06 execute.'),
      (21,'Enquetes','ADAPTE','notebooks/07_evaluation_formations.qmd','Questionnaires et protocole dans surveys/ ; non-reponse et insertion calculees. LimeSurvey non importe ; alpha non pertinent pour un item global unique.'),
      (22,'Longitudinal','VALIDE','notebooks/08_analyse_longitudinale.qmd','Cohortes et transitions executees ; censure, sortie documentee et inconnu distingues.'),
      (23,'Faisabilite causale','VALIDE','notebooks/09_analyse_causale.qmd','Hypotheses et donnees manquantes pour identifier un effet explicitees ; decision de ne pas estimer un effet causal.'),
      (24,'Indicateurs decisionnels','ADAPTE','notebooks/10_indicateurs_decisionnels.qmd','Priorites et calculs presents ; config/indicator_definitions.yml reste la reference, aucun doublon indicators.yml.'),
      (25,'Restitution decisionnelle','VALIDE','notebooks/11_restitution_decisionnelle.qmd','Resultat, interpretation, implication et recommandation relies ; note de pilotage existante reutilisee.'),
      (26,'Pipeline targets','VALIDE','_targets.R','tar_make execute : 10 cibles declarees ; metadonnees controlees, aucune cible obsolete.'),
      (27,'Notebook pipeline','VALIDE','notebooks/12_pipeline_complet.qmd','Lecture des metadonnees et des fichiers executee, sans second pipeline dans le notebook.'),
      (28,'Audit technique','VALIDE','scripts/audit_code.R','0 observation lintr sur R/, regles par defaut conservees ; tests, chemins et renv passent. Variables de donnees explicites, etat des closures explicite.'),
      (29,'Shiny','ADAPTE','dashboards/shiny/app.R','Application existante conservee : trois vues regroupent les indicateurs. Demarrage HTTP et 30 assertions Shiny verifies ; pas de bslib ajoute ni six nouvelles pages dupliquees.'),
      (30,'Rapport Quarto','VALIDE','reports/rapport_final.qmd','Nouveaux rendus HTML et PDF verifies ; 13 chapitres conserves. Acces au cache CSS autorise, theme et navigation conserves.'),
      (31,'README final','VALIDE','README.md','Liens vers l audit, preuves, reproduction et limites actualises.'),
      (32,'Publication GitHub','NON_REALISE','docs/11_publication.md','Preparation locale uniquement ; aucune destination distante confirmee, aucun push. Ne pas confondre ce statut avec une erreur de calcul.'),
      (33,'Presentation orale','VALIDE','notebooks/13_presentation_orale.qmd','Afficher, dire, message cle, question et reponse renseignes ; support Markdown execute. Diaporama existant conserve.'),
      (34,'Discours 3 a 5 minutes','VALIDE','docs/24_preparation_orale.md','Discours redige a partir des chiffres verifies ; duree visee, non mesuree en situation orale.'),
      (35,'Trente questions de jury','VALIDE','docs/24_preparation_orale.md','30 questions, reponses courtes, developpements et pieges ; pas de passage reel devant un jury revendique.'),
      (36,'Audit sur 100','VALIDE','docs/22_audit_final.md','Evaluation argumentee selon le bareme demande ; autoevaluation documentaire, pas certification externe.'),
      (37,'Validation finale','VALIDE','docs/23_validation_technique.md','Controles locaux R, lintr, renv, schemas Power BI et rendus passes. Publication distante et validation institutionnelle hors perimetre.'),
    ]
    if published:
        rows = [(n, title, 'VALIDE', path,
                 'Sources publiees sur main ; preuve et destination dans docs/26_publication_github.json.')
                if n in (10, 32) else (n, title, status, path, note)
                for n, title, status, path, note in rows]
    for _,_,_,path,_ in rows:
        if path not in ('docs/22_audit_final.md','docs/23_validation_technique.md'):
            assert (ROOT/path).exists(), path
    counts = Counter(x[2] for x in rows)
    with (OUT/'matrice_37_etapes.csv').open('w',encoding='utf-8',newline='') as stream:
        writer=csv.writer(stream);writer.writerow(['numero','etape','statut','reference','constat']);writer.writerows(rows)
    now = datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M UTC')
    matrix = '# Vérification des 37 étapes\n\n'
    matrix += f'Revue du {now}. Les références équivalentes sont acceptées sans renommer les fonctions ou multiplier les dossiers. Une présence actuelle et une recette ne prouvent pas une chronologie historique exacte en 37 opérations.\n\n'
    matrix += '**Statuts :** VALIDE = présence et vérification adaptées au besoin ; ADAPTE = fonction équivalente avec organisation conservée ; PARTIEL = preuve ou exigence restante ; NON_REALISE = opération non effectuée.\n\n'
    matrix += ', '.join(f'{k} : {v}' for k,v in counts.items()) + '.\n\n'
    matrix += '| Nº | Étape | Statut | Référence | Constat |\n|---|---|---|---|---|\n'
    for n,title,status,path,note in rows:
        relative = '../'+path if not path.startswith('docs/') else path[5:]
        matrix += f'| {n:02} | {title} | {status} | [{path}]({relative}) | {note} |\n'
    matrix += '\n[Audit sur 100](22_audit_final.md) · [Validation technique](23_validation_technique.md).\n'
    (ROOT/'docs/21_verification_37_etapes.md').write_text(matrix,encoding='utf-8')
    scores = [
      ('Cadrage',10,10,'Unites, populations, questions et limites explicites.'),
      ('Architecture',9,10,'Sources uniques et taches VS Code ; dependances de diffusion encore complexes et poste Windows.'),
      ('Donnees',10,10,'Simulation relationnelle, graine, integrite et generation verifiees.'),
      ('Qualite',9,10,'Regles, journal, quarantaine et controles ; validation metier institutionnelle hors perimetre.'),
      ('Statistiques',13,15,'Denominateurs, couverture, cohortes et non-reponse ; precision et redressement des enquetes non developpes.'),
      ('Modelisation',12,15,'Evaluation reservee, calibration et sensibilite ; discrimination limitee et absence de validation externe ou IC d AUC.'),
      ('Code R',9,10,'0 observation lintr sur R/, formatage coherent, .data explicite et etat local des closures ; scripts de poste et fonctions metier restent distincts.'),
      ('Tests',5,5,f'{passed} assertions, 13 cas, aucun echec, avertissement ou test ignore.'),
      ('Reproductibilite',5,5,'targets, renv, dependances Python figees, rendus et empreintes des exports verifies sur ce poste ; une machine vierge reste un controle distinct.'),
      ('Restitution',4,5,'Nouveaux rendus HTML/PDF et 79 schemas Power BI valides ; relecture exhaustive du canvas et validation institutionnelle hors perimetre.'),
      ('Presentation',3,5,'Diaporama, discours et 30 questions ; duree et prestation non evaluees en situation.'),
    ]
    score=sum(x[1] for x in scores)
    audit=f'# Audit final — {score}/100\n\nAutoévaluation technique et documentaire du {now}, selon le barème demandé. Cette note motive un jugement ; elle ne constitue pas une certification ni une mesure statistique de qualité.\n\n'
    audit+='| Domaine | Note | Justification |\n|---|---|---|\n'
    for title,points,maximum,note in scores:
        audit+=f'| {title} | {points}/{maximum} | {note} |\n'
    audit+=f'\n**Total : {score}/100.**\n\n'
    audit+='## Verdict\n\n**Validation technique locale réussie sur le périmètre contrôlé.** Les trois réserves techniques de l’audit initial sont levées : lintr sans observation, 79 schémas Power BI valides et nouveaux rendus Quarto réussis. Les exports protégés sont strictement identiques à ceux d’avant correction. La publication GitHub n’est pas réalisée et n’est pas un préalable au fonctionnement local.\n\n'
    audit+='## Réserves levées\n\n1. Règles lintr conservées : références de colonnes explicites, fonctions partagées chargées pour l’analyse, état local des closures et formatage corrigés. Aucun masquage global des avertissements.\n2. Validateur Power BI isolé dans `.venv-powerbi/`, versions figées dans `requirements-powerbi.txt` ; ancien dossier Python incomplet exclu du chargement.\n3. Accès au cache CSS Quarto autorisé : rendus normaux réussis sans changer le thème ni la navigation.\n\nPour une diffusion publique, choisir destination et licence, sélectionner les sources, créer les commits et publier uniquement dans le périmètre confirmé.\n\n'
    audit+='## Améliorations non bloquantes\n\nInstaller l’extension Quarto recommandée, vérifier le terminal intégré VS Code, chronométrer l’oral et réaliser une relecture visuelle exhaustive du canvas Power BI. Une nouvelle restauration renv sur une machine vierge reste un contrôle distinct de la synchronisation réussie sur ce poste.\n\n'
    audit+='Les warnings de locale au démarrage restent distincts des résultats de tests et de lintr : aucun avertissement de test ni aucune observation lintr dans la recette actuelle. La note initiale était de 84/100 ; elle est réévaluée après les corrections vérifiées.\n'
    if published:
        audit = audit.replace('La publication GitHub n’est pas réalisée et n’est pas un préalable au fonctionnement local.',
                              'Les sources sont publiées sur GitHub ; voir la preuve de publication et les limites de validation distante dans docs/11_publication.md.')
        audit = audit.replace('Pour une diffusion publique, choisir destination et licence, sélectionner les sources, créer les commits et publier uniquement dans le périmètre confirmé.',
                              'La diffusion porte sur les sources auditées et les agrégats protégés. Aucune licence de réutilisation supplémentaire n’a été choisie automatiquement.')
    (ROOT/'docs/22_audit_final.md').write_text(audit,encoding='utf-8')
    technical=f'''# Validation technique finale

Exécution du {now}. Statut global : **validation technique locale réussie sur le périmètre contrôlé**.

| Contrôle | Statut réel | Preuve |
|---|---|---|
| Pipeline targets | VALIDE : 10 cibles déclarées, aucune obsolète ; calculs réexécutés | `outputs/validation_finale/validation_R.log`, `targets_meta.csv` |
| Tests testthat | VALIDE : {passed} assertions, 13 cas, 0 échec, 0 warning, 0 ignoré | `outputs/validation_finale/tests.csv` |
| renv | VALIDE : synchronized=TRUE, packages disponibles ; lockfile actualisé pour lintr | `outputs/validation_finale/renv_status.rds`, `audit_code.log` |
| Syntaxe et chemins R | VALIDE : aucune erreur de parse ni chemin Windows absolu dans R/ | `scripts/verify_structure.R`, `chemins_absolus_metier.csv` |
| Notebooks | VALIDE pour les calculs : {len(notebooks)} supports exécutés via knitr | `outputs/validation_finale/notebooks.csv` et `notebooks_knit/` |
| Rendu HTML Quarto actuel | VALIDE : rapports, notebooks et site rendus avec le cache CSS accessible | `rendu_rapports.log`, `rendu_notebooks.log`, `rendu_site.log` |
| HTML/PDF | Nouveaux rendus, intégrité et mentions vérifiées ; note de deux pages | `scripts/verify_artifacts.py`, `outputs/tables/recette_pdf.json` |
| lintr 3.4.0 | VALIDE : 0 style, 0 warning, 0 error sur R/, règles par défaut conservées | `outputs/validation_finale/lintr.csv` et `lintr.txt` |
| Shiny | VALIDE : serveur de recette accessible en HTTP sur 3847, puis arrêté ; 30 assertions dans la suite | `shiny_smoke.json`, `shiny_stderr.log` |
| Tableau web | VALIDE : 18 contrôles JavaScript après correction du chemin du test | `dashboards/interactive/test-dashboard.cjs` |
| Site | Nouveau rendu ; navigation, ressources et treize chapitres contrôlés ; apparence conservée | `outputs/site-classique-qa/verification.json` |
| Modèle Power BI TOM | VALIDE : 7 tables, 6 relations, 35 mesures | `outputs/powerbi-qa/recette-modele.json` |
| Schémas PBIR Python | VALIDE : 79 fichiers, 0 erreur, dépendances Python figées | `outputs/validation_finale/schemas_powerbi.log` |
| Exports protégés | VALIDE : six fichiers strictement identiques avant/après correction (SHA-256) | `outputs/validation_finale/corrections_validees.json` |
| Moteur DAX et canvas Desktop | Recette historique conservée ; pas de nouvelle recette moteur ni de contrôle visuel exhaustif | `docs/16_recette_powerbi.md` |
| Git | Dépôt local sur master, fichiers non suivis, aucun commit ni remote ; aucun push | `outputs/validation_finale/git.txt` |
| CI GitHub et LimeSurvey | NON EXECUTES dans leurs services respectifs | `docs/11_publication.md`, `surveys/protocols/protocole.md` |

## Corrections réalisées pendant la revue

Le sandbox renv a été isolé dans `renv/sandbox/`, sans désactiver l’isolation.
Les dépendances lintr sont figées. Les notebooks manquants, la faisabilité
causale, le discours court et les trente questions sont ajoutés. Le test web
utilise son propre dossier au lieu du répertoire courant. Les rapports et les
notebooks ont désormais leur sous-projet Quarto, séparé du site.

## Refaire les contrôles

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_r.ps1 -Script scripts/validate_final.R
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_r.ps1 -Script scripts/audit_code.R
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_r.ps1 -Script scripts/validate_notebooks.R
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_r.ps1 -Script scripts/smoke_shiny.R
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run_r.ps1 -QuartoCommand render -Reports
.venv-powerbi/Scripts/python.exe scripts/validate_powerbi_project.py
python scripts/verify_classic_website.py
```

Le rendu requiert un cache CSS accessible. Après une nouvelle autorisation,
les rendus normaux réussissent ; le thème n’a pas été remplacé pour contourner
le problème. Les anciens échecs restent des preuves historiques, pas le statut
actuel. Le validateur Power BI s’installe avec `scripts/setup_powerbi_validation.ps1`.
La CI comprend désormais des contrôles lintr et Power BI, sans exécution distante
revendiquée dans cette session.

Les journaux PowerShell peuvent étiqueter la sortie stderr de R comme
`NativeCommandError` lors des warnings de locale. Le résultat du contrôle
est établi à partir du code de sortie, des fichiers structurés et des assertions,
pas de cette étiquette seule.

[Matrice des 37 étapes](21_verification_37_etapes.md) · [Audit sur 100](22_audit_final.md).
'''
    if published:
        technical = technical.replace('Dépôt local sur master, fichiers non suivis, aucun commit ni remote ; aucun push',
                                      'VALIDE : sources sur main dans le dépôt confirmé ; preuve dans docs/26_publication_github.json')
        technical = technical.replace('CI GitHub et LimeSurvey | NON EXECUTES dans leurs services respectifs',
                                      'CI GitHub et LimeSurvey | Statut CI dans docs/11_publication.md ; import LimeSurvey non exécuté')
        technical = technical.replace('sans exécution distante\nrevendiquée dans cette session.',
                                      'avec statut distant documenté dans docs/11_publication.md.')
    (ROOT/'docs/23_validation_technique.md').write_text(technical,encoding='utf-8')
    summary={'date_utc':now,'etapes':dict(counts),'score':score,'maximum':100,
      'assertions':passed,'notebooks_calculs':len(notebooks),'lintr':dict(kinds),
      'verdict':'VALIDATION_LOCALE_REUSSIE','rendu_quarto_actuel':'VALIDE'}
    summary['renv_lock_sha256']=hashlib.sha256((ROOT/'renv.lock').read_bytes()).hexdigest()
    (OUT/'bilan_final.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8')
    print(json.dumps(summary,ensure_ascii=False))

if __name__ == '__main__':
    main()
