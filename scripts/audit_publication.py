"""Controler les candidats Git sans afficher de contenu sensible."""
import csv
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
paths = subprocess.check_output(
    ['git', 'ls-files', '--cached', '--others', '--exclude-standard', '-z'],
    cwd=ROOT).decode('utf-8').split('\0')
paths = sorted(set(p for p in paths if p))
patterns = [
    rb'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----',
    rb'gh[pousr]_[A-Za-z0-9]{30,}',
    rb'github_pat_[A-Za-z0-9_]{40,}',
    rb'AKIA[0-9A-Z]{16}',
    rb'sk-(?:proj-)?[A-Za-z0-9_-]{40,}',
]
issues = []
for name in paths:
    path = ROOT / name
    parts = Path(name).parts
    if any(p in ('.git', '.openai', '.pbi', 'node_modules', '__pycache__') for p in parts):
        issues.append({'fichier': name, 'cause': 'metadata ou cache'})
    if parts[0] in ('data', 'outputs') and path.name != '.gitkeep':
        issues.append({'fichier': name, 'cause': 'donnees ou sorties locales'})
    if path.stat().st_size >= 95 * 1024 * 1024:
        issues.append({'fichier': name, 'cause': 'taille excessive'})
    if any(re.search(pattern, path.read_bytes()) for pattern in patterns):
        issues.append({'fichier': name, 'cause': 'secret potentiel'})
    if name.startswith('dashboards/powerbi/Observatoire/Data/') and path.suffix == '.csv':
        with path.open(encoding='utf-8-sig', newline='') as stream:
            reader = csv.DictReader(stream)
            assert not {'etudiant_id', 'inscription_id', 'diplome_id'} & set(reader.fieldnames)
            for row in reader:
                if row.get('masque') == 'TRUE':
                    assert all(not value for key, value in row.items()
                               if key not in ('annee', 'formation_id', 'masque'))
result = {'fichiers': len(paths), 'octets': sum((ROOT/p).stat().st_size for p in paths),
          'anomalies': issues, 'statut': 'VALIDE' if not issues else 'ECHEC'}
out = ROOT/'outputs/validation_finale'
out.mkdir(parents=True, exist_ok=True)
(out/'publication_contenu.json').write_text(json.dumps(result, indent=2), encoding='utf-8')
print(json.dumps(result))
assert not issues, 'Publication bloquee : examiner le rapport local.'
