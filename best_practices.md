# Playwright MCP Best Practices

## General Principles

### 1. Error Handling and Recovery
- Always implement graceful error handling for network issues
- Use try-catch patterns for critical operations
- Implement retry mechanisms for transient failures
- Clean up browser processes on errors

### 2. Performance Optimization
- Use headless mode for production automation
- Cache browser instances when possible
- Minimize page loads and navigation
- Use efficient element selectors

### 3. Resource Management
- Properly close browser instances
- Clean up temporary files and cache
- Monitor memory usage during long operations
- Use background processes for long-running tasks

## Navigation Best Practices

### URL Handling
```javascript
// Good: Use absolute URLs
await page.goto('https://bourses.umontreal.ca/repertoire-des-bourses/');

// Avoid: Relative URLs that might fail
await page.goto('/repertoire-des-bourses/');
```

### Page Loading
```javascript
// Wait for page load completion
await page.waitForLoadState('networkidle');

// Wait for specific elements
await page.waitForSelector('[data-testid="content"]');
```

## Element Selection Strategies

### Robust Selectors
1. **Use stable attributes**: `data-testid`, `id`, `name`
2. **Avoid fragile selectors**: CSS classes that might change
3. **Use text content**: When structural selectors aren't available
4. **Implement fallback selectors**: Multiple selection strategies

### Example Selection Patterns
```javascript
// Primary selector with fallback
const element = await page.locator('[data-testid="submit-btn"]')
  .or(page.locator('button:has-text("Submit")'))
  .or(page.locator('.submit-button'));
```

## Form Interaction Patterns

### Input Handling
```javascript
// Clear before typing
await page.fill('input[name="email"]', '');
await page.fill('input[name="email"]', 'user@example.com');

// Alternative: Clear and type
await page.locator('input[name="email"]').clear();
await page.locator('input[name="email"]').type('user@example.com');
```

### Checkbox and Radio Buttons
```javascript
// Check/uncheck
await page.check('input[name="agree"]');
await page.uncheck('input[name="newsletter"]');

// Radio button selection
await page.click('input[value="option1"]');
```

## Data Extraction Best Practices

### Structured Data Collection
```javascript
// Extract multiple elements efficiently
const items = await page.$$eval('article.bourse-item', elements => 
  elements.map(el => ({
    title: el.querySelector('h3')?.textContent?.trim(),
    amount: el.querySelector('.amount')?.textContent?.trim(),
    deadline: el.querySelector('.deadline')?.textContent?.trim(),
    url: el.querySelector('a')?.href
  }))
);
```

### Text Processing
```javascript
// Clean extracted text
const cleanText = (text) => text?.replace(/\s+/g, ' ').trim();

// Extract and clean
const title = cleanText(await element.textContent());
```

## Authentication and Session Management

### Login Handling
```javascript
// Wait for login form
await page.waitForSelector('form[name="login"]');

// Fill credentials
await page.fill('input[name="username"]', username);
await page.fill('input[name="password"]', password);

// Submit and wait for navigation
await Promise.all([
  page.waitForNavigation(),
  page.click('button[type="submit"]')
]);
```

### Session Persistence
```javascript
// Save session state
const cookies = await page.context().cookies();
await fs.writeFile('session.json', JSON.stringify(cookies));

// Restore session
const savedCookies = JSON.parse(await fs.readFile('session.json'));
await page.context().addCookies(savedCookies);
```

## Error Handling Patterns

### Network Error Recovery
```javascript
try {
  await page.goto(url, { waitUntil: 'networkidle' });
} catch (error) {
  if (error.message.includes('net::ERR_NAME_NOT_RESOLVED')) {
    console.log('DNS resolution failed, retrying...');
    await new Promise(resolve => setTimeout(resolve, 5000));
    await page.goto(url);
  }
}
```

### Element Interaction Errors
```javascript
// Retry element interactions
async function clickWithRetry(page, selector, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      await page.click(selector, { timeout: 5000 });
      return;
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      await page.waitForTimeout(1000);
    }
  }
}
```

## Resource Cleanup

### Process Management
```powershell
# PowerShell cleanup script
taskkill /f /im chrome.exe 2>$null
taskkill /f /im node.exe /fi "WINDOWTITLE eq playwright-mcp*" 2>$null
```

### Cache Management
```javascript
// Clear browser cache periodically
await page.context().clearCookies();
await page.context().clearPermissions();
```

## Development and Debugging

### Debugging Strategies
1. **Use screenshots**: Capture state before/after actions
2. **Enable verbose logging**: Set DEBUG environment variable
3. **Use page.pause()**: For interactive debugging
4. **Record traces**: Enable trace recording for complex scenarios

### Logging Best Practices
```javascript
// Structured logging
console.log(`[${new Date().toISOString()}] Navigating to: ${url}`);
console.log(`[${new Date().toISOString()}] Found ${items.length} items`);
```

## Security Considerations

### Credential Management
- Never hardcode credentials in scripts
- Use environment variables or secure vaults
- Implement proper session cleanup
- Be mindful of logged sensitive data

### Rate Limiting
- Implement delays between requests
- Respect robots.txt and rate limits
- Use random delays to avoid detection
- Monitor for rate limiting responses

## Testing and Validation

### Data Validation
```javascript
// Validate extracted data
const isValidData = (item) => {
  return item.title && 
         item.amount && 
         item.deadline && 
         item.url?.startsWith('http');
};

const validItems = items.filter(isValidData);
```

### Automated Testing
- Test scripts with different data sets
- Implement smoke tests for critical paths
- Use staging environments when available
- Validate against expected data schemas
