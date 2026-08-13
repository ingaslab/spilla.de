#!/bin/bash

set -euo pipefail

MODE="${1:-}"

PROJECT_DIR="$(cd "../$(dirname "$0")" && pwd)"
DIST_DIR="$PROJECT_DIR/dist"

# ------------------------------------------------------------
# Ziele anpassen
# ------------------------------------------------------------

TEST_HOST="ingasadm9.spilla.local"
TEST_USER="root"
TEST_PATH="/mnt/hgfs/10.WebDesign/spilla.de/"

PROD_HOST="DEIN-PROD-SERVER"
PROD_USER="aspilla"
PROD_PATH="/DEIN/PROD/WEBROOT/"

# ------------------------------------------------------------
# Funktionen
# ------------------------------------------------------------

usage() {
    echo "Usage:"
    echo "  $0 test"
    echo "  $0 prod"
    exit 1
}

build_test() {
    echo
    echo "========================================"
    echo " Building TEST"
    echo "========================================"
    echo

    cd "$PROJECT_DIR"

    npm run build:test
}

build_prod() {
    echo
    echo "========================================"
    echo " Building PRODUCTION"
    echo "========================================"
    echo

    cd "$PROJECT_DIR"

    npm run build:prod
}

deploy_test() {
    echo
    echo "========================================"
    echo " Deploying TEST"
    echo "========================================"
    echo

    rsync \
        -avz \
        --delete \
        --progress \
        "$DIST_DIR/" \
        "${TEST_USER}@${TEST_HOST}:${TEST_PATH}"
}

deploy_prod() {
    echo
    echo "========================================"
    echo " PRODUCTION DEPLOYMENT"
    echo "========================================"
    echo

    echo "Target:"
    echo "${PROD_USER}@${PROD_HOST}:${PROD_PATH}"
    echo

    read -r -p "Wirklich PRODUKTIV deployen? [yes/NO]: " ANSWER

    if [ "$ANSWER" != "yes" ]; then
        echo "Deployment abgebrochen."
        exit 0
    fi

    rsync \
        -avz \
        --delete \
        --progress \
        "$DIST_DIR/" \
        "${PROD_USER}@${PROD_HOST}:${PROD_PATH}"
}

# ------------------------------------------------------------
# Main
# ------------------------------------------------------------

case "$MODE" in

    test)

        build_test
        deploy_test

        echo
        echo "========================================"
        echo " TEST Deployment erfolgreich"
        echo "========================================"
        echo
        echo "https://adminserver.spilla.local/srv/spilla.de/"
        ;;

    prod)

        build_prod
        deploy_prod

        echo
        echo "========================================"
        echo " PRODUCTION Deployment erfolgreich"
        echo "========================================"
        echo
        echo "https://spilla.de/"
        ;;

    *)

        usage
        ;;

esac
