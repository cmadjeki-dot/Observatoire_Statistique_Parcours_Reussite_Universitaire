"""Controle sans dependance des PDF Chromium (objets Page non compresses)."""
import json
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
folder = root / 'outputs' / 'reports' / 'reports'
checks = []
for name in ('rapport_final', 'note_pilotage', 'enquetes'):
    path = folder / f'{name}.pdf'
    content = path.read_bytes()
    assert content.startswith(b'%PDF-'), f'PDF invalide : {name}'
    pages = len(re.findall(rb'/Type\s*/Page\b', content))
    assert pages > 0, f'Pagination non identifiable : {name}'
    if name == 'note_pilotage':
        assert pages == 2, f'Note : {pages} pages au lieu de 2'
    checks.append({'fichier': str(path.relative_to(root)), 'pages': pages,
                   'controle': 'valide', 'donnees': 'entierement_fictives'})
output = root / 'outputs' / 'tables' / 'recette_pdf.json'
output.write_text(json.dumps(checks, ensure_ascii=False, indent=2), encoding='utf-8')
print(json.dumps(checks, ensure_ascii=False, indent=2))
