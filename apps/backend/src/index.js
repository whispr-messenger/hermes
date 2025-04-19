// Ajouter au début du fichier
console.log('Starting application...');
console.log('Loading environment variables...');
require('dotenv').config();
console.log('Environment loaded. PORT:', process.env.PORT);
const express = require('express');
const http = require('http');
const cors = require('cors');
const morgan = require('morgan');
const { Server } = require('socket.io');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const authRoutes = require('./routes/auth');
const messageRoutes = require('./routes/messages');
const userRoutes = require('./routes/users');
const { socketAuthMiddleware, authMiddleware } = require('./middleware/auth');

const app = express();
const server = http.createServer(app);

// Mise à jour de la configuration CORS pour accepter les requêtes de votre IP locale
app.use(cors({
  origin: [
    'http://localhost:3000',
    'http://192.168.1.22:3000',
    'http://100.86.59.48:3000'  // Ajouter l'IP Tailscale
  ],
  credentials: true
}));
app.use(express.json());
app.use(morgan('dev'));

// Configuration pour le stockage des fichiers

const uploadsDir = path.join(__dirname, '../uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Configuration de Multer pour le téléchargement de fichiers
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadsDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, file.fieldname + '-' + uniqueSuffix + ext);
  }
});

const upload = multer({ storage: storage });

// Servir les fichiers statiques
app.use('/uploads', express.static(uploadsDir));

// Route pour télécharger des fichiers - essayez les deux routes
app.post('/upload', authMiddleware, upload.single('file'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No file uploaded' });
    }

    const fileUrl = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;

    res.json({
      url: fileUrl,
      name: req.file.originalname,
      size: req.file.size,
      type: req.file.mimetype
    });
  } catch (error) {
    console.error('Error uploading file:', error);
    res.status(500).json({ message: 'Error uploading file' });
  }
});

app.post('/api/upload', authMiddleware, upload.single('file'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No file uploaded' });
    }

    const fileUrl = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;

    res.json({
      url: fileUrl,
      name: req.file.originalname,
      size: req.file.size,
      type: req.file.mimetype
    });
  } catch (error) {
    console.error('Error uploading file:', error);
    res.status(500).json({ message: 'Error uploading file' });
  }
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/messages', messageRoutes);
app.use('/api/users', userRoutes);

// Socket.io - CORRECTION: Définir io avant de l'utiliser
const io = new Server(server, {
  cors: {
    origin: [
      'http://localhost:3000',
      'http://192.168.1.22:3000',
      'http://100.86.59.48:3000'  // Ajouter l'IP Tailscale
    ],
    methods: ["GET", "POST"],
    credentials: true
  }
});

// In the server startup section:
server.listen(process.env.PORT || 5001, '0.0.0.0', () => {
  console.log(`Server running on port ${process.env.PORT || 5001}`);
});
