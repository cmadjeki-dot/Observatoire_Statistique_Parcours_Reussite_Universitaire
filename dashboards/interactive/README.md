# Observatoire interactif

Tableau de bord HTML/CSS/JavaScript autonome, sans dépendances ni services de données. Ouvrir `dist/index.html` pour la version locale. Les données sont entièrement fictives ; aucun résultat UPEC.

Les filtres année/formation recalculent les comptes et proportions. Trois vues : essentiels, parcours/devenir et huit fiches méthodologiques. Graphique commutable validation/effectifs/satisfaction, tableau de valeurs accessible et réinitialisation des filtres.

Seuls les exports **agrégés et protégés** de `outputs/exports/powerbi/` sont embarqués. Les valeurs masquées ne sont pas livrées au navigateur. L'année sélectionnée pour l'emploi est l'année du diplôme : 2025-2026 reste non observable à six mois. Les années antérieures d'insertion sont masquées par la règle conservatrice de diffusion du projet.

Actualiser : exécuter le pipeline R puis `python scripts/build_dashboard_data.py` depuis la racine. Depuis ce dossier : `node test-dashboard.cjs`. Les tests couvrent filtres, valeurs calculées, masquage, censure, graphique et remise à zéro. Cette interface complète les sources Power BI ; elle ne constitue pas un PBIX.

Pour la fiche d'entretien complète et les exemples chiffrés : `docs/13_maitriser_les_indicateurs.md` à la racine du projet.
