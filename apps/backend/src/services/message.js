const redisClient = require('./redis');
const { v4: uuidv4 } = require('uuid');

class MessageService {
  static async createMessage({ senderId, recipientId, content, files = [] }) {
    // Générer un ID vraiment unique en combinant UUID avec timestamp
    const messageId = `${uuidv4()}-${Date.now()}`;
    const timestamp = Date.now();
    
    // Assurez-vous que les fichiers sont correctement formatés
    const processedFiles = files.map(file => ({
      name: file.name || 'unknown',
      size: file.size || 0,
      type: file.type || 'application/octet-stream',
      url: file.url || ''
    }));
    
    const message = {
      id: messageId,
      senderId,
      recipientId,
      content,
      files: processedFiles,
      timestamp,
      read: false
    };
    
    // Stocker le message dans Redis - utiliser le même objet mais avec des clés différentes
    await redisClient.rpush(`messages:${senderId}:${recipientId}`, JSON.stringify(message));
    await redisClient.rpush(`messages:${recipientId}:${senderId}`, JSON.stringify(message));
    
    return message;
  }
  
  static async getConversationMessages(userId1, userId2) {
    const messages = await redisClient.lrange(`messages:${userId1}:${userId2}`, 0, -1);
    
    // Créer un Set pour suivre les IDs déjà vus
    const seenIds = new Set();
    const uniqueMessages = [];
    
    // Filtrer les messages dupliqués
    for (const msgStr of messages) {
      const msg = JSON.parse(msgStr);
      if (!seenIds.has(msg.id)) {
        seenIds.add(msg.id);
        uniqueMessages.push(msg);
      }
    }
    
    // Trier les messages par timestamp
    return uniqueMessages.sort((a, b) => a.timestamp - b.timestamp);
  }
  
  static async markMessagesAsRead(senderId, recipientId) {
    const messages = await this.getConversationMessages(recipientId, senderId);
    
    // Marquer les messages comme lus
    const updatedMessages = messages.map(msg => {
      if (msg.senderId === senderId && !msg.read) {
        return { ...msg, read: true };
      }
      return msg;
    });
    
    // Supprimer les anciens messages
    await redisClient.del(`messages:${recipientId}:${senderId}`);
    
    // Stocker les messages mis à jour
    for (const msg of updatedMessages) {
      await redisClient.rpush(`messages:${recipientId}:${senderId}`, JSON.stringify(msg));
    }
    
    return updatedMessages.filter(msg => msg.senderId === senderId && msg.read);
  }
}

module.exports = { MessageService };