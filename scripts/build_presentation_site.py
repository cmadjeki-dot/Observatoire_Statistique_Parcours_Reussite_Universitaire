"""Assembler le site et des archives selectionnees, sans sources individuelles."""
import csv
import hashlib
import html
import json
import shutil
import zipfile
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
DIST=ROOT/'sites/presentation/dist'
DOWNLOADS=DIST/'telechargements'
DOWNLOADS.mkdir(parents=True,exist_ok=True)

def page(title,body):
    return f'''<!doctype html><html lang="fr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>{html.escape(title)} · Observatoire</title><link rel="stylesheet" href="style.css"></head><body><header class="header"><a class="brand" href="index.html"><span class="monogram">O<span>·</span></span><span>Observatoire<small>PARCOURS & RÉUSSITE UNIVERSITAIRE</small></span></a><a class="back-link" href="index.html#livrables">← Tous les livrables</a></header><main class="article-page"><div class="eyebrow">PROJET DÉMONSTRATEUR · DONNÉES ENTIÈREMENT FICTIVES</div><h1>{html.escape(title)}</h1>{body}</main><footer><a href="index.html">← Accueil du projet</a><a href="rapport_final.html#limites-et-précautions">Limites & précautions</a></footer></body></html>'''

def protect_checks():
    for path in (ROOT/'outputs/exports/powerbi').glob('fait_*.csv'):
        with path.open(encoding='utf-8',newline='') as stream:
            reader=csv.DictReader(stream)
            assert not {'etudiant_id','inscription_id','diplome_id'} & set(reader.fieldnames)
            for row in reader:
                if row['masque']=='TRUE': assert all(not v for k,v in row.items() if k not in ('annee','formation_id','masque'))

def archive_sources():
    files=[]
    for folder in ['R','scripts','config','reports','docs','prompts','notebooks','.vscode','surveys/questionnaires','surveys/protocols','dashboards/shiny','dashboards/powerbi','dashboards/interactive']:
        for path in (ROOT/folder).rglob('*'):
            if not path.is_file():continue
            if any(v in path.relative_to(ROOT).parts for v in ('.git','.pbi','.openai','node_modules','__pycache__')):continue
            if path.suffix in ('.log','.pbix','.abf','.pyc','.zip','.tar','.gz'):continue
            files.append(path)
    for name in ['.here','.Rprofile','.gitignore','.renvignore','DESCRIPTION','Observatoire.Rproj','renv.lock','_targets.R','_quarto.yml','README.md','renv/activate.R','renv/settings.json','.github/workflows/validate.yml','index.qmd','projet.qmd','tableaux_de_bord.qmd','indicateurs.qmd','livrables.qmd','reproduire.qmd','website.css']:
        files.append(ROOT/name)
    files.append(ROOT/'requirements-powerbi.txt')
    files.extend((ROOT/'outputs/exports/powerbi').glob('*.csv'))
    files.extend((ROOT/'assets/previews').glob('*.png'))
    files.extend(DIST/name for name in ('index.html','style.css','site.js'))
    with zipfile.ZipFile(DOWNLOADS/'Observatoire_Sources.zip','w',zipfile.ZIP_DEFLATED) as archive:
        for path in sorted(set(files)):
            archive.write(path,Path('Observatoire')/path.relative_to(ROOT))
        archive.writestr('Observatoire/COMMENCER_ICI.txt',
          'Donnees entierement fictives. Aucune table individuelle n\'est incluse.\n'
          'Ouvrir le dossier dans VS Code. Lire docs/00_fiche_identite.md et docs/19_architecture_vscode.md.\n'
          'Restaurer renv::restore(), puis source("scripts/run_pipeline.R") et source("scripts/run_tests.R").\n'
          'Les CSV de outputs/exports/powerbi permettent de lancer Shiny sans generer les donnees individuelles.\n'
          'Rendre les rapports : quarto render. Python ne sert qu\'aux outils de diffusion annexes.\n')
    selected=[p for p in set(files) if p.relative_to(ROOT).as_posix().startswith(('dashboards/shiny/','outputs/exports/powerbi/','renv/'))
              or p.relative_to(ROOT).as_posix() in ['.here','.Rprofile','DESCRIPTION','Observatoire.Rproj','renv.lock',
                'scripts/run_shiny.R','scripts/setup_shiny.R','scripts/test_shiny.R','scripts/activate_environment.R','R/functions/common.R','tests/testthat/test-shiny.R','config/parameters.yml']]
    selected.append(ROOT/'tests/testthat/test-shiny.R')
    with zipfile.ZipFile(DOWNLOADS/'Observatoire_Shiny.zip','w',zipfile.ZIP_DEFLATED) as archive:
        for path in sorted(set(selected)):archive.write(path,Path('Observatoire_Shiny')/path.relative_to(ROOT))
        archive.writestr('Observatoire_Shiny/COMMENCER_ICI.txt',
          'Application R Shiny locale, donnees entierement fictives.\n'
          'Extraire tout, ouvrir Observatoire.Rproj, restaurer renv::restore(), puis source("scripts/run_shiny.R").\n'
          'Le navigateur ouvre http://127.0.0.1:3839. Arreter depuis la console R. Aucun serveur R distant n\'est fourni.\n')

protect_checks()
reports=ROOT/'outputs/reports/reports'
for name in ('rapport_final.html','rapport_final.pdf','note_pilotage.html','note_pilotage.pdf','enquetes.html','enquetes.pdf','presentation.html'):
    shutil.copyfile(reports/name,DIST/name)
for name in ('rapport_final.qmd','note_pilotage.qmd','enquetes.qmd','presentation.qmd'):
    shutil.copyfile(ROOT/'reports'/name,DOWNLOADS/name)
with zipfile.ZipFile(DOWNLOADS/'Observatoire_PowerBI.zip','w',zipfile.ZIP_DEFLATED) as archive:
    project = ROOT/'dashboards/powerbi/Observatoire'
    for path in sorted(project.rglob('*')):
        if path.is_file() and not any(p in ('.git','.pbi') for p in path.parts) and path.suffix not in ('.pbix','.abf'):
            archive.write(path, Path('Observatoire')/path.relative_to(project))
shutil.copyfile(ROOT/'outputs/tables/recette_filtres_powerbi.csv',DOWNLOADS/'recette_powerbi.csv')
shutil.copyfile(ROOT/'docs/13_maitriser_les_indicateurs.md',DOWNLOADS/'fiche_indicateurs.md')
(DIST/'assets').mkdir(exist_ok=True)
shutil.copyfile(ROOT/'assets/previews/dashboard.png',DIST/'assets/dashboard.png')
shutil.copyfile(ROOT/'assets/previews/shiny.png',DIST/'assets/shiny.png')
shutil.copytree(ROOT/'dashboards/interactive/dist',DIST/'dashboard',dirs_exist_ok=True)

shiny_body='''<p>Une véritable application R Shiny, avec calculs réactifs, graphiques et filtres année/formation. Le site de présentation est statique : il propose les sources et l’aperçu de l’application, sans prétendre héberger un serveur R.</p><div class="callout"><strong>À lancer sur votre ordinateur</strong><p>Téléchargez l’archive, extrayez-la entièrement, puis ouvrez <code>Observatoire.Rproj</code> dans RStudio.</p><a class="button primary" href="telechargements/Observatoire_Shiny.zip" download>Télécharger l’application Shiny ↓</a></div><h2>Démarrer</h2><pre><code># Une fois, après ouverture du projet extrait
renv::restore()
# Puis lancer l’application
source("scripts/run_shiny.R")</code></pre><p>L’application écoute sur <code>http://127.0.0.1:3839</code>. Cette adresse désigne votre propre ordinateur, pas le site publié. Si le port est occupé, définir <code>Sys.setenv(OBS_SHINY_PORT = "3840")</code> avant le lancement. Arrêter avec Stop/Échap dans RStudio.</p><h2>Ce qui est inclus</h2><ul><li>Trois vues : synthèse, parcours/devenir et huit fiches méthodologiques.</li><li>Filtres année/formation, graphique commutable et réinitialisation.</li><li>CSV agrégés protégés, sans données individuelles ni valeurs masquées.</li><li>30 assertions Shiny et contrôles navigateur bureau/mobile exécutés.</li></ul><img src="assets/shiny.png" width="1450" height="1200" alt="Capture réelle de l’application Shiny locale"><p>Les diplômés 2025-2026 ne sont pas encore observables à six mois à la clôture. Les états masqué, non observable et non calculable restent distincts.</p>'''
(DIST/'shiny.html').write_text(page('Le tableau de bord R Shiny',shiny_body),encoding='utf-8')
powerbi_body='''<p>Un projet Power BI natif PBIP avec trois pages et des mesures DAX : Vue d’ensemble, Parcours & devenir et Indicateurs & méthode. Ce site ne contient pas un rapport publié dans le service Power BI.</p><a class="button primary" href="telechargements/Observatoire_PowerBI.zip" download>Télécharger le projet Power BI ↓</a><h2>Ouvrir dans Desktop</h2><ol><li>Extraire toute l’archive. Conserver les dossiers <code>Observatoire.Report</code>, <code>Observatoire.SemanticModel</code> et <code>Data</code>.</li><li>Ouvrir <code>Observatoire.pbip</code> dans Power BI Desktop, ou utiliser le lanceur <code>ouvrir_observatoire.cmd</code> fourni pour Windows.</li><li>Dans Power Query, régler le paramètre <code>DossierExports</code> vers le dossier <code>Data</code> extrait, avec un séparateur final <code>/</code>.</li><li>Cliquer sur <strong>Accueil → Actualiser</strong> pour charger les agrégats protégés. Aucun cache de données n’est livré.</li><li>Utiliser année et formation ; les listes sont synchronisées entre les pages analytiques. Le graphique conserve les trois années.</li></ol><h2>Validation réellement exécutée</h2><p>79 fichiers validés contre les schémas Microsoft ; modèle de 7 tables, 6 relations et 35 mesures accepté par Desktop. L’actualisation et les <strong>126 comparaisons R/DAX</strong> dans le moteur local ont réussi sans écart.</p><p>La validation du moteur est distincte d’une inspection exhaustive du canvas et de toutes les interactions visuelles. Le livrable est un projet PBIP, pas un PBIX renommé. Pour créer un PBIX, utiliser Fichier → Enregistrer sous dans Desktop.</p><p><a href="telechargements/recette_powerbi.csv" download>Télécharger la matrice de rapprochement R/DAX ↓</a></p><h2>Lire les cartes</h2><p>La sélection 2025-2026 donne 10 222 inscrits, 73,2 % de validation annuelle et 71,4 % de satisfaction parmi les avis. L’emploi à six mois est non observable pour ces diplômés ; les années antérieures sont masquées selon la règle conservatrice de diffusion.</p>'''
(DIST/'powerbi.html').write_text(page('Le projet Power BI',powerbi_body),encoding='utf-8')
reproduce_body='''<p>Le démonstrateur est calculé en R. Le code, la configuration, les tests et les sources Quarto sont fournis ; aucune table individuelle n’est incluse dans les archives. Le générateur permet de les recréer localement.</p><a class="button primary" href="telechargements/Observatoire_Sources.zip" download>Télécharger les sources complètes ↓</a><h2>Reproduire les calculs</h2><pre><code># Après extraction et ouverture de Observatoire.Rproj
renv::restore()
source("scripts/run_pipeline.R")
source("scripts/run_tests.R")</code></pre><p>Le fichier <code>renv.lock</code> enregistre R 4.6.1 et les dépendances utilisées. Restauration et accès au cache peuvent demander une connexion réseau. La graine du simulateur et les trois années se trouvent dans <code>config/parameters.yml</code>.</p><h2>Rendre les rapports</h2><pre><code># Dans un terminal, à la racine du projet
quarto render</code></pre><p>Les quatre sources sont aussi téléchargeables séparément : <a href="telechargements/rapport_final.qmd" download>rapport final</a>, <a href="telechargements/note_pilotage.qmd" download>note</a>, <a href="telechargements/enquetes.qmd" download>enquêtes</a>, <a href="telechargements/presentation.qmd" download>présentation</a>.</p><h2>Choisir une restitution</h2><ul><li><a href="dashboard/index.html">Web</a> : interface interactive déjà accessible sur ce site.</li><li><a href="shiny.html">Shiny</a> : démarrer un serveur R sur votre poste.</li><li><a href="powerbi.html">Power BI</a> : ouvrir et actualiser le projet natif dans Desktop.</li></ul><h2>Comprendre les limites</h2><p>Les données sont entièrement fictives. Les sources brutes individuelles, bibliothèques locales, caches, secrets, métadonnées Git et journaux machine sont exclus. Le site est un instantané publié, sans actualisation distante automatique. Une nouvelle production exige de rendre à nouveau les rapports, contrôler les fichiers et republier.</p>'''
(DIST/'reproduire.html').write_text(page('Reproduire le projet',reproduce_body),encoding='utf-8')
indicators=[('Effectifs inscrits','Étudiants distincts dans le périmètre année–formation.','10 222 en 2025-2026. Ne pas sommer les années pour compter des personnes uniques.'),
('Évolution des inscriptions','(N courant − N précédent) / N précédent × 100.','(10 222 − 8 026) / 8 026 = +27,4 %. Années consécutives et base non nulle.'),
('Validation annuelle','Validations connues / inscriptions éligibles × 100.','7 478 / 10 222 = 73,2 %. Couverture : 97,2 % ; parmi connus : 75,3 %. Le diplôme terminal est distinct.'),
('Passage','Passages / inscriptions de départ non terminales suivables × 100.','4 067 / 6 168 = 65,9 % de 2024-2025 à 2025-2026. Suivi futur non observable pour la dernière année.'),
('Réorientation','Réinscrits dans une autre formation / cohorte suivable × 100.','193 / 8 026 = 2,4 % de 2024-2025 à 2025-2026. Absence de réinscription ne signifie pas abandon.'),
('Participation','Répondants substantiels / invitations délivrées × 100.','4 967 / 9 805 = 50,7 % en 2025-2026. Exclure les invitations non délivrées.'),
('Satisfaction','Notes 4 ou 5 / avis valides de 1 à 5 × 100.','2 942 / 4 120 = 71,4 %. Sans avis et items manquants ne sont pas des avis défavorables.'),
('Emploi à six mois','Emploi / répondants éligibles de situation connue, études comprises × 100.','Non observable pour les diplômés 2025-2026 à la clôture. L’insertion parmi actifs utilise emploi + recherche au dénominateur.')]
body='<p>Exemples entièrement fictifs. Les pourcentages sont arrondis à une décimale ; les calculs conservent leur précision.</p>'
for i,(title,formula,explanation) in enumerate(indicators,1):
    body+=f'<details><summary>{i:02d} · {html.escape(title)}</summary><p><strong>{html.escape(formula)}</strong></p><p>{html.escape(explanation)}</p></details>'
body+='<h2>Une règle commune</h2><p>Un taux agrégé se recalcule à partir des sommes des numérateurs et dénominateurs. Un dénominateur nul donne « non calculable ». « Non observable » et « masqué » sont encore d’autres états, jamais remplacés par zéro.</p><p><a href="telechargements/fiche_indicateurs.md" download>Télécharger la fiche complète avec les pièges à éviter ↓</a></p>'
(DIST/'indicateurs.html').write_text(page('Maîtriser les huit indicateurs',body),encoding='utf-8')
archive_sources()
manifest=[]
for path in sorted(DOWNLOADS.iterdir()):
    if path.is_file() and path.name!='manifest.json':manifest.append({'fichier':path.name,'octets':path.stat().st_size,'sha256':hashlib.sha256(path.read_bytes()).hexdigest()})
(DOWNLOADS/'manifest.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False),encoding='utf-8')
print('Site assemble :',DIST)
print(len(list(DIST.rglob('*'))),'entrees ;',len(manifest),'telechargements controles.')
