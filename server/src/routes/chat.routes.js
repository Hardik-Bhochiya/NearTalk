const express = require('express');
const router = express.Router();
const { getRooms, getMessages, sendMessage } = require('../controllers/chat.controller');

router.get('/rooms', getRooms);
router.get('/rooms/:roomId/messages', getMessages);
router.post('/rooms/:roomId/messages', sendMessage);

module.exports = router;
