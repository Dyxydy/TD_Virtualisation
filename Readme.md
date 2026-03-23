Pour lancer l'environnement


docker compose --profile build run --rm webapp
2. Lancer tous les services


docker compose up -d
3. Accéder à l'app


http://localhost
Commandes utiles pour la suite :


# Voir l'état des services
docker compose ps

# Voir les logs d'un service
docker compose logs restapi
docker compose logs wsapi
docker compose logs front

# Stopper tout
docker compose down

# Stopper et supprimer les volumes (repart de zéro, BDs vidées)
docker compose down -v