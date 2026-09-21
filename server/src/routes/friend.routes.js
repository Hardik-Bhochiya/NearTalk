const express = require('express');
const router = express.Router();
const friendController = require('../controllers/friend.controller');

router.post('/request', friendController.sendFriendRequest);
router.post('/respond', friendController.respondFriendRequest);
router.post('/cancel', friendController.cancelFriendRequest);
router.get('/requests/:username', friendController.getFriendRequests);
router.get('/list/:username', friendController.getFriends);

module.exports = router;

