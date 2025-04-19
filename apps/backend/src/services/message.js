const redisClient = require('./redis');
const { v4: uuidv4 } = require('uuid');

class MessageService {
  static async createMessage({ senderId, recipientId, content, files }) {
    try {
      const message = {
        id: uuidv4(),
        senderId,
        recipientId,
        content,
        files: files || [],
        timestamp: Date.now()
      };

      // Store message in Redis
      await redisClient.lpush(`messages:${senderId}:${recipientId}`, JSON.stringify(message));
      await redisClient.lpush(`messages:${recipientId}:${senderId}`, JSON.stringify(message));
      
      // Publish message to Redis pub/sub
      await redisClient.publish('new_message', JSON.stringify(message));
      
      return message;
    } catch (error) {
      throw new Error('Error creating message: ' + error.message);
    }
  }

  static async getConversationMessages(senderId, recipientId) {
    try {
      const messages = await redisClient.lrange(`messages:${senderId}:${recipientId}`, 0, -1);
      return messages.map(JSON.parse);
    } catch (error) {
      throw new Error('Error fetching messages: ' + error.message);
    }
  }

  static async markMessagesAsRead(senderId, recipientId) {
    try {
      // Implementation for read receipts would go here
      return { status: 'success' };
    } catch (error) {
      throw new Error('Error marking messages as read: ' + error.message);
    }
  }
}

module.exports = { MessageService };