"""Contrôle les pages, ressources et ancres du site Quarto classique."""
from pathlib import Path
from html.parser import HTMLParser
from urllib.parse import urlsplit, unquote
import json
import re

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / '_site'

class Links(HTMLParser):
    def __init__(self):
        super().__init__()
        self.links = []
        self.ids = set()
    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if 'id' in attrs:
            self.ids.add(attrs['id'])
        for key in ('href', 'src'):
            if key in attrs:
                self.links.append(attrs[key])

pages = [SITE / (n + '.html') for n in (
    'index', 'projet', 'tableaux_de_bord', 'indicateurs', 'livrables',
    'reproduire', 'rapport_final', 'note_pilotage', 'enquetes', 'presentation')]
broken = []
checked = 0
for page in pages:
    parser = Links()
    text = page.read_text(encoding='utf-8')
    parser.feed(text)
    for link in parser.links:
        url = urlsplit(link)
        if url.scheme or url.netloc or not url.path:
            continue
        target = SITE / unquote(url.path.lstrip('/')) if url.path.startswith('/') else page.parent / unquote(url.path)
        checked += 1
        if not target.exists():
            broken.append(f'{page.name}: {link}')

report = (SITE / 'rapport_final.html').read_text(encoding='utf-8')
chapters = re.findall(r'<h1[^>]*>\s*<span class="header-section-number">(\d+)</span>', report)
assert chapters == [str(i) for i in range(1,14)], chapters
assert not broken, '\n'.join(broken)
assert 'quarto-header' in (SITE/'index.html').read_text(encoding='utf-8')
assert (SITE/'dashboard/index.html').exists()
assert all((SITE/f'{name}.pdf').exists() for name in ('rapport_final','note_pilotage','enquetes'))
result = {'pages': len(pages), 'liens_locaux': checked, 'chapitres': 13, 'liens_absents': broken}
(ROOT/'outputs/site-classique-qa').mkdir(exist_ok=True)
(ROOT/'outputs/site-classique-qa/verification.json').write_text(json.dumps(result, ensure_ascii=False, indent=2),encoding='utf-8')
print(json.dumps(result, ensure_ascii=False))
