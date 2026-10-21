# Plan qualité

Conserver une référence synthétique cohérente et immuable. Introduire les anomalies dans une copie `data/raw/` en enregistrant graine, règle, clés touchées et valeur d'origine dans un registre réservé à la validation. Le nettoyage ne doit pas lire ce registre pour retrouver artificiellement les bonnes valeurs.

Contrôles : clés uniques et non nulles, références existantes, domaines de valeurs, ECTS entre 0 et 60, années et dates cohérentes, diplôme terminal avec validation, trajectoires compatibles et sollicitations dédupliquées. Séparer avertissements et erreurs bloquantes. Une donnée manquante plausible n'est pas systématiquement une anomalie.

Doublons strictement identiques : suppression journalisée ; doublons contradictoires : mise en quarantaine tant qu'une règle fiable n'est pas disponible. Ne pas choisir arbitrairement la première ligne. Conserver les manques sans justification d'imputation. Journal : contrôle, table, clé, valeur avant/après si applicable, règle, motif et statut.

Recette : rapprochement des volumes avant/après, absence de violation bloquante dans les tables diffusables, exceptions documentées, comparaison des anomalies détectées aux anomalies injectées. Ne pas prétendre détecter une anomalie non identifiable à partir des données.
