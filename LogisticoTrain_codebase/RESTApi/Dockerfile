# =============================================================================
# Dockerfile - RESTApi (Python Flask) - Logistico-Train
# =============================================================================
# STRATÉGIE (CDC - Objectif performance) :
#   "Le composant RESTApi n'a pas de roadmap de développement à court terme et
#    sa base de code est considérée stable : il vous est conseillé de faire une
#    image embarquant directement le code source applicatif et si possible ses
#    fichiers python précompilés."
#
#   → Image CUSTOM avec code source et .pyc précompilés intégrés.
#   → Pas de montage de volume source : l'image est autonome.
#   → mysqlclient nécessite les headers C de libmariadb (compilation native).
# =============================================================================

# Python 3.11 slim : image minimale Debian, sans l'overhead de la version full.
# Satisfait la contrainte "Python ≥ 3.11" du CDC.
FROM python:3.11-slim

# ---- Dépendances système ----
# mysqlclient (pip) est un binding C vers la librairie MariaDB/MySQL.
# Il nécessite à la compilation :
#   - default-libmysqlclient-dev : headers C de MariaDB/MySQL
#   - gcc                        : compilateur C pour le binding
#   - pkg-config                 : utilisé par le setup.py de mysqlclient
# On supprime les listes apt après install pour minimiser la taille de l'image.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        default-libmysqlclient-dev \
        gcc \
        pkg-config \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ---- Installation des dépendances Python ----
# On copie requirements.txt AVANT le code source pour exploiter le cache Docker :
# si requirements.txt ne change pas, cette couche n'est pas recalculée.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ---- Copie du code source applicatif ----
COPY . .

# ---- Pré-compilation Python (performance) ----
# `python -m compileall -b .` génère un fichier .pyc à côté de chaque .py
# (flag -b = byte-code dans le même répertoire que la source).
# Au démarrage, Python charge directement les .pyc → pas de compilation JIT
# → temps de démarrage et premières requêtes plus rapides.
RUN python -m compileall -b .

# Port d'écoute de la Flask app (défini dans config.py via SERVER_PORT=5001)
EXPOSE 5001

# ---- Démarrage ----
# Le script start-server.sh lance : python -m MyRamesServer
# Le fichier config.py de PRODUCTION est monté en tant que secret Docker
# sur /app/config.py (écrase ce fichier au runtime), injecté par docker-compose.
CMD ["sh", "start-server.sh"]
