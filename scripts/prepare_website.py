from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
# Les sources canoniques restent dans reports/.
for name in ('rapport_final', 'note_pilotage', 'enquetes', 'presentation'):
    text = (ROOT / 'reports' / f'{name}.qmd').read_text(encoding='utf-8')
    text = text.replace('css: report.css', 'css: reports/report.css').replace('css: note.css', 'css: reports/note.css')
    if name == 'note_pilotage':
        text = text.replace('theme: none', 'theme: cosmo').replace('css: reports/note.css', 'css: website.css')
    (ROOT / f'{name}.qmd').write_text(text, encoding='utf-8')
