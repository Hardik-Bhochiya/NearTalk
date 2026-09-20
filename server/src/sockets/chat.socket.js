const store = require('../controllers/store');
const { v4: uuidv4 } = require('uuid');

const registerChatSocket = (io) => {
  const chatNamespace = io.of('/chat');

  chatNamespace.on('connection', (socket) => {
    console.log(`[Socket.IO] Client connected: ${socket.id}`);

    // Join personal user notification channel
    socket.on('join_user', ({ userId, username }) => {
      if (userId) socket.join(`user-${userId}`);
      if (username) socket.join(`user-${username.toLowerCase()}`);
      console.log(`[Socket.IO] Joined user channel: ${userId || username}`);
    });

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
        status: 'seen',
        likes: [],
        dislikes: [],
        isEdited: false,
        isDeleted: false,
        deletedForUserIds: [],
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

      // If DM, also broadcast to participant user channels
      if (roomId.startsWith('dm-')) {
        const parts = roomId.replace('dm-', '').split('_');
        for (const userHandle of parts) {
          chatNamespace.to(`user-${userHandle.toLowerCase()}`).emit('receive_message', newMessage);
        }
      }
    });

    socket.on('edit_message', ({ roomId, messageId, newContent }) => {
      const roomMsgs = store.messages[roomId];
      if (roomMsgs) {
        const msg = roomMsgs.find((m) => m.id === messageId);
        if (msg) {
          msg.content = newContent;
          msg.isEdited = true;
        }
      }
      chatNamespace.to(roomId).emit('message_edited', { roomId, messageId, newContent });
    });

    socket.on('delete_message', ({ roomId, messageId, forEveryone }) => {
      const roomMsgs = store.messages[roomId];
      if (roomMsgs) {
        const msg = roomMsgs.find((m) => m.id === messageId);
        if (msg) {
          msg.isDeleted = true;
          msg.content = '🚫 This message was deleted';
        }
      }
      chatNamespace.to(roomId).emit('message_deleted', { roomId, messageId, forEveryone });
    });

    socket.on('like_message', ({ roomId, messageId, userId }) => {
      chatNamespace.to(roomId).emit('message_liked', { roomId, messageId, userId });
    });

    socket.on('dislike_message', ({ roomId, messageId, userId }) => {
      chatNamespace.to(roomId).emit('message_disliked', { roomId, messageId, userId });
    });

    socket.on('mark_seen', ({ roomId, messageId }) => {
      chatNamespace.to(roomId).emit('message_seen', { roomId, messageId });
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

    socket.on('send_friend_request', (data) => {
      const { receiverUsername } = data;
      if (receiverUsername) {
        const rChannel = `user-${receiverUsername.toLowerCase().replaceAll('@', '')}`;
        chatNamespace.to(rChannel).emit('friend_request_received', data);
        console.log(`[Socket.IO] Broadcasted friend request to ${rChannel}`);
      }
    });

    socket.on('respond_friend_request', (data) => {
      const { senderUsername, status } = data;
      if (senderUsername && status === 'accepted') {
        const sChannel = `user-${senderUsername.toLowerCase().replaceAll('@', '')}`;
        chatNamespace.to(sChannel).emit('friend_request_accepted', data);
        console.log(`[Socket.IO] Broadcasted friend request accepted to ${sChannel}`);
      }
    });

    socket.on('disconnect', () => {
      console.log(`[Socket.IO] Client disconnected: ${socket.id}`);
    });
  });
};

module.exports = registerChatSocket;
