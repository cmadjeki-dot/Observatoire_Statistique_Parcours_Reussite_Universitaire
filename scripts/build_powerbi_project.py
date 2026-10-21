"""Generer un projet Power BI natif (PBIP/PBIR et modele TMSL)."""
import csv
import hashlib
import json
import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / 'dashboards/powerbi/Observatoire'
REPORT = PROJECT / 'Observatoire.Report'
MODEL = PROJECT / 'Observatoire.SemanticModel'
BASE = 'https://developer.microsoft.com/json-schemas/fabric/'
REPORT_BASE = BASE + 'item/report/definition/'
INK, GREEN, PAPER = '#183B38', '#217762', '#F5F7F4'

def write(path, obj):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

def literal(value):
    if isinstance(value, bool): value = str(value).lower()
    elif isinstance(value, (int, float)): value = f'{value}D'
    else: value = "'" + str(value).replace("'", "''") + "'"
    return {'expr': {'Literal': {'Value': value}}}

def colour(value): return {'solid': {'color': literal(value)}}
def props(**values): return [{'properties': values}]
def field(table, name, measure=False):
    return {'Measure' if measure else 'Column': {'Expression': {'SourceRef': {'Entity': table}}, 'Property': name}}
def projection(table, name, measure=False):
    return {'field': field(table, name, measure), 'queryRef': f'{table}.{name}', 'nativeQueryRef': name}

def container(title=None, background='#FFFFFF', border=True):
    result = {'background': props(show=literal(True), color=colour(background), transparency=literal(0)),
        'border': props(show=literal(border), color=colour('#E1E8E1'), radius=literal(8)),
        'padding': props(top=literal(12), bottom=literal(12), left=literal(16), right=literal(16)),
        'visualHeader': props(show=literal(False))}
    result['title'] = props(show=literal(title is not None), text=literal(title or ''),
        fontColor=colour(INK), fontSize=literal(12), fontFamily=literal('Segoe UI Semibold'))
    return result

class Page:
    def __init__(self, name, label):
        self.name = name
        self.folder = REPORT / 'definition/pages' / name
        self.index = 0
        write(self.folder / 'page.json', {'$schema': REPORT_BASE + 'page/2.0.0/schema.json',
            'name': name, 'displayName': label, 'displayOption': 'FitToPage', 'width': 1440, 'height': 1000,
            'objects': {'background': props(color=colour(PAPER), transparency=literal(0))}})
    def add(self, kind, x, y, w, h, roles=None, objects=None, vco=None, extra=None):
        self.index += 1
        name = hashlib.sha256(f'{self.name}-{self.index}'.encode()).hexdigest()[:20]
        visual = {'visualType': kind, 'drillFilterOtherVisuals': True}
        if roles: visual['query'] = {'queryState': {k: {'projections': v} for k,v in roles.items()}}
        if objects: visual['objects'] = objects
        if vco: visual['visualContainerObjects'] = vco
        if extra: visual.update(extra)
        obj = {'$schema': REPORT_BASE + 'visualContainer/2.1.0/schema.json', 'name': name,
            'position': {'x':x,'y':y,'width':w,'height':h,'z':self.index*1000,'tabOrder':self.index*1000}, 'visual':visual}
        write(self.folder / 'visuals' / name / 'visual.json', obj)
        return name
    def text(self, text, x, y, w, h, size=14, color=INK, background=None, bold=False):
        paragraphs = [{'textRuns':[{'value': line, 'textStyle': {'fontFamily':'Segoe UI',
            'fontSize': f'{size}px', 'fontWeight': 'bold' if bold else 'normal', 'color':color}}]} for line in text.split('\n')]
        vco = container(background=background or PAPER, border=False)
        vco['padding'] = props(top=literal(8), bottom=literal(8), left=literal(12), right=literal(12))
        self.add('textbox',x,y,w,h,objects={'general':props(paragraphs=paragraphs)},vco=vco)
    def card(self, title, measure, x, y, w=260, h=142, size=28):
        self.add('card',x,y,w,h,{'Values':[projection('Indicateurs',measure,True)]},
            {'labels':props(fontSize=literal(size), color=colour(INK), labelDisplayUnits=literal(1)),
             'categoryLabels':props(show=literal(False)), 'wordWrap':props(show=literal(True))}, container(title))
    def slicer(self, table, column, label, x, y, w, selected=None):
        objects = {'data':props(mode=literal('Dropdown')), 'header':props(show=literal(True), text=literal(label)),
            'selection':props(singleSelect=literal(table=='DimAnnee'), selectAllCheckboxEnabled=literal(table!='DimAnnee'))}
        if selected is not None:
            objects['general'] = props(filter={'filter': {'Version':2,'From':[{'Name':'s','Entity':table,'Type':0}],
                'Where':[{'Condition':{'In':{'Expressions':[{'Column':{'Expression':{'SourceRef':{'Source':'s'}},'Property':column}}],
                    'Values':[[{'Literal':{'Value':"'"+selected+"'"}}]]}}}]}})
        self.add('slicer',x,y,w,88,{'Values':[projection(table,column)]},objects,container(),
            {'syncGroup':{'groupName':table,'fieldChanges':True,'filterChanges':True}})
    def line(self, title, measure, x, y, w=1100, h=310):
        self.add('lineChart',x,y,w,h,{'Category':[projection('DimAnneeGraph','annee')],
            'Y':[projection('Indicateurs',measure,True)]},
            {'dataPoint':props(defaultColor=colour(GREEN)), 'labels':props(show=literal(True), color=colour(GREEN), fontSize=literal(11)),
             'legend':props(show=literal(False)), 'categoryAxis':props(show=literal(True), showAxisTitle=literal(False)),
             'valueAxis':props(show=literal(True), showAxisTitle=literal(False))},container(title))

def shell(page, title, subtitle):
    page.text('',0,0,224,1000,background='#123F36')
    page.text('O ·  Observatoire',16,30,196,55,22,'#EDF5ED',background='#123F36',bold=True)
    page.text('PARCOURS UNIVERSITAIRES',16,88,196,44,10,'#A6C1B8',background='#123F36')
    page.text('ESPACE DE PILOTAGE',16,185,196,42,10,'#A6C1B8',background='#123F36')
    page.add('pageNavigator',16,240,196,220,objects={
        'layout':props(orientation=literal('Vertical')),
        'text':props(fontColor=colour('#EDF5ED'), fontSize=literal(12)),
        'fill':props(show=literal(True), fillColor=colour('#28564B'))}, vco=container(background='#123F36',border=False))
    page.text('100 % FICTIF\nR · POWER BI',16,865,196,95,12,'#D6E6B5',background='#123F36')
    page.text('Études & pilotage  /  Observatoire étudiant',260,22,830,36,12,'#72817E')
    page.text('DÉMONSTRATION',1190,22,210,36,11,'#58704D')
    page.text(title,260,74,1120,57,32,INK,bold=True)
    page.text(subtitle,260,132,1120,38,13,'#72817E')
    page.text('Données entièrement fictives · Aucun résultat réel de l’UPEC · Clôture : 30 septembre 2026',260,180,1120,45,12,'#58704D',background='#EDF1E4')

def parse_measures():
    measures, name, lines = {}, None, []
    for line in (ROOT/'dashboards/powerbi/mesures.dax').read_text(encoding='utf-8').splitlines():
        if line.strip().startswith('//'): continue
        match = re.match(r'^([A-Za-z][A-Za-z0-9 ]*?)\s*=\s*(.*)$',line)
        if match and not line.startswith(('VAR ','RETURN ')):
            if name: measures[name] = '\n'.join(lines).strip()
            name, lines = match.group(1).strip(), [match.group(2)]
        elif name: lines.append(line)
    if name: measures[name] = '\n'.join(lines).strip()
    return measures

def build_model():
    exports = ROOT/'outputs/exports/powerbi'
    files = {'DimFormation':'dim_formation.csv','DimAnnee':'dim_annee.csv','DimAnneeGraph':'dim_annee.csv',
        'FactScolarite':'fait_scolarite.csv','FactEvaluation':'fait_evaluation.csv','FactInsertion':'fait_insertion.csv'}
    tables = []
    for name, filename in files.items():
        target = PROJECT/'Data'/filename
        target.parent.mkdir(parents=True,exist_ok=True)
        shutil.copyfile(exports/filename,target)
        with target.open(encoding='utf-8',newline='') as stream: rows=list(csv.DictReader(stream))
        assert not {'etudiant_id','inscription_id','diplome_id'} & rows[0].keys()
        columns=[]; texts=[]
        for col in rows[0]:
            kind = 'boolean' if col=='masque' else 'string' if col in ('annee','formation_id','libelle_fictif','composante_fictive','cycle') else 'int64'
            if kind=='string' or col=='masque': texts.append(col)
            c={'name':col,'dataType':kind,'sourceColumn':col,'summarizeBy':'none'}
            if name.startswith('Fact') and col not in ('annee','formation_id'): c['isHidden']=True
            if kind=='int64': c['formatString']='0'
            if name=='DimAnnee' and col=='annee': c['sortByColumn']='ordre'
            if name=='DimAnneeGraph' and col=='annee': c['sortByColumn']='ordre'
            columns.append(c)
        m='fxCsv("'+filename+'", {'+', '.join('"'+v+'"' for v in texts)+'}, '+str(name.startswith('Fact')).lower()+')'
        tables.append({'name':name,'columns':columns,'partitions':[{'name':name,'mode':'import','source':{'type':'m','expression':m}}]})
    measures=parse_measures()
    measures.update({
        'Emploi affichage':'SWITCH(TRUE(), NOT(HASONEVALUE(DimAnnee[annee])), "Sélectionner une année", [Insertion masquee], "Masqué", SUM(FactInsertion[eligibles]) = 0, "Non observable", ISBLANK([Emploi six mois]), "Non calculable", FORMAT([Emploi six mois], "0.0 %", "fr-FR"))',
        'Passage affichage':'SWITCH(TRUE(), NOT(HASONEVALUE(DimAnnee[annee])), "Sélectionner une année", [Scolarite masquee], "Masqué", SUM(FactScolarite[suivis]) = 0, "Non observable", ISBLANK([Passage]), "Non calculable", FORMAT([Passage], "0.0 %", "fr-FR"))',
        'Reorientation affichage':'SWITCH(TRUE(), NOT(HASONEVALUE(DimAnnee[annee])), "Sélectionner une année", [Scolarite masquee], "Masqué", SUM(FactScolarite[suivis]) = 0, "Non observable", FORMAT([Reorientation], "0.0 %", "fr-FR"))',
        'Sortie affichage':'SWITCH(TRUE(), [Scolarite masquee], "Masqué", SUM(FactScolarite[suivis]) = 0, "Non observable", FORMAT([Sortie observee], "0.0 %", "fr-FR"))',
        'Inconnus affichage':'SWITCH(TRUE(), [Scolarite masquee], "Masqué", SUM(FactScolarite[suivis]) = 0, "Non observable", FORMAT([Situation inconnue], "0.0 %", "fr-FR"))',
        'Validation evolution':'VAR AnneeGraph = SELECTEDVALUE(DimAnneeGraph[annee])\nRETURN CALCULATE([Validation eligibles], REMOVEFILTERS(DimAnnee), TREATAS({AnneeGraph}, DimAnnee[annee]))',
        'Effectifs evolution':'VAR AnneeGraph = SELECTEDVALUE(DimAnneeGraph[annee])\nRETURN CALCULATE([Inscrits], REMOVEFILTERS(DimAnnee), TREATAS({AnneeGraph}, DimAnnee[annee]))',
        'Satisfaction evolution':'VAR AnneeGraph = SELECTEDVALUE(DimAnneeGraph[annee])\nRETURN CALCULATE([Satisfaction], REMOVEFILTERS(DimAnnee), TREATAS({AnneeGraph}, DimAnnee[annee]))',
    })
    integers={'Inscrits','Inscriptions annuelles cumulees','Avis valides','Eligibles insertion','Non matures','Situations connues','Effectifs evolution'}
    model_measures=[]
    for name,expression in measures.items():
        m={'name':name,'expression':expression,'displayFolder':'Diagnostic' if name.endswith('masquee') else 'Indicateurs'}
        if name.endswith('masquee'): m['isHidden']=True
        elif not name.endswith('affichage'): m['formatString']='#,0' if name in integers else '0.0%'
        model_measures.append(m)
    tables.append({'name':'Indicateurs','columns':[{'name':'vide','dataType':'int64','sourceColumn':'vide','isHidden':True}],
        'measures':model_measures,'partitions':[{'name':'Indicateurs','mode':'import','source':{'type':'m','expression':'#table(type table [vide = Int64.Type], {{0}})'}}]})
    relationships=[]
    for fact in ('FactScolarite','FactEvaluation','FactInsertion'):
        for dim,col in [('DimFormation','formation_id'),('DimAnnee','annee')]:
            relationships.append({'name':f'{fact}_{dim}','fromTable':fact,'fromColumn':col,'toTable':dim,'toColumn':col,
                'crossFilteringBehavior':'oneDirection','fromCardinality':'many','toCardinality':'one'})
    parameter=json.dumps((PROJECT/'Data').as_posix()+'/',ensure_ascii=False)+' meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]'
    fx='\n'.join(line for line in (ROOT/'dashboards/powerbi/fxCsv.pq').read_text(encoding='utf-8').splitlines() if not line.startswith('//'))
    database={'name':'Observatoire','compatibilityLevel':1567,'model':{'culture':'fr-FR','defaultPowerBIDataSourceVersion':'powerBI_V3',
        'sourceQueryCulture':'fr-FR','tables':tables,'relationships':relationships,
        'expressions':[{'name':'DossierExports','kind':'m','expression':parameter},{'name':'fxCsv','kind':'m','expression':fx}],
        'annotations':[{'name':'PBI_ProTooling','value':'["DevMode"]'}]}}
    write(MODEL/'model.bim',database)
    write(MODEL/'definition.pbism',{'$schema':BASE+'item/semanticModel/definitionProperties/1.0.0/schema.json','version':'1.0','settings':{'qnaEnabled':False}})

def main():
    build_model()
    write(PROJECT/'Observatoire.pbip',{'$schema':BASE+'pbip/pbipProperties/1.0.0/schema.json','version':'1.0',
        'artifacts':[{'report':{'path':'Observatoire.Report'}}],'settings':{'enableAutoRecovery':True}})
    write(REPORT/'definition.pbir',{'$schema':BASE+'item/report/definitionProperties/2.0.0/schema.json','version':'4.0',
        'datasetReference':{'byPath':{'path':'../Observatoire.SemanticModel'}}})
    write(REPORT/'definition/version.json',{'$schema':REPORT_BASE+'versionMetadata/1.0.0/schema.json','version':'2.0.0'})
    write(REPORT/'definition/report.json',{'$schema':REPORT_BASE+'report/2.0.0/schema.json',
        'themeCollection':{'baseTheme':{'name':'CY24SU10','reportVersionAtImport':'5.60','type':'SharedResources'}}})
    pages=[('01_synthese','Vue d’ensemble'),('02_parcours','Parcours & devenir'),('03_methode','Indicateurs & méthode')]
    write(REPORT/'definition/pages/pages.json',{'$schema':REPORT_BASE+'pagesMetadata/1.0.0/schema.json',
        'pageOrder':[n for n,_ in pages],'activePageName':pages[0][0]})
    p=Page(*pages[0]);shell(p,'Les parcours en perspective.','Une lecture de la réussite, des enquêtes et de leur couverture.')
    p.slicer('DimAnnee','annee','Année universitaire',260,240,225,'2025-2026')
    p.slicer('DimFormation','libelle_fictif','Formation',510,240,520)
    for i,(title,measure) in enumerate([('Étudiants inscrits','Inscrits'),('Validation annuelle','Validation eligibles'),('Satisfaction','Satisfaction'),('Emploi à six mois','Emploi affichage')]):
        p.card(title,measure,260+i*286,350,w=260,size=22 if i==3 else 30)
    p.line('Évolution de la validation annuelle · données fictives','Validation evolution',260,520,w=1118,h=310)
    p.card('Couverture des résultats','Couverture resultats',260,855,w=260,h=112,size=24)
    p.card('Participation à l’évaluation','Participation evaluation',546,855,w=260,h=112,size=24)
    p.card('Évolution des inscrits','Evolution',832,855,w=260,h=112,size=24)
    p.text('Comparer les comptes,\npas les moyennes de taux.',1118,855,260,112,14,'#58704D',background='#EDF1E4')
    p=Page(*pages[1]);shell(p,'Parcours & devenir.','Distinguer réinscription, sortie documentée et situation inconnue.')
    p.slicer('DimAnnee','annee','Cohorte / année de diplôme',260,240,260,'2025-2026')
    p.slicer('DimFormation','libelle_fictif','Formation',546,240,520)
    for i,(title,measure) in enumerate([('Passage','Passage affichage'),('Réorientation','Reorientation affichage'),('Sortie documentée','Sortie affichage'),('Situation inconnue','Inconnus affichage')]):
        p.card(title,measure,260+i*286,350,w=260,size=22)
    p.text('Absence de réinscription ≠ abandon définitif.\nLa dernière année est censurée pour les transitions futures.\nLe passage exclut les niveaux terminaux ; les autres taux utilisent la cohorte suivable.',260,520,1118,135,17,background='#EDF1E4')
    p.card('Emploi à six mois','Emploi affichage',260,690,w=350,h=140,size=24)
    p.card('Diplômés non encore matures','Non matures',640,690,w=350,h=140,size=28)
    p.text('L’année sélectionnée est l’année de diplôme.\nLes petits comptes et leurs compléments sont retirés avant import.\nMasqué et non observable ne signifient pas zéro.',260,860,1118,110,15,'#58704D')
    p=Page(*pages[2]);shell(p,'Les 8 indicateurs à maîtriser.','Définitions opérationnelles · périodes · exclusions · dénominateurs')
    definitions=[('Effectifs inscrits','Étudiants distincts dans l’année et la formation.\nNe pas additionner les années pour compter des personnes uniques.'),
        ('Évolution des inscriptions','(N courant − N précédent) / N précédent × 100.\nAnnées consécutives et périmètre comparable ; NA si base nulle.'),
        ('Validation annuelle','Validations connues / inscriptions éligibles.\nAfficher couverture et taux parmi connus ; diplôme terminal distinct.'),
        ('Passage','Passages / inscriptions non terminales suivables.\nDernière année censurée pour le suivi futur.'),
        ('Réorientation','Autre formation à l’année suivante / cohorte suivable.\nNe pas assimiler une absence à un abandon.'),
        ('Participation à l’enquête','Répondants substantiels / invitations délivrées.\nUne inscription par vague ; décrire la non-réponse.'),
        ('Satisfaction','Notes 4 ou 5 / avis valides de 1 à 5.\nExclure sans avis et items manquants ; montrer la participation.'),
        ('Emploi à six mois','Emploi / situations connues, études comprises.\nDiplôme + six mois atteint ; insertion parmi actifs distincte.')]
    for i,(title,text) in enumerate(definitions):
        x=260+(i%2)*572;y=250+(i//2)*169
        p.text(f'{i+1:02d} · {title}',x,y,546,49,19,background='#FFFFFF',bold=True)
        p.text(text,x,y+48,546,104,14,'#657A6B',background='#FFFFFF')
    (PROJECT/'.gitignore').write_text('**/.pbi/\n*.pbix\n',encoding='utf-8')
    print('Projet genere :',PROJECT/'Observatoire.pbip')
    print('3 pages,',len(list((REPORT/'definition/pages').glob('*/visuals/*/visual.json'))),'visuels natifs, 7 tables, 6 relations.')

if __name__=='__main__': main()
