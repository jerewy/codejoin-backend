const axios = require('axios');

const BASE_URL = process.env.BASE_URL || 'http://localhost:3001';

async function testCodeExecution() {
  console.log('Testing Code Execution API...\n');

  try {
    // Test 1: Simple JavaScript code
    console.log('1. Testing JavaScript execution...');
    const jsResponse = await axios.post(`${BASE_URL}/api/execute`, {
      language: 'javascript',
      code: 'console.log("Hello from JavaScript!");\nconsole.log("Execution completed successfully");',
      timeout: 10
    });

    console.log('   JavaScript execution started:', jsResponse.data.executionId);

    // Check status
    const jsStatus = await axios.get(`${BASE_URL}/api/status/${jsResponse.data.executionId}`);
    console.log('   JavaScript status:', jsStatus.data.status);

    if (jsStatus.data.status === 'completed') {
      console.log('   JavaScript output:', jsStatus.data.output);
    }

    console.log('\n2. Testing Python execution...');
    const pyResponse = await axios.post(`${BASE_URL}/api/execute`, {
      language: 'python',
      code: 'print("Hello from Python!")\nprint("Python execution completed")',
      timeout: 10
    });

    console.log('   Python execution started:', pyResponse.data.executionId);

    // Wait a moment for Python execution
    setTimeout(async () => {
      try {
        const pyStatus = await axios.get(`${BASE_URL}/api/status/${pyResponse.data.executionId}`);
        console.log('   Python status:', pyStatus.data.status);

        if (pyStatus.data.status === 'completed') {
          console.log('   Python output:', pyStatus.data.output);
        }
      } catch (error) {
        console.error('   Python status check failed:', error.message);
      }

      console.log('\n3. Testing error handling (invalid language)...');
      try {
        await axios.post(`${BASE_URL}/api/execute`, {
          language: 'ruby',
          code: 'puts "Hello from Ruby"',
          timeout: 10
        });
      } catch (error) {
        console.log('   Error handled correctly:', error.response.data.error);
      }

      console.log('\n4. Testing validation (missing required fields)...');
      try {
        await axios.post(`${BASE_URL}/api/execute`, {
          code: 'console.log("test");'
          // missing language
        });
      } catch (error) {
        console.log('   Validation error handled correctly:', error.response.data.error);
      }

      console.log('\n✅ All tests completed!');
    }, 2000);

  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  }
}

// Run tests
testCodeExecution();