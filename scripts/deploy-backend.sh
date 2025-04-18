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
apt-get install -y build-essential python3

# Installer les dépendances Node.js
cd ~/hermes/apps/backend
echo "Suppression du module bcrypt existant..."
rm -rf node_modules/bcrypt

echo "Installation des dépendances avec recompilation des modules natifs..."
npm install --production

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