"""Telecharger les schemas publics Microsoft, uniquement pour la validation locale."""
import json
import urllib.request
from pathlib import Path

root = Path(__file__).resolve().parents[1]
folder = root / 'outputs/powerbi-qa/schemas'
folder.mkdir(parents=True, exist_ok=True)
base = 'https://developer.microsoft.com/json-schemas/fabric/'
schemas = {
    'project': 'pbip/pbipProperties/1.0.0/schema.json',
    'report_properties': 'item/report/definitionProperties/2.0.0/schema.json',
    'model_properties': 'item/semanticModel/definitionProperties/1.0.0/schema.json',
    'report': 'item/report/definition/report/2.0.0/schema.json',
    'page': 'item/report/definition/page/2.0.0/schema.json',
    'pages': 'item/report/definition/pagesMetadata/1.0.0/schema.json',
    'visual': 'item/report/definition/visualContainer/2.1.0/schema.json',
    'version': 'item/report/definition/versionMetadata/1.0.0/schema.json',
}
for name, url in schemas.items():
    target = folder / f'{name}.json'
    if target.exists(): continue
    try:
        with urllib.request.urlopen(base + url, timeout=15) as response:
            content = json.load(response)
        target.write_text(json.dumps(content, indent=2), encoding='utf-8')
        print(name, 'OK')
    except Exception as exc:
        print(name, type(exc).__name__, str(exc)[:200])
        raise
