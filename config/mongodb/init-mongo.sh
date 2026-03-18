#!/bin/bash
# =============================================================================
# Script d'initialisation MongoDB - Logistico-Train
# =============================================================================
# Ce script est exécuté AUTOMATIQUEMENT au PREMIER démarrage du conteneur
# nosqldatabase, via le mécanisme /docker-entrypoint-initdb.d/ de l'image
# officielle MongoDB (les fichiers .sh sont sourcés avant les .js).
#
# POURQUOI un script shell plutôt qu'un .js ?
#   -> Pour pouvoir lire les credentials depuis les fichiers secrets Docker
#      (/run/secrets/) avec la commande `cat`, ce que mongosh ne permet pas
#      nativement sans Node.js complet.
#
# A ce stade de l'initialisation, l'image MongoDB a déjà :
#   1. Lu MONGO_INITDB_ROOT_USERNAME_FILE et MONGO_INITDB_ROOT_PASSWORD_FILE
#   2. Exporté MONGO_INITDB_ROOT_USERNAME et MONGO_INITDB_ROOT_PASSWORD en vars
#   3. Créé l'utilisateur root dans la BD "admin"
# =============================================================================

set -e  # Arrêt immédiat si une commande échoue

echo "[init-mongo] Lecture des credentials applicatifs depuis les secrets Docker..."

# Lecture des credentials de l'utilisateur applicatif depuis les fichiers secrets.
# Les secrets Docker sont montés en lecture seule dans /run/secrets/ par le daemon.
APP_USER=$(cat /run/secrets/mongo_app_user | tr -d '[:space:]')
APP_PASSWORD=$(cat /run/secrets/mongo_app_password | tr -d '[:space:]')

echo "[init-mongo] Création de l'utilisateur applicatif '$APP_USER' dans 'history-db'..."

# On se connecte en tant que root (credentials disponibles via les vars d'env
# exportées par l'entrypoint de l'image) pour créer l'utilisateur applicatif.
#
# La base "history-db" est la base d'historique orientée document du CDC.
# L'utilisateur reçoit uniquement les droits readWrite sur cette base
# (principe du moindre privilège).
mongosh \
    --authenticationDatabase admin \
    --username  "$MONGO_INITDB_ROOT_USERNAME" \
    --password  "$MONGO_INITDB_ROOT_PASSWORD" \
    --eval "
        db = db.getSiblingDB('history-db');

        // Vérifie si l'utilisateur existe déjà (idempotence au cas où le script
        // serait rejoué manuellement, bien que l'initdb ne le fasse qu'une fois).
        const existingUser = db.getUser('$APP_USER');
        if (existingUser) {
            print('[init-mongo] Utilisateur déjà existant, aucune action.');
        } else {
            db.createUser({
                user: '$APP_USER',
                pwd:  '$APP_PASSWORD',
                roles: [
                    // readWrite sur history-db : l'API peut lire et écrire
                    // les documents d'historique des actions sur les rames.
                    { role: 'readWrite', db: 'history-db' }
                ]
            });
            print('[init-mongo] Utilisateur créé avec succès.');
        }
    "

echo "[init-mongo] Initialisation MongoDB terminée."
