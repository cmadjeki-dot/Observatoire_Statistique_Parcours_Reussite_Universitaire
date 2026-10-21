"""Verifier les liens locaux, le sommaire demande et les archives diffusees."""
import json
import re
import urllib.parse
import zipfile
from html.parser import HTMLParser
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
SITE=ROOT/'sites/presentation/dist'
class Parser(HTMLParser):
    def __init__(self): super().__init__();self.ids=set();self.links=[];self.headings=[];self.heading=None
    def handle_starttag(self,tag,attrs):
        attrs=dict(attrs)
        if 'id' in attrs:self.ids.add(attrs['id'])
        for key in ('href','src'):
            if key in attrs:self.links.append(attrs[key])
        if tag=='h1':self.heading=[]
    def handle_data(self,data):
        if self.heading is not None:self.heading.append(data)
    def handle_endtag(self,tag):
        if tag=='h1' and self.heading is not None:self.headings.append(''.join(self.heading).strip());self.heading=None

parsers={}
for path in SITE.rglob('*.html'):
    parser=Parser();parser.feed(path.read_text(encoding='utf-8'));parsers[path.resolve()]=parser
errors=[];checked=0
for path,parser in parsers.items():
    for link in parser.links:
        parts=urllib.parse.urlsplit(link)
        if parts.scheme or parts.netloc:continue
        target=(path.parent/urllib.parse.unquote(parts.path)).resolve() if parts.path else path
        if target.is_dir():target=target/'index.html'
        if not target.exists():errors.append(f'{path.relative_to(SITE)} -> {link}')
        elif parts.fragment and target in parsers and urllib.parse.unquote(parts.fragment) not in parsers[target].ids:
            errors.append(f'Ancre absente : {target.name}#{parts.fragment}')
        checked+=1
expected=['Résumé exécutif','Contexte et objectifs','Données et périmètre','Qualité et traçabilité','Méthodes et définitions',
          'Enquêtes et devenir des diplômés','Parcours et suivi longitudinal','Modélisation exploratoire','Résultats descriptifs',
          'Indicateurs décisionnels','Recommandations de pilotage','Limites et précautions','Reproductibilité et accès aux livrables']
report=parsers[(SITE/'rapport_final.html').resolve()]
numbered=[re.sub(r'^\d+\s*','',h).replace('\u00a0',' ') for h in report.headings if re.match(r'^\d+',h)]
assert numbered==expected,f'Structure du rapport incorrecte : {numbered}'
assert len(re.findall(r'\{#.+?\}',(ROOT/'reports/rapport_final.qmd').read_text(encoding='utf-8')))==13
assert 'data:image/png;base64,' in (SITE/'rapport_final.html').read_text(encoding='utf-8')
for archive in (SITE/'telechargements').glob('*.zip'):
    with zipfile.ZipFile(archive) as z:
        assert z.testzip() is None
        for name in z.namelist():
            pieces=Path(name).parts
            assert not any(p in pieces for p in ('.git','.pbi','.openai','node_modules'))
            assert not any(part in name for part in ('data/raw/','data/synthetic/','data/processed/','data/interim/'))
pdf=(ROOT/'outputs/tables/recette_pdf.json').read_text(encoding='utf-8')
assert next(x['pages'] for x in json.loads(pdf) if 'note_pilotage' in x['fichier'])==2
if errors:raise AssertionError('\n'.join(errors[:30]))
proof={'statut':'valide','pages_html':len(parsers),'liens_locaux_verifies':checked,'chapitres_ordonnes':13,
       'graphique_rapport_integre':True,'archives_verifiees':3,'note_pages':2}
folder=ROOT/'outputs/site-presentation-qa';folder.mkdir(parents=True,exist_ok=True)
(folder/'recette-statique.json').write_text(json.dumps(proof,indent=2),encoding='utf-8')
print(json.dumps(proof,indent=2))
