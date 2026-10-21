"""Verifier PBIR avec les schemas Microsoft et les references du modele."""
import csv
import hashlib
import importlib.metadata
import json
import sys
import urllib.parse
import urllib.request
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
QA=ROOT/'outputs/powerbi-qa'
try:
    import jsonschema
    from referencing import Registry, Resource
    from referencing.jsonschema import DRAFT7
except ImportError as error:
    raise SystemExit(
        "Dependances du validateur absentes ou incompletes. "
        "Executer scripts/setup_powerbi_validation.ps1, puis "
        ".venv-powerbi/Scripts/python.exe scripts/validate_powerbi_project.py"
    ) from error

PROJECT=ROOT/'dashboards/powerbi/Observatoire'
cache=QA/'schemas'
cache.mkdir(parents=True, exist_ok=True)
stored={}
for path in cache.glob('*.json'):
    obj=json.loads(path.read_text(encoding='utf-8'))
    if '$id' in obj: stored[obj['$id']]=obj

def retrieve(uri):
    url=urllib.parse.urldefrag(uri)[0]
    if url in stored: return Resource.from_contents(stored[url], default_specification=DRAFT7)
    if not url.startswith('https://developer.microsoft.com/json-schemas/'):
        raise ValueError('Domaine de schema non autorise : '+url)
    target=cache/(hashlib.sha256(url.encode()).hexdigest()+'.json')
    if target.exists(): obj=json.loads(target.read_text(encoding='utf-8'))
    else:
        with urllib.request.urlopen(url,timeout=20) as response: obj=json.load(response)
        target.write_text(json.dumps(obj,indent=2),encoding='utf-8')
    stored[url]=obj
    return Resource.from_contents(obj, default_specification=DRAFT7)

registry=Registry(retrieve=retrieve)
for uri,obj in stored.items(): registry=registry.with_resource(uri,Resource.from_contents(obj,default_specification=DRAFT7))
errors=[]; count=0
for path in PROJECT.rglob('*'):
    if path.suffix not in ('.json','.pbip','.pbir','.pbism'): continue
    obj=json.loads(path.read_text(encoding='utf-8'))
    if '$schema' not in obj: continue
    validator=jsonschema.Draft7Validator(retrieve(obj['$schema']).contents,registry=registry)
    for err in validator.iter_errors(obj): errors.append(f'{path.relative_to(PROJECT)} :: {list(err.path)} :: {err.message}')
    count+=1
if errors:
    print('\n'.join(errors[:20]));sys.exit(1)
model=json.loads((PROJECT/'Observatoire.SemanticModel/model.bim').read_text(encoding='utf-8'))['model']
tables={t['name']:t for t in model['tables']}
measures={m['name'] for t in model['tables'] for m in t.get('measures',[])}
for relationship in model['relationships']:
    for side in ('from','to'):
        assert relationship[side+'Column'] in {c['name'] for c in tables[relationship[side+'Table']]['columns']}
    assert relationship['crossFilteringBehavior']=='oneDirection'
for path in PROJECT.glob('Observatoire.Report/definition/pages/*/visuals/*/visual.json'):
    visual=json.loads(path.read_text(encoding='utf-8'))['visual']
    for role in visual.get('query',{}).get('queryState',{}).values():
        for proj in role['projections']:
            key=next(iter(proj['field']));spec=proj['field'][key]
            if key=='Measure': assert spec['Property'] in measures
            elif key=='Column': assert spec['Property'] in {c['name'] for c in tables[spec['Expression']['SourceRef']['Entity']]['columns']}
for path in (PROJECT/'Data').glob('fait_*.csv'):
    with path.open(encoding='utf-8',newline='') as stream:
        reader=csv.DictReader(stream)
        assert not {'etudiant_id','inscription_id','diplome_id'} & set(reader.fieldnames)
        for row in reader:
            if row['masque']=='TRUE': assert all(not v for k,v in row.items() if k not in ('annee','formation_id','masque'))
proof={'schema_files_validated':count,'schema_errors':0,'tables':len(tables),'relationships':len(model['relationships']),
       'measures':len(measures),'model_references':'valides','exports':'agreges_et_proteges',
       'desktop_visual_validation':'a_effectuer'}
proof['dependencies'] = {
    name: importlib.metadata.version(name)
    for name in ('jsonschema', 'referencing')
}
(QA/'recette-projet.json').write_text(json.dumps(proof,indent=2),encoding='utf-8')
print(json.dumps(proof,indent=2))
