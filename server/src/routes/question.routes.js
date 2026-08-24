const express = require('express');
const router = express.Router();
const {
  getQuestions,
  getQuestionById,
  createQuestion,
  toggleUpvote,
  toggleBookmark,
  addReply,
} = require('../controllers/question.controller');

router.get('/', getQuestions);
router.get('/:id', getQuestionById);
router.post('/', createQuestion);
router.post('/:id/upvote', toggleUpvote);
router.post('/:id/bookmark', toggleBookmark);
router.post('/:id/replies', addReply);

module.exports = router;
