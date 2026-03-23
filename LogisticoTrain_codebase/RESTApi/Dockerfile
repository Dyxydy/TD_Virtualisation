# =============================================================================
# Dockerfile — RESTApi (Python Flask)
# =============================================================================
#
# Un Dockerfile est une recette pour construire une image Docker.
# Il est exécuté une seule fois par "docker build". Le résultat est une image
# réutilisable qui embarque le code et toutes ses dépendances.
#
# INSTRUCTIONS UTILISÉES :
#
#  FROM    : image de base depuis Docker Hub. Tout ce qui suit s'y appuie.
#  RUN     : exécute une commande shell lors du BUILD (pas au runtime du
#            conteneur). Chaque RUN crée une "couche" dans l'image — on
#            chaîne les commandes avec && pour réduire le nombre de couches.
#  WORKDIR : définit le répertoire de travail courant pour les instructions
#            suivantes (comme un `cd` persistant dans l'image).
#  COPY    : copie des fichiers depuis l'hôte vers l'image en cours de build.
#  EXPOSE  : documente le port écouté par le conteneur (informatif uniquement,
#            ne publie pas le port — c'est docker compose qui s'en charge).
#  CMD     : commande lancée lorsque le conteneur démarre.
# =============================================================================

# Image de base Python 3.11 "slim" : Debian minimal avec Python, sans outils
# inutiles. Réduit la taille de l'image et la surface d'attaque.
FROM python:3.11-slim

# Installe les dépendances système nécessaires à la compilation de mysqlclient
# (le connecteur Python/MariaDB). Le cache apt est supprimé ensuite pour ne
# pas alourdir l'image finale.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        default-libmysqlclient-dev \
        gcc \
        pkg-config \
 && rm -rf /var/lib/apt/lists/*

# Tous les COPY, RUN et CMD suivants opèrent depuis /app dans le conteneur.
WORKDIR /app

# On copie requirements.txt AVANT le code source. Avantage : Docker met cette
# couche en cache. Si le code change mais pas requirements.txt, Docker réutilise
# le cache de pip install → rebuild beaucoup plus rapide.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copie tout le code source de RESTApi/ dans /app du conteneur.
COPY . .

# Précompile tous les fichiers .py en bytecode .pyc.
# Avantage : démarrage plus rapide et exécution légèrement plus performante.
RUN python -m compileall -b .

# Port d'écoute du serveur Flask (défini dans config.py).
EXPOSE 5001

# Lance le serveur Flask via le script de démarrage au lancement du conteneur.
CMD ["sh", "start-server.sh"]
