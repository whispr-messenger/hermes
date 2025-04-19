const express = require('express');
const { authMiddleware } = require('../middleware/auth');
// Correction de l'import
const { MessageService } = require('../services/message'); // <- Remove the extra .js extension

const router = express.Router();

// Get messages between current user and another user
router.get('/:userId', authMiddleware, async (req, res) => {
  try {
    const currentUserId = req.userId;
    const otherUserId = req.params.userId;
    
    const messages = await MessageService.getConversationMessages(
      currentUserId, 
      otherUserId
    );
    
    // Mark messages as read
    await MessageService.markMessagesAsRead(currentUserId, otherUserId);
    
    res.json(messages);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Send a message
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { recipientId, content, files } = req.body;
    
    if (!recipientId || (!content && (!files || files.length === 0))) {
      return res.status(400).json({ message: 'Recipient and content/files are required' });
    }
    
    const message = await MessageService.createMessage({
      senderId: req.userId,
      recipientId,
      content,
      files
    });
    
    res.status(201).json(message);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

module.exports = router;