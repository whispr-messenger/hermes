const express = require('express');
const { authMiddleware } = require('../middleware/auth');
const { UserService } = require('../services/user');

const router = express.Router();

// Get current user
router.get('/me', authMiddleware, async (req, res) => {
  try {
    res.json(req.user);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Get user by ID
router.get('/:userId', authMiddleware, async (req, res) => {
  try {
    const user = await UserService.getUserById(req.params.userId);
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    res.json(user);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Get contacts/users list
router.get('/', authMiddleware, async (req, res) => {
  try {
    const contacts = await UserService.getContacts(req.userId);
    res.json(contacts);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Update user status
router.put('/status', authMiddleware, async (req, res) => {
  try {
    const { status } = req.body;
    
    if (!status) {
      return res.status(400).json({ message: 'Status is required' });
    }
    
    const result = await UserService.updateUserStatus(req.userId, status);
    res.json(result);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

module.exports = router;