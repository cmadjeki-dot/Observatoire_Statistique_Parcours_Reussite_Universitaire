"""Assembler uniquement les exports agreges proteges, sans donnees individuelles."""
import csv
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
folder = root / 'outputs/exports/powerbi'
data = {'cloture': '2026-09-30', 'donnees': 'entierement_fictives'}
for key, filename in [('school', 'fait_scolarite.csv'), ('survey', 'fait_evaluation.csv'),
                      ('employment', 'fait_insertion.csv'), ('formations', 'dim_formation.csv')]:
    with (folder / filename).open(encoding='utf-8', newline='') as stream:
        rows = list(csv.DictReader(stream))
    for row in rows:
        for name, value in row.items():
            if value == '': row[name] = None
            elif value in ('TRUE', 'FALSE'): row[name] = value == 'TRUE'
            elif value.isdigit(): row[name] = int(value)
        assert not {'etudiant_id', 'inscription_id', 'diplome_id'} & row.keys()
        if row.get('masque'):
            assert all(v is None for k, v in row.items() if k not in ('annee', 'formation_id', 'masque'))
    data[key] = rows
target = root / 'dashboards/interactive/dist'
target.mkdir(parents=True, exist_ok=True)
(target / 'data.js').write_text('window.OBS_DATA = ' + json.dumps(data, ensure_ascii=False) + ';\n', encoding='utf-8')
print('Exports proteges assembles :', {k: len(v) for k, v in data.items() if isinstance(v, list)})
