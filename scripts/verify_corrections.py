"""Verifier la levee des trois reserves avec les preuves et sorties actuelles."""
import csv
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'outputs/validation_finale'

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

with (OUT/'lintr.csv').open(encoding='utf-8', newline='') as stream:
    assert not list(csv.DictReader(stream)), 'Observations lintr restantes'
with (OUT/'tests.csv').open(encoding='utf-8', newline='') as stream:
    tests = list(csv.DictReader(stream))
assert sum(int(x['passed']) for x in tests) == 104
assert sum(int(x['failed']) for x in tests) == 0
assert sum(int(x['warning']) for x in tests) == 0
assert all(x['error'] == 'FALSE' for x in tests)
with (OUT/'controles_R.csv').open(encoding='utf-8', newline='') as stream:
    assert all(x['statut'] == 'VALIDE' for x in csv.DictReader(stream))
schema = json.loads((ROOT/'outputs/powerbi-qa/recette-projet.json').read_text(encoding='utf-8'))
assert schema['schema_files_validated'] == 79 and schema['schema_errors'] == 0
baseline = json.loads((OUT/'exports_avant_correction.json').read_text(encoding='utf-8'))
assert all(digest(ROOT/name) == expected for name, expected in baseline.items())
appearance = json.loads((OUT/'site_apparence_avant.json').read_text(encoding='utf-8'))
assert all(digest(ROOT/name) == expected for name, expected in appearance.items())
assert len(list((ROOT/'outputs/notebooks').glob('*.html'))) == 18
for name in ('rapport_final', 'note_pilotage', 'enquetes', 'presentation'):
    assert (ROOT/'outputs/reports/reports'/f'{name}.html').exists()
assert '104 assertions R' in (ROOT/'_site/rapport_final.html').read_text(encoding='utf-8')
pdf = json.loads((ROOT/'outputs/tables/recette_pdf.json').read_text(encoding='utf-8'))
assert all(x['controle'] == 'valide' for x in pdf)
assert next(x['pages'] for x in pdf if 'note_pilotage' in x['fichier']) == 2
for name in ('rendu_rapports.log', 'rendu_notebooks.log', 'rendu_site.log'):
    data = (OUT/name).read_bytes()
    log = data.decode('utf-16' if data.startswith(b'\xff\xfe') else 'utf-8', errors='replace')
    assert 'Output created:' in log, name
result = {
    'statut': 'VALIDE', 'date_utc': datetime.now(timezone.utc).isoformat(),
    'assertions_R': 104, 'observations_lintr': 0,
    'schemas_powerbi': 79, 'erreurs_schemas': 0,
    'notebooks_html': 18, 'rapports_html': 4, 'site_quarto': 'VALIDE',
    'exports_identiques_sha256': len(baseline), 'sources_apparence_inchangees': list(appearance),
    'pdf': pdf,
}
(OUT/'corrections_validees.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(result,ensure_ascii=False))
