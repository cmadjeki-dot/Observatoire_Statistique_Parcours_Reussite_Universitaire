# Publication préparée localement

Le dépôt est local : aucun commit, dépôt distant ou envoi à GitHub n'est effectué automatiquement. Vérifier identité, licence souhaitée, contenu et accès avant publication. Les fichiers `data/`, `outputs/`, bibliothèques renv, caches et PBIX restent ignorés par défaut.

Le portfolio peut présenter le README, les méthodes, les fonctions R, les tests, les questionnaires fictifs et les sources Quarto. Pour joindre des rapports rendus, sélectionner uniquement les HTML/PDF relus dans `outputs/reports/reports/` ; ne jamais ajouter tout outputs/ ou data/ en bloc. La note et les rapports signalent les limites Power BI et le caractère fictif.

Avant ajout : examiner `git status --short`, `git diff --check`, puis les fichiers à indexer. Le diagnostic local inclut un chemin utilisateur et doit rester local. Les données synthétiques sont reproductibles, leur publication n'est pas nécessaire pour reproduire les résultats. Le fichier de configuration et renv.lock suffisent avec le code et un environnement compatible.

CI : restauration renv, pipeline et tests sous Windows ; sa configuration sera versionnée après succès local. Elle n'a pas été exécutée sur un serveur GitHub dans cette session et ne valide ni Power BI ni l'import LimeSurvey.
