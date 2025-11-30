const axios = require('axios');

// ANSI color codes for output
const colors = {
  green: '\x1b[0;32m',
  blue: '\x1b[0;34m',
  yellow: '\x1b[1;33m',
  red: '\x1b[0;31m',
  reset: '\x1b[0m'
};

// Service URLs
const PRODUCTPAGE_URL = 'http://productpage:9080';
const DETAILS_URL = 'http://details:9080';
const REVIEWS_URL = 'http://reviews:9080';
const RATINGS_URL = 'http://ratings:9080';

// Request counter
let requestCount = 0;

// Function to make a request and log it
async function makeRequest(method, url, data = null, description) {
  requestCount++;
  console.log(`${colors.blue}[Request #${requestCount}]${colors.reset} ${description}`);
  
  try {
    const config = {
      method,
      url,
      validateStatus: () => true // Accept all status codes
    };
    
    if (data) {
      config.data = data;
      config.headers = { 'Content-Type': 'application/json' };
    }
    
    const response = await axios(config);
    const httpCode = response.status;
    const body = typeof response.data === 'string' ? response.data : JSON.stringify(response.data);
    
    // Log status
    if (httpCode >= 200 && httpCode < 300) {
      console.log(`${colors.green}✓ Success${colors.reset} - HTTP ${httpCode}`);
    } else if (httpCode >= 400 && httpCode < 500) {
      console.log(`${colors.yellow}⚠ Client Error${colors.reset} - HTTP ${httpCode}`);
    } else {
      console.log(`${colors.red}✗ Error${colors.reset} - HTTP ${httpCode}`);
    }
    
    // Show a snippet of the response if it exists
    if (body && body.length > 0) {
      const snippet = body.substring(0, 150);
      console.log(snippet + (body.length > 150 ? '...' : ''));
    }
    
    console.log('');
    
    // Small delay between requests
    await new Promise(resolve => setTimeout(resolve, 500));
    
  } catch (error) {
    console.log(`${colors.red}✗ Error${colors.reset} - ${error.message}`);
    console.log('');
  }
}

// Main traffic generation function
async function generateTraffic() {
  console.log('============================================');
  console.log('   Bookinfo Traffic Generator');
  console.log('============================================');
  console.log('');
  console.log(`Starting traffic generation at ${new Date().toUTCString()}`);
  console.log('');
  
  // Wait for services to be ready
  console.log('Waiting for services to be ready...');
  await new Promise(resolve => setTimeout(resolve, 2000));
  console.log('');
  
  // ===== ProductPage Service Requests =====
  console.log(`${colors.yellow}>>> Testing ProductPage Service${colors.reset}`);
  console.log('');
  
  await makeRequest('GET', `${PRODUCTPAGE_URL}/productpage?u=normal`, null, 
    'GET /productpage (main page with reviews)');
  
  await makeRequest('GET', `${PRODUCTPAGE_URL}/productpage?u=test`, null,
    'GET /productpage (different user session)');
  
  await makeRequest('GET', `${PRODUCTPAGE_URL}/productpage`, null,
    'GET /productpage (no user parameter)');
  
  await makeRequest('GET', `${PRODUCTPAGE_URL}/health`, null,
    'GET /health (productpage health check)');
  
  // ===== Details Service Requests =====
  console.log(`${colors.yellow}>>> Testing Details Service${colors.reset}`);
  console.log('');
  
  await makeRequest('GET', `${DETAILS_URL}/details/0`, null,
    'GET /details/0 (book details)');
  
  await makeRequest('GET', `${DETAILS_URL}/details/1`, null,
    'GET /details/1 (non-existent product)');
  
  await makeRequest('GET', `${DETAILS_URL}/health`, null,
    'GET /health (details service)');
  
  // ===== Reviews Service Requests =====
  console.log(`${colors.yellow}>>> Testing Reviews Service${colors.reset}`);
  console.log('');
  
  await makeRequest('GET', `${REVIEWS_URL}/reviews/0`, null,
    'GET /reviews/0 (product reviews)');
  
  await makeRequest('GET', `${REVIEWS_URL}/reviews/1`, null,
    'GET /reviews/1 (non-existent product)');
  
  await makeRequest('GET', `${REVIEWS_URL}/health`, null,
    'GET /health (reviews service)');
  
  // ===== Ratings Service Requests =====
  console.log(`${colors.yellow}>>> Testing Ratings Service${colors.reset}`);
  console.log('');
  
  await makeRequest('GET', `${RATINGS_URL}/ratings/0`, null,
    'GET /ratings/0 (product ratings)');
  
  await makeRequest('GET', `${RATINGS_URL}/ratings/1`, null,
    'GET /ratings/1 (non-existent product)');
  
  await makeRequest('GET', `${RATINGS_URL}/health`, null,
    'GET /health (ratings service)');
  
  // ===== Simulating Realistic User Behavior =====
  console.log(`${colors.yellow}>>> Simulating Realistic User Behavior (Multiple Page Views)${colors.reset}`);
  console.log('');
  
  const userTypes = ['normal', 'test', 'reviewer'];
  for (let i = 1; i <= 5; i++) {
    const user = userTypes[Math.floor(Math.random() * userTypes.length)];
    await makeRequest('GET', `${PRODUCTPAGE_URL}/productpage?u=${user}`, null,
      `GET /productpage (simulated user: ${user}, visit #${i})`);
  }
  
  // ===== POST Requests =====
  console.log(`${colors.yellow}>>> Testing POST Requests${colors.reset}`);
  console.log('');
  
  // Try posting a rating with product ID in the URL
  await makeRequest('POST', `${RATINGS_URL}/ratings/0`, 
    { reviewer: 'test-user', rating: 5 },
    'POST /ratings/0 (submit rating)');
  
  // ===== Summary =====
  console.log('');
  console.log('============================================');
  console.log('   Traffic Generation Complete');
  console.log('============================================');
  console.log('');
  console.log(`Total requests sent: ${requestCount}`);
  console.log(`Completed at: ${new Date().toUTCString()}`);
  console.log('');
  console.log('To run this again, execute:');
  console.log('  nerdctl run --rm --network docker-compose-boutique_bookinfo traffic-generator');
  console.log('  docker run --rm --network docker-compose-boutique_bookinfo traffic-generator');
  console.log('  podman run --rm --network docker-compose-boutique_bookinfo traffic-generator');
  console.log('');
}

// Run the traffic generator
generateTraffic().catch(error => {
  console.error(`${colors.red}Fatal error:${colors.reset}`, error.message);
  process.exit(1);
});

