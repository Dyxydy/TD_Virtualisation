# BASE SERVER CONFIGURATION
SERVER_HOST = '0.0.0.0'
SERVER_PORT = 5001
DEBUG = False
ENABLE_CORS = True

# SQL PRODUCTION DB CONNECTION CONFIGURATION
SQLDB_SETTINGS = {
    "db": 'myrames-prod-db',
    "user": 'mariaUsr',
    "password": 'mariaPwd',
    "host": 'sqldatabase',
    "port": 3306
}

# MONGODB HISTORY DB CONNECTION CONFIGURATION
MONGODB_SETTINGS = {
    "db": "history-db",
    "host": "nosqldatabase",
    "port": 27017,
    "username": "mongoRoot",
    "password": "mongoPwdRoot",
    "authentication_source": "admin"
}
