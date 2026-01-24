# Guide de création des issues GitHub

Ce dossier contient tous les issues GitHub à créer pour les évolutions futures de RepoLens.

## Fichiers

- `ISSUES.md` - Liste complète de tous les issues (55 issues) avec descriptions détaillées
- `scripts/create_issues.sh` - Script pour créer automatiquement les issues sur GitHub

## Création manuelle des issues

1. Ouvrir le fichier `ISSUES.md`
2. Copier le contenu d'un issue (de `### Issue #X:` jusqu'à `---`)
3. Aller sur GitHub et créer un nouveau issue
4. Coller le contenu et ajuster le formatage si nécessaire
5. Ajouter les labels appropriés

## Création automatique avec le script

### Prérequis

- GitHub CLI (`gh`) installé et authentifié
- `jq` installé
- Accès en écriture au repository

### Utilisation

```bash
# Depuis la racine du projet
cd .github/scripts
./create_issues.sh [owner/repo]

# Exemple
./create_issues.sh kdelfour/repolens
```

Le script va:
1. Extraire chaque issue du fichier `ISSUES.md`
2. Créer l'issue sur GitHub avec les labels appropriés
3. Afficher l'URL de chaque issue créée

**Note:** Le script fait une pause d'1 seconde entre chaque issue pour éviter le rate limiting de GitHub.

## Organisation suggérée

### Milestones

- **v0.2.0** - Issues prioritaires pour la prochaine version majeure
- **v0.3.0** - Fonctionnalités importantes
- **Backlog** - Améliorations futures

### Labels recommandés

Créer les labels suivants sur GitHub:

```
enhancement
feature
bug
documentation
testing
security
performance
ux
i18n
technical
refactoring
maintenance
priority:high
priority:medium
priority:low
```

### Priorisation

Les issues sont organisés par catégorie dans `ISSUES.md`. Pour la priorisation:

1. **High Priority** - Fonctionnalités critiques pour l'adoption
2. **Medium Priority** - Améliorations importantes
3. **Low Priority** - Nice-to-have

## Structure d'un issue

Chaque issue dans `ISSUES.md` suit ce format:

```markdown
### Issue #X: Titre

**Labels:** `label1`, `label2`

**Description:**

Description détaillée...

**Objectifs:**
- Objectif 1
- Objectif 2

**Acceptance Criteria:**
- [ ] Critère 1
- [ ] Critère 2
```

## Notes importantes

- Les issues sont numérotés de 1 à 55
- Chaque issue est indépendant et peut être traité séparément
- Certains issues peuvent avoir des dépendances (mentionnées dans la description)
- Les issues peuvent être adaptés selon les retours de la communauté
