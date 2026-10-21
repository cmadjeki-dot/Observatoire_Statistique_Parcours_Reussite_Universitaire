"""Controle des livrables locaux et du paquet de diffusion, sans dependances."""
import csv
import json
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
reports = root / 'outputs' / 'reports' / 'reports'
main = (reports / 'rapport_final.html').read_text(encoding='utf-8')
assert 'data:image/png;base64,' in main, 'Graphique non integre au rapport'
assert 'outputs/figures/validation.png' not in main, 'Chemin de graphique non embarque'
for name in ('rapport_final', 'note_pilotage', 'presentation', 'enquetes'):
    html = (reports / f'{name}.html').read_text(encoding='utf-8')
    assert 'fictives' in html, f'Mention fictive absente : {name}'
    assert not re.search(r'<img[^>]+src=["\']https?://', html), 'Image externe dans un rapport'

exports = root / 'outputs' / 'exports' / 'powerbi'
for path in exports.glob('fait_*.csv'):
    with path.open(encoding='utf-8', newline='') as stream:
        reader = csv.DictReader(stream)
        assert not {'etudiant_id', 'inscription_id', 'diplome_id'} & set(reader.fieldnames)
        for row in reader:
            if row['masque'] == 'TRUE':
                assert all(value == '' for key, value in row.items()
                           if key not in {'annee', 'formation_id', 'masque'})

pdf = json.loads((root / 'outputs' / 'tables' / 'recette_pdf.json').read_text(encoding='utf-8'))
assert next(x['pages'] for x in pdf if 'note_pilotage' in x['fichier']) == 2
checks = {'html_autonomes': True, 'figure_integree': True,
          'exports_sans_identifiants_individuels': True, 'masques_vides': True,
          'note_deux_pages': True, 'publication_distante': False}
(root / 'outputs' / 'tables' / 'recette_livrables.json').write_text(
    json.dumps(checks, indent=2), encoding='utf-8')
print(json.dumps(checks, indent=2))
