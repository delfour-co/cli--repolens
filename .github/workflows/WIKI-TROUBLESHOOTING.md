# Dépannage - Synchronisation du WIKI

Si la synchronisation du WIKI ne fonctionne pas, suivez ce guide de dépannage.

## Vérifications préalables

### 1. Le WIKI est-il activé ?

**Obligatoire** : Le WIKI doit être activé dans les paramètres GitHub avant que la synchronisation puisse fonctionner.

1. Allez sur votre repository GitHub
2. Cliquez sur **Settings**
3. Dans le menu de gauche, cliquez sur **Features**
4. Vérifiez que **Wikis** est activé (checkbox cochée)
5. Si ce n'est pas le cas, cochez la case et sauvegardez

⚠️ **Important** : Sans cette étape, GitHub ne créera pas le dépôt `.wiki` et la synchronisation échouera.

### 2. Vérifier les logs du workflow

1. Allez sur **Actions** dans votre repository
2. Trouvez le workflow **Sync Wiki**
3. Cliquez sur la dernière exécution
4. Examinez les logs de chaque étape

**Messages à rechercher :**

- ✅ `WIKI trouvé et accessible` : Le WIKI est activé et accessible
- ⚠️ `WIKI non trouvé ou non activé` : Le WIKI n'est pas activé
- ✅ `WIKI cloné avec succès` : Le WIKI existe et a été cloné
- 📝 `WIKI vide ou non initialisé` : Le WIKI est activé mais vide (normal pour le premier push)
- ✅ `WIKI synchronisé avec succès` : La synchronisation a réussi

### 3. Vérifier que les fichiers existent

Le workflow synchronise les fichiers du dossier `wiki/` (sauf `README.md`).

Vérifiez que vous avez des fichiers dans `wiki/` :

```bash
ls -la wiki/*.md
```

Vous devriez voir des fichiers comme :
- `Home.md`
- `Installation.md`
- `Guide-d-utilisation.md`
- etc.

## Problèmes courants

### Problème 1 : "WIKI non trouvé ou non activé"

**Cause** : Le WIKI n'est pas activé dans les paramètres GitHub.

**Solution** :
1. Activez le WIKI dans Settings > Features > Wikis
2. Relancez le workflow manuellement (Actions > Sync Wiki > Run workflow)

### Problème 2 : "Échec du push"

**Causes possibles** :
- Permissions insuffisantes
- WIKI non activé
- Problème d'authentification

**Solutions** :
1. Vérifiez que le WIKI est activé
2. Vérifiez les permissions du workflow (doit avoir `contents: write`)
3. Relancez le workflow

### Problème 3 : "Aucune page n'a été synchronisée"

**Causes possibles** :
- Aucun fichier dans `wiki/`
- Seulement `README.md` dans `wiki/` (qui est ignoré)
- Les fichiers n'ont pas changé

**Solutions** :
1. Vérifiez que vous avez des fichiers `.md` dans `wiki/` (autres que `README.md`)
2. Modifiez un fichier dans `wiki/` et faites un commit
3. Le workflow se déclenchera automatiquement

### Problème 4 : Le workflow se déclenche mais ne fait rien

**Cause** : Le workflow peut se déclencher même si aucun fichier dans `wiki/` n'a changé (par exemple si `README.md` a changé).

**Solution** :
- Le workflow vérifie automatiquement s'il y a des changements
- Si aucun changement n'est détecté, il affiche "Aucun changement détecté"
- C'est normal si les fichiers dans `wiki/` n'ont pas été modifiés

## Test manuel

Pour tester manuellement la synchronisation :

1. **Modifier un fichier dans `wiki/`** :
   ```bash
   echo "# Test" >> wiki/Home.md
   git add wiki/Home.md
   git commit -m "test: modification du WIKI"
   git push
   ```

2. **Ou déclencher manuellement le workflow** :
   - Allez sur Actions > Sync Wiki
   - Cliquez sur "Run workflow"
   - Sélectionnez la branche (main/master)
   - Cliquez sur "Run workflow"

## Vérification après synchronisation

Après une synchronisation réussie :

1. Allez sur votre repository GitHub
2. Cliquez sur l'onglet **Wiki** (à côté de Code, Issues, etc.)
3. Vous devriez voir les pages synchronisées :
   - Home
   - Installation
   - Guide-d-utilisation
   - etc.

## Logs détaillés

Le workflow affiche maintenant des logs détaillés à chaque étape :

- 📥 Clonage du WIKI
- 🔄 Synchronisation des pages
- ✏️ Mise à jour / ➕ Création de chaque page
- 📝 Commit des changements
- 📤 Push vers GitHub

Consultez ces logs pour identifier où le problème se produit.

## Support

Si le problème persiste :

1. Vérifiez les logs complets du workflow
2. Vérifiez que le WIKI est bien activé
3. Vérifiez que vous avez des fichiers dans `wiki/`
4. Ouvrez une issue sur GitHub avec les logs du workflow
