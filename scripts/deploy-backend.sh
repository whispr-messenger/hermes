#!/bin/bash

# Variables
VPS_IP="100.86.59.48"
APP_DIR="/opt/hermes3.0"  # Répertoire de destination sur le VPS

# Créer une archive du backend
echo "Création de l'archive du backend..."
cd ~/hermes
tar -czf hermes-backend.tar.gz apps/backend

# Configurer le service sur la machine locale
echo "Configuration du service..."

# Installer les dépendances de compilation
echo "Installation des dépendances de compilation..."
apt-get update
apt-get install -y build-essential python3 make g++

# Installer les dépendances Node.js
cd ~/hermes/apps/backend
echo "Nettoyage des modules node..."
rm -rf node_modules
rm -f package-lock.json

echo "Installation des dépendances avec recompilation des modules natifs..."
# Vérifier la version de npm et node
echo "Node version: $(node -v)"
echo "NPM version: $(npm -v)"

# Mettre à jour npm pour éviter les problèmes d'installation
npm install -g npm@latest

# Installer toutes les dépendances localement sans utiliser le cache
npm cache clean --force

# Installer les modules un par un avec --no-bin-links et --no-optional
echo "Installation des modules individuellement..."
npm install express --no-bin-links --no-optional
npm install dotenv --no-bin-links --no-optional
npm install bcrypt --no-bin-links --no-optional --build-from-source
npm install ioredis --no-bin-links --no-optional
npm install cors --no-bin-links --no-optional
npm install morgan --no-bin-links --no-optional
npm install socket.io --no-bin-links --no-optional
npm install multer --no-bin-links --no-optional
npm install jsonwebtoken --no-bin-links --no-optional
npm install uuid --no-bin-links --no-optional
npm install http --no-bin-links --no-optional
npm install path --no-bin-links --no-optional
npm install fs --no-bin-links --no-optional

# Vérifier si les modules critiques sont correctement installés
if [ ! -d "node_modules/express" ]; then
  echo "ERREUR CRITIQUE: Impossible d'installer express"
  echo "Tentative d'installation globale..."
  npm install -g express
  mkdir -p node_modules/express
  cp -r $(npm root -g)/express/* node_modules/express/
fi

# Créer un répertoire uploads s'il n'existe pas
mkdir -p ~/hermes/apps/backend/uploads
chmod 755 ~/hermes/apps/backend/uploads

# Vérifier que le fichier .env existe
if [ ! -f ".env" ]; then
  echo "Création du fichier .env..."
  cat > .env << EOL
PORT=5001
FRONTEND_URL=http://192.168.1.22:3000
JWT_SECRET=your_super_secret_jwt_key
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0
EOL
fi

# Configurer Redis si ce n'est pas déjà fait
if ! command -v redis-server &> /dev/null; then
  apt-get update
  apt-get install -y redis-server
  systemctl enable redis-server
  systemctl start redis-server
fi

# Trouver le chemin exact de node et npm
NODE_PATH=$(which node)
NPM_PATH=$(which npm)
echo "Using node from: $NODE_PATH"
echo "Using npm from: $NPM_PATH"

# Créer un service systemd pour l'application
cat > /etc/systemd/system/hermes-backend.service << EOL
[Unit]
Description=Hermes 3.0 Backend
After=network.target redis-server.service

[Service]
Type=simple
User=root
WorkingDirectory=/root/hermes/apps/backend
ExecStart=${NODE_PATH} /root/hermes/apps/backend/src/index.js
Restart=on-failure
Environment=NODE_ENV=production
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/lib/node_modules
Environment=NODE_PATH=/root/hermes/apps/backend/node_modules:/usr/local/lib/node_modules

[Install]
WantedBy=multi-user.target
EOL

# Recharger systemd, activer et démarrer le service
systemctl daemon-reload
systemctl enable hermes-backend
systemctl restart hermes-backend

# Vérifier le statut du service
echo "Checking service status..."
systemctl status hermes-backend --no-pager

# Nettoyer
cd ~/hermes
rm -f hermes-backend.tar.gz

echo "Déploiement terminé !"