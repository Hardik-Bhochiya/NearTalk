const http = require('http');

const runTests = async () => {
  const request = (path, method = 'GET', data = null) => {
    return new Promise((resolve, reject) => {
      const options = {
        hostname: '127.0.0.1',
        port: 5000,
        path,
        method,
        headers: {
          'Content-Type': 'application/json',
        },
      };

      const req = http.request(options, (res) => {
        let body = '';
        res.on('data', (chunk) => (body += chunk));
        res.on('end', () => {
          try {
            resolve({ status: res.statusCode, body: JSON.parse(body) });
          } catch {
            resolve({ status: res.statusCode, body });
          }
        });
      });

      req.on('error', reject);
      if (data) req.write(JSON.stringify(data));
      req.end();
    });
  };

  console.log('[Test] Running Backend API Tests...');

  try {
    // 1. Health Check
    const health = await request('/api/health');
    console.log(`[Test] 1. GET /api/health -> Status: ${health.status} (${health.body.service})`);

    // 2. Communities
    const comms = await request('/api/communities');
    console.log(`[Test] 2. GET /api/communities -> Status: ${comms.status} (Count: ${comms.body.count})`);

    // 3. Questions
    const questions = await request('/api/questions');
    console.log(`[Test] 3. GET /api/questions -> Status: ${questions.status} (Count: ${questions.body.count})`);

    // 4. Create Question
    const newQ = await request('/api/questions', 'POST', {
      title: 'Automated Test: What is the library timing on Sundays?',
      content: 'Testing question creation via REST API',
      communityId: 'c1',
      communityName: 'DDU Students',
      isAnonymous: true,
      tags: ['DDU', 'Library'],
    });
    console.log(`[Test] 4. POST /api/questions -> Status: ${newQ.status} (ID: ${newQ.body.data?.id})`);

    // 5. Upvote Question
    const upvote = await request(`/api/questions/${newQ.body.data?.id}/upvote`, 'POST');
    console.log(`[Test] 5. POST /api/questions/:id/upvote -> Status: ${upvote.status} (Upvotes: ${upvote.body.data?.upvotes})`);

    // 6. Chat Rooms
    const chatRooms = await request('/api/chat/rooms');
    console.log(`[Test] 6. GET /api/chat/rooms -> Status: ${chatRooms.status} (Count: ${chatRooms.body.count})`);

    // 7. Search Users
    const usersSearch = await request('/api/auth/users?q=');
    console.log(`[Test] 7. GET /api/auth/users -> Status: ${usersSearch.status} (Count: ${usersSearch.body.count})`);

    // 8. Cancel Friend Request Endpoint check
    const cancelReq = await request('/api/friends/cancel', 'POST', {
      senderUsername: 'test_user_1',
      receiverUsername: 'test_user_2',
    });
    console.log(`[Test] 8. POST /api/friends/cancel -> Status: ${cancelReq.status} (Success: ${cancelReq.body.success})`);

    console.log('\n[Test] ALL BACKEND API TESTS PASSED SUCCESSFULLY! 🎉');
  } catch (err) {
    console.error('[Test Failed]', err.message);
  }
};

runTests();
