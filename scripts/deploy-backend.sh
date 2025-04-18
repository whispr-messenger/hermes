#!/bin/bash

# Variables
VPS_IP="100.86.59.48"
VPS_USER="root"  # Remplacez par votre nom d'utilisateur sur le VPS
APP_DIR="/opt/hermes3.0"  # Répertoire de destination sur le VPS

# Créer une archive du backend
echo "Création de l'archive du backend..."
cd /Users/dalm1/Desktop/reroll/Progra/hermes3.0
tar -czf hermes-backend.tar.gz apps/backend

# Transférer l'archive vers le VPS
echo "Transfert de l'archive vers le VPS..."
scp hermes-backend.tar.gz $VPS_USER@$VPS_IP:~

# Exécuter les commandes de déploiement sur le VPS
echo "Déploiement sur le VPS..."
ssh $VPS_USER@$VPS_IP << 'EOF'
  # Créer le répertoire de l'application s'il n'existe pas
  mkdir -p /opt/hermes3.0

  # Extraire l'archive
  tar -xzf ~/hermes-backend.tar.gz -C /opt/hermes3.0

  # Installer les dépendances
  cd /opt/hermes3.0/apps/backend
  npm install --production

  # Configurer Redis si ce n'est pas déjà fait
  if ! command -v redis-server &> /dev/null; then
    apt-get update
    apt-get install -y redis-server
    systemctl enable redis-server
    systemctl start redis-server
  fi

  # Créer un service systemd pour l'application
  cat > /etc/systemd/system/hermes-backend.service << 'EOL'
[Unit]
Description=Hermes 3.0 Backend
After=network.target redis-server.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/hermes3.0/apps/backend
ExecStart=/usr/bin/npm start
Restart=on-failure
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOL

  # Recharger systemd, activer et démarrer le service
  systemctl daemon-reload
  systemctl enable hermes-backend
  systemctl start hermes-backend

  # Nettoyer
  rm ~/hermes-backend.tar.gz

  echo "Déploiement terminé !"
EOF

# Supprimer l'archive locale
rm hermes-backend.tar.gz

echo "Script de déploiement terminé !"