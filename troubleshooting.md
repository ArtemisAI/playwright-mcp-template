# Troubleshooting Guide

## Common Issues and Solutions

### 1. MCP Server Startup Issues

#### Issue: "Module not found" error
```
Error: Cannot find module '@modelcontextprotocol/server-playwright'
```

**Solutions:**
```powershell
# Install the package
npm install @modelcontextprotocol/server-playwright

# Or use npx to run without installation
npx --package @modelcontextprotocol/server-playwright playwright-mcp
```

#### Issue: Browser installation failures
```
Error: Executable doesn't exist at [browser path]
```

**Solutions:**
```powershell
# Force reinstall browsers
npx playwright install --force

# Install specific browser
npx playwright install chromium

# Check installation
npx playwright show-report
```

### 2. Network and Connectivity Issues

#### Issue: DNS resolution failures
```
net::ERR_NAME_NOT_RESOLVED
```

**Solutions:**
```javascript
// Implement retry logic
try {
  await page.goto(url);
} catch (error) {
  if (error.message.includes('ERR_NAME_NOT_RESOLVED')) {
    console.log('DNS error, retrying in 5 seconds...');
    await new Promise(resolve => setTimeout(resolve, 5000));
    await page.goto(url);
  }
}
```

#### Issue: Timeout errors
```
Timeout 30000ms exceeded
```

**Solutions:**
```javascript
// Increase timeout
await page.goto(url, { timeout: 60000 });

// Wait for specific conditions
await page.waitForLoadState('networkidle', { timeout: 60000 });

// Use shorter timeouts with retries
await page.click(selector, { timeout: 5000 });
```

### 3. Element Interaction Issues

#### Issue: Element not found
```
Error: Element not found
```

**Solutions:**
```javascript
// Wait for element to appear
await page.waitForSelector(selector, { timeout: 10000 });

// Use multiple selector strategies
const element = await page.locator(selector)
  .or(page.locator(fallbackSelector));

// Check if element exists before interaction
const elementExists = await page.locator(selector).count() > 0;
```

#### Issue: Element not clickable
```
Error: Element is not clickable
```

**Solutions:**
```javascript
// Wait for element to be visible and enabled
await page.waitForSelector(selector, { state: 'visible' });

// Scroll element into view
await page.locator(selector).scrollIntoViewIfNeeded();

// Use force click for stubborn elements
await page.click(selector, { force: true });
```

### 4. Authentication and Session Issues

#### Issue: Login redirects not working
**Solutions:**
```javascript
// Wait for navigation after login
await Promise.all([
  page.waitForNavigation({ waitUntil: 'networkidle' }),
  page.click('button[type="submit"]')
]);

// Check for login success indicators
await page.waitForSelector('.user-dashboard', { timeout: 10000 });
```

#### Issue: Session expiration
**Solutions:**
```javascript
// Check for session expiry indicators
const isLoggedIn = await page.locator('.user-menu').count() > 0;
if (!isLoggedIn) {
  // Re-authenticate
  await loginProcess();
}
```

### 5. Data Extraction Issues

#### Issue: Empty or null data extraction
**Solutions:**
```javascript
// Add null checks and fallbacks
const extractData = async (element) => {
  const title = await element.$eval('h3', el => el?.textContent?.trim()) || 'No title';
  const amount = await element.$eval('.amount', el => el?.textContent?.trim()) || 'Amount not specified';
  return { title, amount };
};

// Validate data before processing
const validData = extractedData.filter(item => 
  item.title && item.title !== 'No title'
);
```

#### Issue: Malformed or garbled text
**Solutions:**
```javascript
// Clean extracted text
const cleanText = (text) => {
  return text?.replace(/\s+/g, ' ')
             .replace(/\n+/g, ' ')
             .trim() || '';
};

// Handle encoding issues
const decodedText = decodeURIComponent(rawText);
```

### 6. Process Management Issues

#### Issue: Zombie browser processes
**Solutions:**
```powershell
# Kill all Chrome processes
taskkill /f /im chrome.exe

# Kill specific MCP processes
taskkill /f /im node.exe /fi "WINDOWTITLE eq playwright-mcp*"

# Create cleanup script
./scripts/cleanup.ps1
```

#### Issue: Memory leaks during long operations
**Solutions:**
```javascript
// Close pages when done
await page.close();

// Clear cache periodically
await page.context().clearCookies();

// Restart browser context for long sessions
await browser.close();
browser = await playwright.chromium.launch();
```

### 7. Performance Issues

#### Issue: Slow page loading
**Solutions:**
```javascript
// Block unnecessary resources
await page.route('**/*.{png,jpg,jpeg,gif,svg}', route => route.abort());

// Use headless mode
const browser = await playwright.chromium.launch({ headless: true });

// Wait for specific elements instead of full page load
await page.waitForSelector('[data-testid="content"]');
```

#### Issue: High memory usage
**Solutions:**
```javascript
// Limit concurrent operations
const concurrencyLimit = 3;
const results = [];
for (let i = 0; i < urls.length; i += concurrencyLimit) {
  const batch = urls.slice(i, i + concurrencyLimit);
  const batchResults = await Promise.all(
    batch.map(url => processUrl(url))
  );
  results.push(...batchResults);
}
```

### 8. Configuration Issues

#### Issue: MCP server not connecting to Claude
**Solutions:**
1. Check Claude Desktop MCP configuration:
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["--package", "@modelcontextprotocol/server-playwright", "playwright-mcp"],
      "cwd": "/path/to/your/project"
    }
  }
}
```

2. Restart Claude Desktop after configuration changes
3. Check logs for connection errors
4. Verify working directory path is correct

#### Issue: Browser configuration not applied
**Solutions:**
```json
// Check .playwright-mcprc configuration
{
  "browser": "chromium",
  "headless": false,
  "viewport": { "width": 1280, "height": 720 },
  "timeout": 30000
}
```

### 9. Debugging Strategies

#### Enable Debug Logging
```powershell
# PowerShell
$env:DEBUG = "playwright:*"
npx playwright-mcp

# Or for specific components
$env:DEBUG = "playwright:page"
```

#### Capture Screenshots for Debugging
```javascript
// Take screenshot before critical actions
await page.screenshot({ path: 'before-action.png' });

// Take screenshot on errors
try {
  await page.click(selector);
} catch (error) {
  await page.screenshot({ path: 'error-state.png' });
  throw error;
}
```

#### Use Page Traces
```javascript
// Start tracing
await page.context().tracing.start({
  screenshots: true,
  snapshots: true
});

// Stop and save trace
await page.context().tracing.stop({
  path: 'trace.zip'
});
```

### 10. Emergency Recovery Procedures

#### Complete Reset
```powershell
# Stop all processes
taskkill /f /im chrome.exe
taskkill /f /im node.exe

# Clear cache
Remove-Item -Recurse -Force .\.mcp-cache

# Reinstall browsers
npx playwright install --force

# Restart MCP server
npx --package @modelcontextprotocol/server-playwright playwright-mcp
```

#### Backup and Restore
```powershell
# Backup working configuration
Copy-Item -Recurse .\.mcp\playwright_general .\backup\

# Restore from backup
Copy-Item -Recurse .\backup\playwright_general .\.mcp\
```

### Getting Help

#### Log Collection
When reporting issues, collect:
1. Error messages and stack traces
2. Browser console logs
3. Network tab information
4. Configuration files
5. Steps to reproduce

#### Useful Commands for Diagnostics
```powershell
# Check Node.js and npm versions
node --version
npm --version

# Check Playwright installation
npx playwright --version

# List installed browsers
npx playwright show-report

# Test browser installation
npx playwright test --headed
```
