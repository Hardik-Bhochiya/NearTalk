const store = require('../controllers/store');
const { v4: uuidv4 } = require('uuid');

const registerChatSocket = (io) => {
  const chatNamespace = io.of('/chat');

  chatNamespace.on('connection', (socket) => {
    console.log(`[Socket.IO] Client connected: ${socket.id}`);

    socket.on('join_room', ({ roomId, userName }) => {
      socket.join(roomId);
      console.log(`[Socket.IO] User ${userName || 'Anonymous'} joined room: ${roomId}`);
      socket.to(roomId).emit('user_joined', {
        roomId,
        userName: userName || 'Anonymous',
        timestamp: new Date().toISOString(),
      });
    });

    socket.on('leave_room', ({ roomId, userName }) => {
      socket.leave(roomId);
      socket.to(roomId).emit('user_left', {
        roomId,
        userName: userName || 'Anonymous',
        timestamp: new Date().toISOString(),
      });
    });

    socket.on('send_message', ({ roomId, content, senderId, senderName, isAnonymous }) => {
      const newMessage = {
        id: uuidv4(),
        roomId,
        senderId: senderId || 'user-hardik',
        senderName: isAnonymous ? 'Anonymous' : senderName || 'Hardik',
        content,
        isAnonymous: Boolean(isAnonymous),
        timestamp: new Date().toISOString(),
      };

      if (!store.messages[roomId]) store.messages[roomId] = [];
      store.messages[roomId].push(newMessage);

      const room = store.rooms.find((r) => r.id === roomId);
      if (room) {
        room.lastMessage = content;
        room.lastMessageTime = newMessage.timestamp;
      }

      // Broadcast to room
      chatNamespace.to(roomId).emit('receive_message', newMessage);
    });

    socket.on('typing_start', ({ roomId, userName }) => {
      socket.to(roomId).emit('user_typing', {
        roomId,
        userName: userName || 'Someone',
        isTyping: true,
      });
    });

    socket.on('typing_stop', ({ roomId, userName }) => {
      socket.to(roomId).emit('user_typing', {
        roomId,
        userName: userName || 'Someone',
        isTyping: false,
      });
    });

    socket.on('disconnect', () => {
      console.log(`[Socket.IO] Client disconnected: ${socket.id}`);
    });
  });
};

module.exports = registerChatSocket;
