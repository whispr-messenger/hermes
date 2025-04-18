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

# Installer les dépendances globalement pour s'assurer qu'elles sont accessibles
npm install -g dotenv bcrypt ioredis express cors morgan socket.io multer jsonwebtoken uuid

# Installer toutes les dépendances localement
npm install --no-bin-links

# Créer un répertoire uploads s'il n'existe pas
mkdir -p ~/hermes/apps/backend/uploads
chmod 755 ~/hermes/apps/backend/uploads

# Vérifier que les modules critiques sont bien installés
if [ ! -d "node_modules/dotenv" ] || [ ! -d "node_modules/bcrypt" ]; then
  echo "Erreur: modules critiques non installés. Tentative d'installation spécifique..."
  npm install dotenv bcrypt --build-from-source --no-bin-links
  
  # Vérifier à nouveau
  if [ ! -d "node_modules/dotenv" ]; then
    echo "Installation manuelle de dotenv..."
    mkdir -p node_modules/dotenv
    cp -r /usr/local/lib/node_modules/dotenv/* node_modules/dotenv/
  fi
  
  if [ ! -d "node_modules/bcrypt" ]; then
    echo "Installation manuelle de bcrypt..."
    mkdir -p node_modules/bcrypt
    cp -r /usr/local/lib/node_modules/bcrypt/* node_modules/bcrypt/
  fi
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