# Tableau de bord interactif — recette du 21 octobre 2026

La fiche pédagogique est dans `13_maitriser_les_indicateurs.md`. L'interface complète les sources Power BI, sans constituer un PBIX.

- Version locale : `dashboards/interactive/dist/index.html` ; ouverture directe sans serveur.
- [Version intégrée au site du projet](../_site/dashboard/index.html).
- Déploiement Sites : statut `succeeded`, version `appgprj_6ad8109a1260819182a275c8a43f12eb~appgver_ee20dc5a5800819190e9ecb5bc331dfe`.
- Sources du site : dépôt isolé dans `dashboards/interactive/`, commit `d32d3509cacb45f52a21d0aaa7a12962ed5ead9f`. La synchronisation Sites ne publie pas le dépôt statistique sur GitHub.
- Dix-huit contrôles JavaScript exécutés : agrégats, filtrage, censure, masquage, cartes, graphique, réinitialisation et huit fiches.
- Chrome a exécuté la page locale : contrôle des cartes initiales dans le DOM et capture examinée visuellement dans `outputs/dashboard-qa/dashboard.png`. Les interactions sont testées avec un DOM simulé ; aucun contrôle manuel exhaustif dans chaque navigateur n'est revendiqué.

Seuls les comptes agrégés déjà protégés sont embarqués ; aucune ligne individuelle, aucune valeur masquée n'est envoyée au navigateur. Le filtre année correspond à l'année de diplôme pour l'emploi. En 2025-2026, cet horizon est non observable ; les autres années d'insertion sont masquées selon la règle de diffusion conservatrice du projet. Aucun nombre illustratif de la maquette initiale n'est présenté comme résultat calculé.

Actualisation : pipeline R, puis `python scripts/build_dashboard_data.py`. La version hébergée est un instantané qui nécessite un nouveau déploiement pour être actualisée. Aucune collecte, aucun envoi d'enquête ni actualisation distante automatique.
