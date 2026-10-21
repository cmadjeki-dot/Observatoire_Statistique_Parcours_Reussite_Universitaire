# Observatoire — Power BI Desktop

Ouvrir **Observatoire.pbip**. Conserver tous les dossiers voisins ; ce fichier référence le rapport et le modèle, il n'est pas autonome.

Trois pages sont construites : Vue d'ensemble, Parcours & devenir et Indicateurs & méthode. Année et formation sont filtrables. La sélection initiale est 2025-2026, toutes formations.

Si les cartes sont vides, utiliser **Accueil → Actualiser**. Sur une autre machine, modifier le paramètre `DossierExports` dans Power Query pour pointer vers le dossier `Data` de ce projet (avec séparateur final `/`). Les CSV sont des agrégats protégés exclusivement fictifs. Aucun identifiant individuel.

Les chiffres 5 000, 72 %, 81 % et 64 % de la maquette ne sont pas utilisés. Les sorties 2025-2026 préparées donnent 10 222 inscrits, 73,2 % de validation annuelle et 71,4 % de satisfaction. L'emploi à six mois est non observable pour ces diplômés à la clôture. Les millésimes antérieurs d'insertion sont masqués par la règle conservatrice de diffusion.

Les calculs ont été rapprochés des résultats R dans le moteur local de Desktop : 126 comparaisons, aucun écart. Les fichiers PBIR ont été validés contre les schémas Microsoft. La vérification exhaustive du rendu visuel n'est pas revendiquée.

Le format livré est un **projet PBIP natif**. Pour créer une copie `.pbix`, utiliser **Fichier → Enregistrer sous** dans Desktop. Aucun déploiement dans le service Power BI n'est effectué.
