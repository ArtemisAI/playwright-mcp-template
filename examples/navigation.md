# Navigation Examples

## Basic Navigation Patterns

### Simple Page Navigation
```javascript
// Navigate to a specific URL
await page.goto('https://bourses.umontreal.ca/repertoire-des-bourses/');

// Wait for page to fully load
await page.waitForLoadState('networkidle');

// Take a snapshot to see current state
await page.screenshot({ path: 'navigation-result.png' });
```

### Handling Navigation with Redirects
```javascript
// Navigate and handle potential redirects
try {
  await page.goto('https://login.umontreal.ca/redirect');
  
  // Wait for final URL after redirects
  await page.waitForLoadState('networkidle');
  
  console.log('Final URL:', page.url());
} catch (error) {
  console.log('Navigation failed:', error.message);
}
```

### Navigation with Specific Wait Conditions
```javascript
// Wait for specific element to appear
await page.goto('https://bourses.umontreal.ca/');
await page.waitForSelector('[data-testid="main-content"]');

// Wait for multiple conditions
await Promise.all([
  page.waitForLoadState('domcontentloaded'),
  page.waitForSelector('.page-header'),
  page.waitForFunction(() => document.readyState === 'complete')
]);
```

## Link Navigation

### Clicking Links with Navigation
```javascript
// Click link and wait for navigation
await Promise.all([
  page.waitForNavigation({ waitUntil: 'networkidle' }),
  page.click('a[href="/repertoire-des-bourses/"]')
]);

// Alternative: Use locator with navigation
await page.locator('text="Répertoire des bourses"').click();
await page.waitForURL('**/repertoire-des-bourses/**');
```

### Opening Links in New Tabs
```javascript
// Handle new tab/window
const [newPage] = await Promise.all([
  page.context().waitForEvent('page'),
  page.click('a[target="_blank"]')
]);

// Work with the new page
await newPage.waitForLoadState();
console.log('New page title:', await newPage.title());

// Close the new page when done
await newPage.close();
```

## URL-Based Navigation

### Direct URL Construction
```javascript
// Build URLs programmatically
const baseUrl = 'https://bourses.umontreal.ca/repertoire-des-bourses/';
const filterUrl = `${baseUrl}?tx_udembourses[do_search]=1&tx_udembourses[tb][]=4`;

await page.goto(filterUrl);
```

### Query Parameter Handling
```javascript
// Add query parameters
const url = new URL('https://bourses.umontreal.ca/repertoire-des-bourses/');
url.searchParams.set('tx_udembourses[do_search]', '1');
url.searchParams.set('tx_udembourses[tb][]', '4');

await page.goto(url.toString());
```

## Navigation Error Handling

### Network Error Recovery
```javascript
async function navigateWithRetry(page, url, maxRetries = 3) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
      return; // Success
    } catch (error) {
      console.log(`Navigation attempt ${attempt} failed:`, error.message);
      
      if (attempt === maxRetries) {
        throw new Error(`Failed to navigate to ${url} after ${maxRetries} attempts`);
      }
      
      // Wait before retry
      await page.waitForTimeout(2000 * attempt);
    }
  }
}

// Usage
await navigateWithRetry(page, 'https://bourses.umontreal.ca/');
```

### Handling Different Error Types
```javascript
try {
  await page.goto(url);
} catch (error) {
  if (error.message.includes('net::ERR_NAME_NOT_RESOLVED')) {
    console.log('DNS resolution failed');
    // Handle DNS errors
  } else if (error.message.includes('net::ERR_CONNECTION_TIMED_OUT')) {
    console.log('Connection timeout');
    // Handle timeout errors
  } else if (error.message.includes('net::ERR_INTERNET_DISCONNECTED')) {
    console.log('No internet connection');
    // Handle connectivity errors
  } else {
    console.log('Unknown navigation error:', error.message);
  }
}
```

## Advanced Navigation Patterns

### Back and Forward Navigation
```javascript
// Navigate forward through history
await page.goBack();
await page.waitForLoadState('networkidle');

// Navigate back
await page.goForward();
await page.waitForLoadState('networkidle');

// Reload page
await page.reload();
await page.waitForLoadState('networkidle');
```

### Conditional Navigation
```javascript
// Navigate based on current page state
const currentUrl = page.url();

if (currentUrl.includes('/login')) {
  // We're on login page, perform login
  await performLogin(page);
} else if (currentUrl.includes('/dashboard')) {
  // Already logged in, proceed
  console.log('Already authenticated');
} else {
  // Navigate to login
  await page.goto('https://login.umontreal.ca/');
}
```

### Multi-Step Navigation Workflow
```javascript
async function navigateScholarshipWorkflow(page) {
  // Step 1: Home page
  await page.goto('https://bourses.umontreal.ca/');
  await page.waitForSelector('.navigation-menu');
  
  // Step 2: Navigate to directory
  await page.click('text="Répertoire des bourses"');
  await page.waitForURL('**/repertoire-des-bourses/**');
  
  // Step 3: Apply filters
  await page.click('input[value="4"]'); // Engagement filter
  await page.waitForSelector('.search-results');
  
  // Step 4: Navigate to specific scholarship
  await page.click('.scholarship-item:first-child a');
  await page.waitForSelector('.scholarship-details');
  
  return page.url();
}
```

## Navigation State Management

### Checking Navigation State
```javascript
// Check if navigation is in progress
const isNavigating = await page.evaluate(() => {
  return document.readyState !== 'complete';
});

// Wait for specific URL pattern
await page.waitForURL(/.*repertoire.*bourses.*/);

// Check current URL
const currentUrl = page.url();
console.log('Current page:', currentUrl);
```

### Navigation Timing
```javascript
// Measure navigation performance
const startTime = Date.now();

await page.goto('https://bourses.umontreal.ca/repertoire-des-bourses/');
await page.waitForLoadState('networkidle');

const loadTime = Date.now() - startTime;
console.log(`Page loaded in ${loadTime}ms`);
```

## Common Navigation Scenarios

### Scholarship Portal Navigation
```javascript
// Complete UdeM scholarship portal navigation
async function navigateUdeMScholarships(page) {
  // Start at main scholarships page
  await page.goto('https://bourses.umontreal.ca/');
  
  // Navigate to scholarship directory
  await page.click('text="Répertoire des bourses"');
  await page.waitForURL('**/repertoire-des-bourses/**');
  
  // Apply engagement filter
  await page.click('input[name="tx_udembourses[tb][]"][value="4"]');
  
  // Wait for filtered results
  await page.waitForSelector('.search-results');
  
  // Return results summary
  const resultCount = await page.textContent('.result-count');
  return resultCount;
}
```

### Authentication Flow Navigation
```javascript
async function navigateWithAuth(page, protectedUrl) {
  await page.goto(protectedUrl);
  
  // Check if redirected to login
  if (page.url().includes('/login') || page.url().includes('/cas/')) {
    console.log('Authentication required');
    
    // Handle login redirect
    await handleLogin(page);
    
    // Navigate back to original URL
    await page.goto(protectedUrl);
  }
  
  await page.waitForLoadState('networkidle');
  return page.url();
}
```
