"""Verifier les archives effectivement proposees au telechargement."""
import csv
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
from zipfile import ZipFile

ROOT = Path(__file__).resolve().parents[1]
DOWNLOADS = ROOT/'_site/telechargements'
manifest = json.loads((DOWNLOADS/'manifest.json').read_text(encoding='utf-8'))
for item in manifest:
    path = DOWNLOADS/item['fichier']
    assert path.stat().st_size == item['octets'], path.name
    assert hashlib.sha256(path.read_bytes()).hexdigest() == item['sha256'], path.name
checked = []
for path in sorted(DOWNLOADS.glob('*.zip')):
    with ZipFile(path) as archive:
        assert archive.testzip() is None
        names = archive.namelist()
        for name in names:
            parts = PurePosixPath(name).parts
            assert '..' not in parts and not name.startswith('/')
            assert not any(p in ('.git', '.openai', '.pbi', 'node_modules', '__pycache__') for p in parts)
            assert not any('/'+folder+'/' in name for folder in ('data/raw', 'data/processed', 'data/synthetic', 'renv/library'))
            if name.endswith('.csv') and ('/Data/' in name or '/outputs/exports/powerbi/' in name):
                reader = csv.DictReader(io.StringIO(archive.read(name).decode('utf-8-sig')))
                assert not {'etudiant_id', 'inscription_id', 'diplome_id'} & set(reader.fieldnames)
                for row in reader:
                    if row.get('masque') == 'TRUE':
                        assert all(not value for key, value in row.items()
                                   if key not in ('annee', 'formation_id', 'masque'))
        if path.name == 'Observatoire_Sources.zip':
            for required in ('renv/activate.R', 'scripts/activate_environment.R',
                             'assets/previews/dashboard.png', 'assets/previews/shiny.png',
                             'scripts/build_presentation_site.py', '.quartoignore'):
                assert 'Observatoire/'+required in names, required
        checked.append({'archive': path.name, 'entrees': len(names), 'statut': 'VALIDE'})
assert len(checked) == 3
out = ROOT/'outputs/validation_finale/archives_publication.json'
out.write_text(json.dumps(checked, indent=2), encoding='utf-8')
print(json.dumps(checked))
