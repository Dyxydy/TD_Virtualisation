================================================================

set -e  # Arrêt immédiat si une commande échoue

echo "[init-mongo] Lecture des credentials applicatifs depuis les secrets Docker..."

# Lecture des credentials de l'utilisateur applicatif depuis les fichiers secrets.
# Les secrets Docker sont montés en lecture seule dans /run/secrets/ par le daemon.
APP_USER=$(cat /run/secrets/mongo_app_user | tr -d '[:space:]')
APP_PASSWORD=$(cat /run/secrets/mongo_app_password | tr -d '[:space:]')

echo "[init-mongo] Création de l'utilisateur applicatif '$APP_USER' dans 'history-db'..."


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
