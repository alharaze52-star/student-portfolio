const http = require('http');

function get(url) {
  return new Promise((resolve, reject) => {
    http.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve({ status: res.statusCode, body: JSON.parse(data) }));
    }).on('error', (e) => reject(e));
  });
}

async function test() {
  console.log('Testing server endpoints...');
  try {
    const health = await get('http://127.0.0.1:3000/health');
    console.log('1. Health check OK:', health.body.status, health.body.service);

    const profile = await get('http://127.0.0.1:3000/api/profile');
    console.log('2. Profile GET OK:', profile.body.fullName, '| GPA:', profile.body.gpa);

    const projects = await get('http://127.0.0.1:3000/api/projects');
    console.log('3. Projects GET OK: Count =', projects.body.length);

    console.log('ALL API ENDPOINTS TESTED SUCCESSFULLY!');
    process.exit(0);
  } catch (err) {
    console.error('API Test Error Details:', err.code, err.message);
    process.exit(1);
  }
}

require('./server.js');
setTimeout(test, 500);
