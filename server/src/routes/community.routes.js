const express = require('express');
const router = express.Router();
const { getCommunities, getCommunityById, toggleJoin } = require('../controllers/community.controller');

router.get('/', getCommunities);
router.get('/:id', getCommunityById);
router.post('/:id/join', toggleJoin);

module.exports = router;
