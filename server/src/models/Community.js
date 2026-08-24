const mongoose = require('mongoose');

const communitySchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String, required: true },
  regionId: { type: String, default: 'region-ddu' },
  regionName: { type: String, default: 'DDU, Nadiad, Gujarat' },
  category: { type: String, default: 'Campus' },
  memberCount: { type: Number, default: 1 },
  questionCount: { type: Number, default: 0 },
  iconEmoji: { type: String, default: '🎓' },
  bannerColorHex: { type: Number, default: 0xFF6366F1 },
  rules: [{ type: String }],
  members: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
}, { timestamps: true });

module.exports = mongoose.model('Community', communitySchema);
