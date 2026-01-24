#!/bin/bash

# Script de synchronisation de la documentation vers le WIKI GitHub
# Usage: ./scripts/update-wiki.sh [--dry-run] [page.md]

set -e

# Couleurs pour l'output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WIKI_DIR="$PROJECT_ROOT/wiki"
DRY_RUN=false
SPECIFIC_PAGE=""

# Fonction d'aide
show_help() {
    cat << EOF
Usage: $0 [OPTIONS] [PAGE]

Synchronise la documentation locale vers le WIKI GitHub.

OPTIONS:
    --dry-run        Affiche ce qui serait fait sans modifier le WIKI
    --help, -h       Affiche cette aide
    --list           Liste les pages disponibles
    --check          Vérifie les différences sans mettre à jour

PAGE:
    Nom d'une page spécifique à mettre à jour (ex: Home.md)

EXAMPLES:
    $0                    # Met à jour toutes les pages
    $0 --dry-run          # Aperçu des changements
    $0 Home.md            # Met à jour uniquement Home.md
    $0 --check            # Vérifie les différences
EOF
}

# Fonction de logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérifier les prérequis
check_prerequisites() {
    log_info "Vérification des prérequis..."
    
    # Vérifier gh CLI
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) n'est pas installé"
        log_info "Installez-le avec: https://cli.github.com/"
        exit 1
    fi
    
    # Vérifier l'authentification
    if ! gh auth status &> /dev/null; then
        log_error "Vous n'êtes pas authentifié avec GitHub CLI"
        log_info "Authentifiez-vous avec: gh auth login"
        exit 1
    fi
    
    # Vérifier que le WIKI est activé
    REPO_INFO=$(gh repo view --json hasWikiEnabled 2>/dev/null || echo '{"hasWikiEnabled":false}')
    if echo "$REPO_INFO" | grep -q '"hasWikiEnabled":false'; then
        log_warning "Le WIKI n'est pas activé pour ce repository"
        log_info "Activez-le dans les paramètres du repository GitHub: Settings > Features > Wikis"
    fi
    
    # Vérifier que le dossier wiki existe
    if [ ! -d "$WIKI_DIR" ]; then
        log_error "Le dossier wiki/ n'existe pas"
        exit 1
    fi
    
    log_success "Prérequis vérifiés"
}

# Lister les pages disponibles
list_pages() {
    log_info "Pages disponibles dans wiki/:"
    if [ -d "$WIKI_DIR" ]; then
        find "$WIKI_DIR" -name "*.md" -type f | sort | while read -r page; do
            basename "$page"
        done
    else
        log_error "Le dossier wiki/ n'existe pas"
        exit 1
    fi
}

# Vérifier les différences
check_differences() {
    log_info "Vérification des différences..."
    
    # Cloner le WIKI dans un dossier temporaire
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT
    
    REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
    WIKI_REPO="${REPO}.wiki"
    
    log_info "Clonage du WIKI dans $TEMP_DIR..."
    if git clone "https://github.com/${WIKI_REPO}.git" "$TEMP_DIR" 2>/dev/null; then
        log_success "WIKI cloné avec succès"
    else
        log_warning "Impossible de cloner le WIKI (peut-être vide ou non activé)"
        log_info "Toutes les pages seront créées"
        return 0
    fi
    
    # Comparer les fichiers
    DIFF_FOUND=false
    for local_page in "$WIKI_DIR"/*.md; do
        if [ -f "$local_page" ]; then
            page_name=$(basename "$local_page")
            wiki_page="$TEMP_DIR/$page_name"
            
            if [ -f "$wiki_page" ]; then
                if ! diff -q "$local_page" "$wiki_page" &> /dev/null; then
                    log_warning "Différence trouvée: $page_name"
                    DIFF_FOUND=true
                fi
            else
                log_info "Nouvelle page: $page_name"
                DIFF_FOUND=true
            fi
        fi
    done
    
    if [ "$DIFF_FOUND" = false ]; then
        log_success "Aucune différence trouvée"
    fi
}

# Cloner ou mettre à jour le dépôt WIKI
setup_wiki_repo() {
    REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
    WIKI_REPO="${REPO}.wiki"
    WIKI_CLONE_DIR=$(mktemp -d)
    
    log_info "Clonage du dépôt WIKI: ${WIKI_REPO}"
    
    if git clone "https://github.com/${WIKI_REPO}.git" "$WIKI_CLONE_DIR" 2>/dev/null; then
        log_success "WIKI cloné avec succès"
        echo "$WIKI_CLONE_DIR"
        return 0
    else
        # Le WIKI n'existe pas encore, créer un nouveau dépôt
        log_warning "Le WIKI n'existe pas encore ou est vide"
        mkdir -p "$WIKI_CLONE_DIR"
        cd "$WIKI_CLONE_DIR"
        git init
        git remote add origin "https://github.com/${WIKI_REPO}.git"
        echo "$WIKI_CLONE_DIR"
        return 0
    fi
}

# Mettre à jour une page spécifique
update_page() {
    local page_file="$1"
    local wiki_repo_dir="$2"
    local page_name=$(basename "$page_file")
    
    if [ ! -f "$page_file" ]; then
        log_error "Page non trouvée: $page_file"
        return 1
    fi
    
    log_info "Mise à jour de la page: $page_name"
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] La page $page_name serait mise à jour"
        echo "---"
        head -n 10 "$page_file"
        echo "..."
        return 0
    fi
    
    # Copier le fichier dans le dépôt WIKI
    cp "$page_file" "$wiki_repo_dir/$page_name"
    
    log_success "Page $page_name copiée"
    return 0
}

# Mettre à jour toutes les pages
update_all_pages() {
    log_info "Mise à jour de toutes les pages..."
    
    # Configurer le dépôt WIKI
    WIKI_REPO_DIR=$(setup_wiki_repo)
    if [ -z "$WIKI_REPO_DIR" ]; then
        log_error "Impossible de configurer le dépôt WIKI"
        return 1
    fi
    
    # Nettoyer le dépôt temporaire à la fin
    trap "rm -rf $WIKI_REPO_DIR" EXIT
    
    local updated=0
    local failed=0
    
    # Mettre à jour chaque page
    for page_file in "$WIKI_DIR"/*.md; do
        if [ -f "$page_file" ]; then
            if update_page "$page_file" "$WIKI_REPO_DIR"; then
                ((updated++))
            else
                ((failed++))
            fi
        fi
    done
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] $updated page(s) seraient mise(s) à jour"
        return 0
    fi
    
    # Commit et push si des changements ont été faits
    cd "$WIKI_REPO_DIR"
    
    if [ -n "$(git status --porcelain)" ]; then
        log_info "Commit des changements..."
        git add -A
        
        COMMIT_MSG="Update documentation from local wiki/ directory
        
        Mise à jour automatique via scripts/update-wiki.sh
        Date: $(date -Iseconds)"
        
        git config user.name "RepoLens Bot" || true
        git config user.email "repolens@noreply.github.com" || true
        
        if git commit -m "$COMMIT_MSG" 2>/dev/null; then
            log_success "Changements commités"
            
            # Push vers GitHub
            REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
            WIKI_REPO="${REPO}.wiki"
            
            log_info "Push vers GitHub..."
            if git push "https://github.com/${WIKI_REPO}.git" master:master 2>/dev/null || \
               git push "https://github.com/${WIKI_REPO}.git" main:main 2>/dev/null; then
                log_success "Changements poussés vers GitHub"
            else
                log_warning "Push échoué (le WIKI peut ne pas être activé ou vous n'avez pas les permissions)"
                log_info "Vous pouvez pousser manuellement depuis: $WIKI_REPO_DIR"
            fi
        else
            log_warning "Aucun changement à commiter"
        fi
    else
        log_info "Aucun changement détecté"
    fi
    
    log_info "Résumé: $updated page(s) mise(s) à jour, $failed échec(s)"
    
    if [ $failed -gt 0 ]; then
        return 1
    fi
}

# Parser les arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            --list)
                list_pages
                exit 0
                ;;
            --check)
                check_differences
                exit 0
                ;;
            *.md)
                SPECIFIC_PAGE="$1"
                shift
                ;;
            *)
                log_error "Option inconnue: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Fonction principale
main() {
    log_info "=== Synchronisation de la documentation vers le WIKI ==="
    
    parse_args "$@"
    check_prerequisites
    
    if [ "$DRY_RUN" = true ]; then
        log_warning "Mode DRY-RUN activé - aucune modification ne sera effectuée"
    fi
    
    if [ -n "$SPECIFIC_PAGE" ]; then
        # Mettre à jour une page spécifique
        if [[ "$SPECIFIC_PAGE" == *.md ]]; then
            page_file="$WIKI_DIR/$SPECIFIC_PAGE"
        else
            page_file="$WIKI_DIR/${SPECIFIC_PAGE}.md"
        fi
        
        # Configurer le dépôt WIKI
        WIKI_REPO_DIR=$(setup_wiki_repo)
        if [ -z "$WIKI_REPO_DIR" ]; then
            log_error "Impossible de configurer le dépôt WIKI"
            exit 1
        fi
        
        trap "rm -rf $WIKI_REPO_DIR" EXIT
        
        if update_page "$page_file" "$WIKI_REPO_DIR"; then
            if [ "$DRY_RUN" = false ]; then
                cd "$WIKI_REPO_DIR"
                git add -A
                if [ -n "$(git status --porcelain)" ]; then
                    git config user.name "RepoLens Bot" || true
                    git config user.email "repolens@noreply.github.com" || true
                    git commit -m "Update $(basename "$page_file") from local documentation" 2>/dev/null
                    
                    REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
                    WIKI_REPO="${REPO}.wiki"
                    git push "https://github.com/${WIKI_REPO}.git" master:master 2>/dev/null || \
                    git push "https://github.com/${WIKI_REPO}.git" main:main 2>/dev/null || true
                fi
            fi
        else
            exit 1
        fi
    else
        # Mettre à jour toutes les pages
        update_all_pages
    fi
    
    log_success "Synchronisation terminée"
}

# Exécuter le script
main "$@"
