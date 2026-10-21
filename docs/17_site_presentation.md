# Site de présentation du projet

**[Ouvrir la page d’accueil](../_site/index.html)**

- [Présentation du projet](../_site/projet.html)
- [Tableaux de bord](../_site/tableaux_de_bord.html)
- [Rapport final — treize chapitres](../_site/rapport_final.html)
- [Rapports et téléchargements](../_site/livrables.html)
- [Archive du site complet](../outputs/Observatoire_Site_Quarto.zip)

Ces liens ouvrent les pages du site Quarto généré dans le projet.

## Consulter le site dans un navigateur

Depuis la racine du projet :

```powershell
quarto preview --port 4200 --no-browser
```

Ouvrir ensuite [la page d’accueil locale](http://localhost:4200/).
Le serveur doit rester actif pendant la consultation.

## Contenu

Le site réunit la présentation de la démarche, le tableau de bord web interactif,
les versions Shiny et Power BI à télécharger et les rapports Quarto HTML/PDF.
Le rapport final comporte les treize chapitres demandés avec une table des
matières numérotée. Les données sont entièrement fictives et le projet n’a
aucune affiliation officielle avec l’UPEC.

Le tableau de bord web est utilisable directement. Shiny nécessite R et un
serveur adapté ; le projet Power BI s’ouvre dans Power BI Desktop.

## Construire et vérifier

```powershell
quarto render
python scripts/verify_classic_website.py
```

Les contrôles portent sur dix pages, 254 liens locaux et les treize chapitres
du rapport. Voir [la documentation technique](18_site_quarto.md) pour les
prérequis et les commandes de préparation des livrables.

## Adresse publique

Le site est prêt pour un hébergement classique ou GitHub Pages. Il n’a pas
encore d’adresse publique sur ces services : aucun dépôt Git distant n’est
configuré dans ce projet. Une adresse publique indépendante nécessite de
publier le site sur l’hébergement choisi.
