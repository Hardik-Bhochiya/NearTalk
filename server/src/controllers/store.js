const { v4: uuidv4 } = require('uuid');

class InMemoryStore {
  constructor() {
    this.users = [
      {
        id: 'user-hardik',
        username: 'hardik_07',
        name: 'Hardik Bhochiya',
        firstName: 'Hardik',
        lastName: 'Bhochiya',
        email: 'hardik@gmail.com',
        password: '$2a$10$abcdefghijklmnopqrstuvwxyz123456',
        campusOrCity: 'Nadiad',
        majorOrBio: 'Computer Engineering | Tech & Community Builder',
        reputation: 240,
        joinedCommunityIds: ['c-mumbai-dev', 'c-ddu-students'],
        badges: ['Top Contributor'],
        isCollegeVerified: true,
      },
      {
        id: 'user-rahul',
        username: 'rahul123',
        name: 'Rahul Patel',
        firstName: 'Rahul',
        lastName: 'Patel',
        email: 'rahul@gmail.com',
        password: '$2a$10$abcdefghijklmnopqrstuvwxyz123456',
        campusOrCity: 'Mumbai',
        majorOrBio: 'Mumbai Developers • Full Stack Engineer',
        reputation: 160,
        joinedCommunityIds: ['c-mumbai-dev'],
        badges: [],
        isCollegeVerified: true,
      },
      {
        id: 'user-priya',
        username: 'priya_it',
        name: 'Priya Shah',
        firstName: 'Priya',
        lastName: 'Shah',
        email: 'priya@gmail.com',
        password: '$2a$10$abcdefghijklmnopqrstuvwxyz123456',
        campusOrCity: 'Ahmedabad',
        majorOrBio: 'Ahmedabad Students • Tech Enthusiast',
        reputation: 180,
        joinedCommunityIds: ['c-ahmedabad-students'],
        badges: [],
        isCollegeVerified: true,
      },
      {
        id: 'user-devshah',
        username: 'devshah',
        name: 'Dev Shah',
        firstName: 'Dev',
        lastName: 'Shah',
        email: 'dev@gmail.com',
        password: '$2a$10$abcdefghijklmnopqrstuvwxyz123456',
        campusOrCity: 'Dwarka',
        majorOrBio: 'Dwarka Developers • Mobile App Builder',
        reputation: 140,
        joinedCommunityIds: ['c-dwarka-dev'],
        badges: [],
        isCollegeVerified: true,
      },
    ];

    // Zero Readymade Groups - Users create their own communities with location spots
    this.communities = [];

    // Zero Dummy Questions
    this.questions = [];

    this.rooms = [];

    this.messages = {};

    this.friendRequests = [];

    this.friends = {}; // username -> Set of friend usernames
  }
}

const store = new InMemoryStore();
module.exports = store;
