from pathlib import Path
import shutil
ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / '_site'
PORTAL = ROOT / 'sites/presentation/dist'
for folder in ('dashboard', 'assets', 'telechargements'):
    shutil.copytree(PORTAL / folder, SITE / folder, dirs_exist_ok=True)
for name in ('rapport_final', 'note_pilotage', 'enquetes'):
    shutil.copy2(ROOT / 'outputs/reports/reports' / f'{name}.pdf', SITE / f'{name}.pdf')
for name in ('shiny', 'powerbi'):
    (SITE / f'{name}.html').write_text('<!doctype html><html lang="fr"><meta charset="utf-8"><meta http-equiv="refresh" content="0;url=tableaux_de_bord.html#' + name + '"><title>Guide</title><a href="tableaux_de_bord.html#' + name + '">Ouvrir le guide</a></html>', encoding='utf-8')
(SITE / '.nojekyll').touch()
print('Site Quarto assemble dans _site/.')
