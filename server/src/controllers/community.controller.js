const store = require('./store');
const Community = require('../models/Community');
const { isConnected } = require('../config/db');

exports.getCommunities = async (req, res) => {
  try {
    if (isConnected()) {
      const communities = await Community.find();
      return res.json({ success: true, count: communities.length, data: communities });
    } else {
      return res.json({ success: true, count: store.communities.length, data: store.communities });
    }
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};

exports.getCommunityById = async (req, res) => {
  try {
    const { id } = req.params;
    if (isConnected()) {
      const community = await Community.findById(id);
      if (!community) return res.status(404).json({ success: false, message: 'Community not found' });
      return res.json({ success: true, data: community });
    } else {
      const community = store.communities.find((c) => c.id === id);
      if (!community) return res.status(404).json({ success: false, message: 'Community not found' });
      return res.json({ success: true, data: community });
    }
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};

exports.toggleJoin = async (req, res) => {
  try {
    const { id } = req.params;
    const community = store.communities.find((c) => c.id === id);
    if (!community) return res.status(404).json({ success: false, message: 'Community not found' });

    community.isJoined = !community.isJoined;
    community.memberCount = community.isJoined ? community.memberCount + 1 : community.memberCount - 1;

    return res.json({ success: true, data: community });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};
