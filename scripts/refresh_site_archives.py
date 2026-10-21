"""Actualise la documentation et les liens dans les archives distribuées."""
from pathlib import Path
from io import BytesIO
from zipfile import ZipFile, ZIP_DEFLATED
import hashlib
import json
import shutil

ROOT = Path(__file__).resolve().parents[1]
for folder in ('sites/presentation/dist/telechargements', '_site/telechargements'):
    directory = ROOT / folder
    archive = directory / 'Observatoire_Sources.zip'
    if not archive.exists():
        continue
    output = BytesIO()
    with ZipFile(archive) as source, ZipFile(output, 'w', ZIP_DEFLATED) as target:
        for entry in source.infolist():
            data = source.read(entry.filename)
            relative = entry.filename.removeprefix('Observatoire/')
            if relative in ('README.md', 'docs/14_recette_dashboard.md', 'docs/17_site_presentation.md', 'docs/18_site_quarto.md'):
                data = (ROOT / relative).read_bytes()
            target.writestr(entry, data)
    archive.write_bytes(output.getvalue())
    manifest = directory / 'manifest.json'
    if manifest.exists():
        content = json.loads(manifest.read_text(encoding='utf-8'))
        # Le format du manifeste est conservé ; seules les empreintes modifiées changent.
        def update(value):
            if isinstance(value, dict):
                filename = value.get('file') or value.get('fichier') or value.get('name') or value.get('path')
                if filename and Path(filename).name == archive.name:
                    if 'sha256' in value:
                        value['sha256'] = hashlib.sha256(archive.read_bytes()).hexdigest()
                    for key in ('bytes', 'size', 'taille_octets', 'octets'):
                        if key in value:
                            value[key] = archive.stat().st_size
                for child in value.values():
                    update(child)
            elif isinstance(value, list):
                for child in value:
                    update(child)
        update(content)
        manifest.write_text(json.dumps(content, ensure_ascii=False, indent=2), encoding='utf-8')
shutil.make_archive(str(ROOT/'outputs/Observatoire_Site_Quarto'), 'zip', ROOT/'_site')
