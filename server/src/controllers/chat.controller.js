const { v4: uuidv4 } = require('uuid');
const store = require('./store');

exports.getRooms = async (req, res) => {
  try {
    return res.json({ success: true, count: store.rooms.length, data: store.rooms });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};

exports.getMessages = async (req, res) => {
  try {
    const { roomId } = req.params;
    const messages = store.messages[roomId] || [];
    return res.json({ success: true, count: messages.length, data: messages });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};

exports.sendMessage = async (req, res) => {
  try {
    const { roomId } = req.params;
    const { content, senderId, senderName, isAnonymous } = req.body;

    if (!content) {
      return res.status(400).json({ success: false, message: 'Message content is required' });
    }

    const newMessage = {
      id: uuidv4(),
      roomId,
      senderId: senderId || 'user-hardik',
      senderName: isAnonymous ? 'Anonymous' : senderName || 'Hardik',
      content,
      isAnonymous: Boolean(isAnonymous),
      timestamp: new Date().toISOString(),
      isMine: false,
    };

    if (!store.messages[roomId]) store.messages[roomId] = [];
    store.messages[roomId].push(newMessage);

    // Update room last message
    const room = store.rooms.find((r) => r.id === roomId);
    if (room) {
      room.lastMessage = content;
      room.lastMessageTime = newMessage.timestamp;
    }

    return res.status(201).json({ success: true, data: newMessage });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};
