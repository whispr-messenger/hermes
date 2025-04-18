const redisClient = require('./redis');
const bcrypt = require('bcrypt');
const { v4: uuidv4 } = require('uuid');

class UserService {
  static async createUser({ name, email, password, avatar = null }) {
    // Check if user already exists with this email
    const existingUserByEmail = await this.getUserByEmail(email);
    if (existingUserByEmail) {
      throw new Error('User with this email already exists');
    }
    
    // Check if user already exists with this username
    const existingUserByName = await this.getUserByName(name);
    if (existingUserByName) {
      throw new Error('Username already taken');
    }
    
    const userId = uuidv4();
    const hashedPassword = await bcrypt.hash(password, 10);
    
    const user = {
      id: userId,
      name,
      email,
      password: hashedPassword,
      avatar,
      status: 'online',
      createdAt: Date.now()
    };
    
    await redisClient.hset(`user:${userId}`, user);
    await redisClient.set(`user:email:${email}`, userId);
    
    // Store username reference for uniqueness check
    await redisClient.set(`user:name:${name}`, userId);
    
    // Don't return the password
    const { password: _, ...userWithoutPassword } = user;
    return userWithoutPassword;
  }
  
  static async getUserById(userId) {
    const user = await redisClient.hgetall(`user:${userId}`);
    if (!user || Object.keys(user).length === 0) return null;
    
    // Don't return the password
    const { password, ...userWithoutPassword } = user;
    return userWithoutPassword;
  }
  
  static async getUserByEmail(email) {
    const userId = await redisClient.get(`user:email:${email}`);
    if (!userId) return null;
    
    return this.getUserById(userId);
  }
  
  static async getUserByName(name) {
    const userId = await redisClient.get(`user:name:${name}`);
    if (!userId) return null;
    
    return this.getUserById(userId);
  }
  
  static async validateUser(email, password) {
    const userId = await redisClient.get(`user:email:${email}`);
    if (!userId) return null;
    
    const user = await redisClient.hgetall(`user:${userId}`);
    if (!user) return null;
    
    const isValid = await bcrypt.compare(password, user.password);
    if (!isValid) return null;
    
    // Don't return the password
    const { password: _, ...userWithoutPassword } = user;
    return userWithoutPassword;
  }
  
  static async updateUserStatus(userId, status) {
    await redisClient.hset(`user:${userId}`, 'status', status);
    return { id: userId, status };
  }
  
  static async getContacts(userId) {
    // In a real app, you'd have a contacts or friends list
    // For simplicity, we'll return all users except the current one
    const userKeys = await redisClient.keys('user:*');
    const userIds = userKeys
      .filter(key => key.startsWith('user:') && !key.startsWith('user:email:'))
      .map(key => key.split(':')[1]);
    
    const contacts = [];
    for (const id of userIds) {
      if (id !== userId) {
        const user = await this.getUserById(id);
        if (user) {
          contacts.push(user);
        }
      }
    }
    
    return contacts;
  }
}

module.exports = { UserService };