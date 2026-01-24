# Update Documentation Command

Met à jour la documentation du projet et synchronise avec le WIKI GitHub.

## Objectif

Cet agent parcourt la documentation du projet, analyse les changements, et met à jour automatiquement :
- Les fichiers de documentation locaux (README.md, DEVELOPMENT.md, etc.)
- Le WIKI GitHub avec les pages appropriées
- La cohérence entre les différentes sources de documentation

## Étapes

1. **Analyser la documentation existante**
   - Lire les fichiers de documentation principaux :
     - `README.md`
     - `DEVELOPMENT.md`
     - `CHANGELOG.md`
     - `CLAUDE.md`
     - Fichiers dans `wiki/` (pages WIKI locales)
   - Identifier les sections qui ont changé ou qui sont obsolètes

2. **Vérifier la cohérence**
   - Comparer le contenu entre les différentes sources
   - Identifier les incohérences
   - Détecter les informations manquantes

3. **Mettre à jour la documentation**
   - Synchroniser les informations entre les fichiers
   - Mettre à jour les exemples de code
   - Corriger les liens et références
   - Ajouter les nouvelles fonctionnalités documentées dans le code

4. **Mettre à jour le WIKI GitHub**
   - La synchronisation se fait automatiquement via GitHub Actions lors d'un push
   - Le workflow `.github/workflows/sync-wiki.yml` synchronise automatiquement les pages
   - Pour une synchronisation manuelle locale, utiliser `scripts/update-wiki.sh`
   - Vérifier que toutes les pages sont à jour
   - S'assurer que les liens entre pages fonctionnent

5. **Vérifier les résultats**
   - Lancer une vérification finale
   - S'assurer que tous les fichiers sont cohérents

## Synchronisation automatique

La synchronisation du WIKI se fait **automatiquement via GitHub Actions** lors d'un push sur `main`/`master` si :
- Des fichiers dans `wiki/` sont modifiés
- `README.md`, `DEVELOPMENT.md` ou `CHANGELOG.md` sont modifiés

Le workflow `.github/workflows/sync-wiki.yml` gère cette synchronisation.

## Commandes utiles (pour synchronisation manuelle locale)

```bash
# Lancer la mise à jour complète (local uniquement)
./scripts/update-wiki.sh

# Mettre à jour une page spécifique
./scripts/update-wiki.sh Home.md

# Vérifier les différences avant mise à jour
./scripts/update-wiki.sh --dry-run

# Vérifier les différences sans mettre à jour
./scripts/update-wiki.sh --check
```

**Note** : En général, il n'est pas nécessaire d'utiliser le script manuellement car la CI synchronise automatiquement.

## Structure de la documentation

### Fichiers locaux
- `README.md` : Documentation principale pour les utilisateurs
- `DEVELOPMENT.md` : Guide de développement
- `CHANGELOG.md` : Historique des changements
- `CLAUDE.md` : Contexte pour Claude AI

### Pages WIKI (dans `wiki/`)
- `Home.md` : Page d'accueil du WIKI
- `Installation.md` : Guide d'installation
- `Guide-d-utilisation.md` : Guide d'utilisation
- `Configuration.md` : Configuration avancée
- `Presets.md` : Documentation des presets
- `Categories-de-regles.md` : Catégories de règles
- `Bonnes-pratiques.md` : Bonnes pratiques
- `Developpement.md` : Guide de développement
- `Architecture.md` : Architecture technique
- `Contribution.md` : Guide de contribution

## Bonnes pratiques

- Toujours vérifier la cohérence entre les sources
- Mettre à jour les exemples de code si l'API change
- Vérifier que les liens fonctionnent
- Maintenir la structure et le formatage
- Ajouter des sections manquantes si nécessaire

## Détection automatique

L'agent doit détecter :
- Nouvelles fonctionnalités dans le code non documentées
- Changements dans l'API ou les commandes CLI
- Fichiers de configuration ou presets modifiés
- Nouvelles catégories de règles
- Changements dans la structure du projet

## Synchronisation

La synchronisation doit :
1. Lire les fichiers locaux de documentation
2. Comparer avec les pages WIKI existantes
3. Mettre à jour uniquement ce qui a changé
4. Créer de nouvelles pages si nécessaire
5. Supprimer les pages obsolètes (avec confirmation)

## Notes

- **Synchronisation automatique** : La CI synchronise automatiquement lors d'un push
- Le script `update-wiki.sh` est disponible pour une synchronisation manuelle locale
- L'authentification GitHub CLI (`gh`) est nécessaire uniquement pour le script local
- Les pages WIKI sont dans le dossier `wiki/` localement
- Le workflow CI utilise `GITHUB_TOKEN` qui a les permissions nécessaires
- Toujours faire un `--dry-run` avant la mise à jour manuelle réelle
