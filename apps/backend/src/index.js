require('dotenv').config();
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
    // Ajoutez d'autres origines si nécessaire
  ],
  credentials: true
}));
app.use(express.json());
app.use(morgan('dev'));

// Configuration pour le stockage des fichiers
// Suppression des imports dupliqués
// const multer = require('multer');
// const path = require('path');
// const fs = require('fs');

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
// Mise à jour de la configuration CORS pour accepter les requêtes de votre IP locale
app.use(cors({
  origin: [
    'http://localhost:3000',
    'http://192.168.1.22:3000',
    // Ajoutez d'autres origines si nécessaire
  ],
  credentials: true
}));

// Socket.io configuration
const io = new Server(server, {
  cors: {
    origin: [
      'http://localhost:3000',
      'http://192.168.1.22:3000',
      // Ajoutez d'autres origines si nécessaire
    ],
    methods: ["GET", "POST"],
    credentials: true
  }
});

// Maintenant vous pouvez utiliser io
io.use(socketAuthMiddleware);

io.on('connection', (socket) => {
  console.log(`User connected: ${socket.userId}`);
  
  // Join user's personal room
  socket.join(`user:${socket.userId}`);
  
  socket.on('join_chat', (chatId) => {
    socket.join(`chat:${chatId}`);
    console.log(`User ${socket.userId} joined chat ${chatId}`);
  });
  
  socket.on('leave_chat', (chatId) => {
    socket.leave(`chat:${chatId}`);
    console.log(`User ${socket.userId} left chat ${chatId}`);
  });
  
  socket.on('new_message', async (messageData) => {
    try {
      const { MessageService } = require('./services/message');
      
      // Assurez-vous que les fichiers sont correctement formatés
      let processedFiles = [];
      if (messageData.files && Array.isArray(messageData.files)) {
        processedFiles = messageData.files.map(file => ({
          name: file.name || 'unknown',
          size: file.size || 0,
          type: file.type || 'application/octet-stream',
          url: file.url || ''
        }));
      }
      
      const message = await MessageService.createMessage({
        senderId: socket.userId,
        recipientId: messageData.recipientId,
        content: messageData.content,
        files: processedFiles
      });
      
      // Emit to recipient and sender
      io.to(`user:${message.recipientId}`).emit('receive_message', message);
      socket.emit('message_sent', message);
    } catch (error) {
      console.error('Error sending message:', error);
      socket.emit('message_error', { error: error.message });
    }
  });
  
  socket.on('disconnect', () => {
    console.log(`User disconnected: ${socket.userId}`);
  });
});

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});