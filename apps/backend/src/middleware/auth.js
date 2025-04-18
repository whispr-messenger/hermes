const jwt = require('jsonwebtoken');
const { UserService } = require('../services/user');

const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret';

const authMiddleware = async (req, res, next) => {
  try {
    // Ajouter un log pour voir les requêtes entrantes
    console.log('Requête entrante:', req.method, req.path);
    console.log('Headers:', JSON.stringify(req.headers));
    
    // Replace optional chaining with a more compatible approach
    const authHeader = req.headers.authorization;
    const token = authHeader ? authHeader.split(' ')[1] : null;
    
    if (!token) {
      console.log('Authentification échouée: Token manquant');
      return res.status(401).json({ message: 'Authentication required' });
    }
    
    const decoded = jwt.verify(token, JWT_SECRET);
    console.log('Token décodé:', decoded);
    
    const user = await UserService.getUserById(decoded.userId);
    
    if (!user) {
      console.log('Utilisateur non trouvé:', decoded.userId);
      return res.status(401).json({ message: 'User not found' });
    }
    
    console.log('Utilisateur authentifié:', user.name || user.email);
    req.userId = decoded.userId;
    req.user = user;
    next();
  } catch (error) {
    console.error('Erreur d\'authentification:', error.message);
    return res.status(401).json({ message: 'Invalid token' });
  }
};

const socketAuthMiddleware = (socket, next) => {
  const token = socket.handshake.auth.token;
  
  if (!token) {
    return next(new Error('Authentication required'));
  }
  
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    socket.userId = decoded.userId;
    next();
  } catch (error) {
    next(new Error('Invalid token'));
  }
};

module.exports = { authMiddleware, socketAuthMiddleware };