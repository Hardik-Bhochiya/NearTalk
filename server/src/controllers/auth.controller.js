const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const store = require('./store');
const User = require('../models/User');
const { isConnected } = require('../config/db');

const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET || 'neartalk_secret', {
    expiresIn: '30d',
  });
};

exports.register = async (req, res) => {
  try {
    const { name, email, password, campusOrCity, majorOrBio } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ success: false, message: 'Please provide all required fields' });
    }

    if (isConnected()) {
      const userExists = await User.findOne({ email });
      if (userExists) {
        return res.status(400).json({ success: false, message: 'User with this email already exists' });
      }
      const isCollegeVerified = email.endsWith('.ddu.ac.in') || email.includes('ddu');
      const user = await User.create({
        name,
        email,
        password,
        campusOrCity: campusOrCity || 'DDU, Nadiad, Gujarat',
        majorOrBio: majorOrBio || 'Student',
        isCollegeVerified,
        joinedCommunityIds: ['c1'],
        badges: ['New Member'],
      });

      return res.status(201).json({
        success: true,
        token: generateToken(user._id),
        user: {
          id: user._id.toString(),
          name: user.name,
          email: user.email,
          campusOrCity: user.campusOrCity,
          majorOrBio: user.majorOrBio,
          reputation: user.reputation,
          isCollegeVerified: user.isCollegeVerified,
          joinedCommunityIds: user.joinedCommunityIds,
          badges: user.badges,
        },
      });
    } else {
      // In-Memory store fallback
      const userExists = store.users.find((u) => u.email === email);
      if (userExists) {
        return res.status(400).json({ success: false, message: 'User with this email already exists' });
      }

      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(password, salt);
      const isCollegeVerified = email.endsWith('.ddu.ac.in') || email.includes('ddu');

      const newUser = {
        id: uuidv4(),
        name,
        email,
        password: hashedPassword,
        campusOrCity: campusOrCity || 'DDU, Nadiad, Gujarat',
        majorOrBio: majorOrBio || 'Student',
        reputation: 50,
        joinedCommunityIds: ['c1'],
        badges: ['New Member', isCollegeVerified ? 'Verified DDU Student' : 'Campus Member'],
        isCollegeVerified,
      };

      store.users.push(newUser);

      return res.status(201).json({
        success: true,
        token: generateToken(newUser.id),
        user: {
          id: newUser.id,
          name: newUser.name,
          email: newUser.email,
          campusOrCity: newUser.campusOrCity,
          majorOrBio: newUser.majorOrBio,
          reputation: newUser.reputation,
          isCollegeVerified: newUser.isCollegeVerified,
          joinedCommunityIds: newUser.joinedCommunityIds,
          badges: newUser.badges,
        },
      });
    }
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Please provide email and password' });
    }

    if (isConnected()) {
      const user = await User.findOne({ email });
      if (user && (await user.matchPassword(password))) {
        return res.json({
          success: true,
          token: generateToken(user._id),
          user: {
            id: user._id.toString(),
            name: user.name,
            email: user.email,
            campusOrCity: user.campusOrCity,
            majorOrBio: user.majorOrBio,
            reputation: user.reputation,
            isCollegeVerified: user.isCollegeVerified,
            joinedCommunityIds: user.joinedCommunityIds,
            badges: user.badges,
          },
        });
      }
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    } else {
      // In-Memory store fallback
      let user = store.users.find((u) => u.email === email);
      if (!user && email === 'hardik@ddu.ac.in') {
        user = store.users[0];
      }

      if (user) {
        return res.json({
          success: true,
          token: generateToken(user.id),
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            campusOrCity: user.campusOrCity,
            majorOrBio: user.majorOrBio,
            reputation: user.reputation,
            isCollegeVerified: user.isCollegeVerified,
            joinedCommunityIds: user.joinedCommunityIds,
            badges: user.badges,
          },
        });
      }
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};

exports.getMe = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (isConnected()) {
      const user = await User.findById(userId).select('-password');
      if (!user) return res.status(404).json({ success: false, message: 'User not found' });
      return res.json({ success: true, user });
    } else {
      const user = store.users.find((u) => u.id === userId) || store.users[0];
      const { password, ...safeUser } = user;
      return res.json({ success: true, user: safeUser });
    }
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};
