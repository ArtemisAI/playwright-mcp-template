# Authentication Examples

## Basic Authentication Patterns

### Simple Login Form
```javascript
async function performBasicLogin(page, username, password) {
  // Navigate to login page
  await page.goto('https://login.umontreal.ca/');
  
  // Wait for login form
  await page.waitForSelector('form[name="login"], .login-form');
  
  // Fill credentials
  await page.fill('input[name="username"], input[type="email"]', username);
  await page.fill('input[name="password"], input[type="password"]', password);
  
  // Submit form and wait for navigation
  await Promise.all([
    page.waitForNavigation({ waitUntil: 'networkidle' }),
    page.click('button[type="submit"], input[type="submit"]')
  ]);
  
  // Verify login success
  const isLoggedIn = await page.locator('.user-menu, .dashboard, .logout').count() > 0;
  return isLoggedIn;
}
```

### UdeM CAS Authentication
```javascript
async function loginUdeMCAS(page, username, password) {
  try {
    // Navigate to protected resource (will redirect to CAS)
    await page.goto('https://studium.umontreal.ca/');
    
    // Check if redirected to CAS login
    if (page.url().includes('idm.umontreal.ca') || page.url().includes('/cas/')) {
      console.log('Redirected to CAS login');
      
      // Wait for login form
      await page.waitForSelector('input[name="username"], input[name="j_username"]');
      
      // Fill CAS credentials
      await page.fill('input[name="username"], input[name="j_username"]', username);
      await page.fill('input[name="password"], input[name="j_password"]', password);
      
      // Submit CAS form
      await Promise.all([
        page.waitForNavigation({ timeout: 30000 }),
        page.click('button[type="submit"], input[type="submit"]')
      ]);
      
      // Wait for redirect back to original service
      await page.waitForLoadState('networkidle');
      
      console.log('CAS authentication completed');
      return true;
    } else {
      console.log('Already authenticated or no CAS redirect needed');
      return true;
    }
  } catch (error) {
    console.error('CAS authentication failed:', error.message);
    return false;
  }
}
```

### Multi-Factor Authentication (MFA)
```javascript
async function handleMFALogin(page, username, password) {
  // Perform initial login
  await page.fill('input[name="username"]', username);
  await page.fill('input[name="password"]', password);
  await page.click('button[type="submit"]');
  
  // Check for MFA challenge
  const mfaRequired = await page.locator('.mfa-challenge, .two-factor').count() > 0;
  
  if (mfaRequired) {
    console.log('MFA challenge detected');
    
    // Wait for MFA token input (manual intervention required)
    console.log('Please enter MFA token in the browser...');
    
    // Wait for MFA completion (user enters token manually)
    await page.waitForSelector('.dashboard, .user-profile', { timeout: 120000 });
    
    console.log('MFA authentication completed');
  }
  
  return true;
}
```

## Session Management

### Cookie-Based Session Persistence
```javascript
async function saveSession(page, sessionFile) {
  // Get all cookies from current context
  const cookies = await page.context().cookies();
  
  // Save session data
  const sessionData = {
    cookies,
    timestamp: Date.now(),
    url: page.url()
  };
  
  await require('fs').promises.writeFile(
    sessionFile, 
    JSON.stringify(sessionData, null, 2), 
    'utf8'
  );
  
  console.log('Session saved to', sessionFile);
}

async function loadSession(page, sessionFile) {
  try {
    // Read session data
    const sessionContent = await require('fs').promises.readFile(sessionFile, 'utf8');
    const sessionData = JSON.parse(sessionContent);
    
    // Check if session is not too old (e.g., 24 hours)
    const age = Date.now() - sessionData.timestamp;
    const maxAge = 24 * 60 * 60 * 1000; // 24 hours
    
    if (age > maxAge) {
      console.log('Session expired, need to re-authenticate');
      return false;
    }
    
    // Restore cookies
    await page.context().addCookies(sessionData.cookies);
    
    // Navigate to a protected page to verify session
    await page.goto(sessionData.url);
    await page.waitForLoadState('networkidle');
    
    // Check if still authenticated
    const isAuthenticated = await checkAuthenticationStatus(page);
    
    if (isAuthenticated) {
      console.log('Session restored successfully');
      return true;
    } else {
      console.log('Session invalid, need to re-authenticate');
      return false;
    }
  } catch (error) {
    console.log('Failed to load session:', error.message);
    return false;
  }
}

async function checkAuthenticationStatus(page) {
  // Check for authentication indicators
  const authIndicators = [
    '.user-menu',
    '.logout-button',
    '.user-profile',
    '.dashboard',
    '[data-testid="user-authenticated"]'
  ];
  
  for (const indicator of authIndicators) {
    if (await page.locator(indicator).count() > 0) {
      return true;
    }
  }
  
  // Check for login indicators (inverse check)
  const loginIndicators = [
    '.login-form',
    'input[name="username"]',
    'button:has-text("Login")',
    'a:has-text("Sign In")'
  ];
  
  for (const indicator of loginIndicators) {
    if (await page.locator(indicator).count() > 0) {
      return false;
    }
  }
  
  return true; // Assume authenticated if no clear indicators
}
```

### Local Storage Session Management
```javascript
async function saveLocalStorageSession(page, sessionFile) {
  // Extract local storage data
  const localStorageData = await page.evaluate(() => {
    const data = {};
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);
      data[key] = localStorage.getItem(key);
    }
    return data;
  });
  
  // Extract session storage data
  const sessionStorageData = await page.evaluate(() => {
    const data = {};
    for (let i = 0; i < sessionStorage.length; i++) {
      const key = sessionStorage.key(i);
      data[key] = sessionStorage.getItem(key);
    }
    return data;
  });
  
  const sessionData = {
    localStorage: localStorageData,
    sessionStorage: sessionStorageData,
    cookies: await page.context().cookies(),
    timestamp: Date.now()
  };
  
  await require('fs').promises.writeFile(
    sessionFile,
    JSON.stringify(sessionData, null, 2),
    'utf8'
  );
}

async function restoreLocalStorageSession(page, sessionFile) {
  try {
    const sessionContent = await require('fs').promises.readFile(sessionFile, 'utf8');
    const sessionData = JSON.parse(sessionContent);
    
    // Restore cookies
    await page.context().addCookies(sessionData.cookies);
    
    // Navigate to the application
    await page.goto('https://your-app.com/');
    
    // Restore local storage
    await page.evaluate((localStorageData) => {
      for (const [key, value] of Object.entries(localStorageData)) {
        localStorage.setItem(key, value);
      }
    }, sessionData.localStorage);
    
    // Restore session storage
    await page.evaluate((sessionStorageData) => {
      for (const [key, value] of Object.entries(sessionStorageData)) {
        sessionStorage.setItem(key, value);
      }
    }, sessionData.sessionStorage);
    
    // Refresh to apply stored data
    await page.reload();
    await page.waitForLoadState('networkidle');
    
    return true;
  } catch (error) {
    console.error('Failed to restore session:', error.message);
    return false;
  }
}
```

## Advanced Authentication Workflows

### Complete UdeM Authentication Workflow
```javascript
async function authenticateUdeM(page, credentials, sessionFile = 'udem-session.json') {
  // Try to restore existing session first
  const sessionRestored = await loadSession(page, sessionFile);
  
  if (sessionRestored) {
    console.log('Using existing session');
    return true;
  }
  
  console.log('Performing fresh authentication');
  
  try {
    // Navigate to UdeM portal
    await page.goto('https://monudem.umontreal.ca/');
    
    // Check if redirected to login
    if (page.url().includes('login') || page.url().includes('cas')) {
      // Perform CAS authentication
      await page.waitForSelector('input[name="username"]');
      await page.fill('input[name="username"]', credentials.username);
      await page.fill('input[name="password"]', credentials.password);
      
      await Promise.all([
        page.waitForNavigation({ timeout: 30000 }),
        page.click('button[type="submit"]')
      ]);
    }
    
    // Verify authentication success
    await page.waitForLoadState('networkidle');
    const isAuthenticated = await checkAuthenticationStatus(page);
    
    if (isAuthenticated) {
      // Save session for future use
      await saveSession(page, sessionFile);
      console.log('Authentication successful');
      return true;
    } else {
      console.error('Authentication failed');
      return false;
    }
  } catch (error) {
    console.error('Authentication error:', error.message);
    return false;
  }
}
```

### OAuth/SSO Authentication
```javascript
async function handleOAuthLogin(page, provider = 'google') {
  // Click OAuth login button
  await page.click(`button:has-text("Login with ${provider}"), .oauth-${provider}`);
  
  // Wait for OAuth provider page
  await page.waitForURL(`**/${provider}**`, { timeout: 10000 });
  
  // Handle OAuth provider login
  if (provider === 'google') {
    await handleGoogleOAuth(page);
  } else if (provider === 'microsoft') {
    await handleMicrosoftOAuth(page);
  }
  
  // Wait for redirect back to application
  await page.waitForURL('**/dashboard**', { timeout: 30000 });
  
  return true;
}

async function handleGoogleOAuth(page) {
  // Wait for Google login form
  await page.waitForSelector('input[type="email"]');
  
  // Fill email
  await page.fill('input[type="email"]', process.env.GOOGLE_EMAIL);
  await page.click('#identifierNext');
  
  // Wait for password field
  await page.waitForSelector('input[type="password"]', { state: 'visible' });
  
  // Fill password
  await page.fill('input[type="password"]', process.env.GOOGLE_PASSWORD);
  await page.click('#passwordNext');
  
  // Handle potential 2FA
  const has2FA = await page.locator('#totpPin').count() > 0;
  if (has2FA) {
    console.log('2FA required - manual intervention needed');
    await page.waitForNavigation({ timeout: 120000 });
  }
}
```

## Authentication Error Handling

### Robust Authentication with Retries
```javascript
async function authenticateWithRetry(page, credentials, maxRetries = 3) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      console.log(`Authentication attempt ${attempt}/${maxRetries}`);
      
      const success = await performAuthentication(page, credentials);
      
      if (success) {
        console.log('Authentication successful');
        return true;
      } else {
        console.log(`Authentication attempt ${attempt} failed`);
        
        if (attempt < maxRetries) {
          // Wait before retry
          await page.waitForTimeout(2000 * attempt);
          
          // Clear any error states
          await clearAuthenticationErrors(page);
        }
      }
    } catch (error) {
      console.error(`Authentication attempt ${attempt} error:`, error.message);
      
      if (attempt === maxRetries) {
        throw error;
      }
      
      // Reset page state for retry
      await page.reload();
      await page.waitForLoadState('networkidle');
    }
  }
  
  throw new Error('Authentication failed after all retry attempts');
}

async function clearAuthenticationErrors(page) {
  // Clear form fields
  await page.fill('input[name="username"]', '');
  await page.fill('input[name="password"]', '');
  
  // Dismiss any error messages
  const errorDismissButtons = page.locator('.error-dismiss, .alert-close, .close-button');
  const count = await errorDismissButtons.count();
  
  for (let i = 0; i < count; i++) {
    await errorDismissButtons.nth(i).click();
  }
}
```

### Authentication Status Monitoring
```javascript
async function monitorAuthenticationStatus(page, callback) {
  let isAuthenticated = await checkAuthenticationStatus(page);
  
  // Set up periodic status checks
  const statusInterval = setInterval(async () => {
    const currentStatus = await checkAuthenticationStatus(page);
    
    if (currentStatus !== isAuthenticated) {
      isAuthenticated = currentStatus;
      
      if (isAuthenticated) {
        console.log('User authenticated');
        callback('authenticated');
      } else {
        console.log('User logged out');
        callback('unauthenticated');
      }
    }
  }, 5000); // Check every 5 seconds
  
  // Return cleanup function
  return () => clearInterval(statusInterval);
}

// Usage
const stopMonitoring = await monitorAuthenticationStatus(page, (status) => {
  if (status === 'unauthenticated') {
    console.log('Re-authentication required');
    // Trigger re-authentication
  }
});

// Later: stopMonitoring();
```

## Security Considerations

### Secure Credential Handling
```javascript
// Use environment variables for credentials
const credentials = {
  username: process.env.UDEM_USERNAME,
  password: process.env.UDEM_PASSWORD
};

// Or use a secure credential store
async function getCredentialsFromVault() {
  // Implementation depends on your credential management system
  return {
    username: await vault.getSecret('udem-username'),
    password: await vault.getSecret('udem-password')
  };
}

// Never log credentials
function safeLog(message, data) {
  const sensitiveFields = ['password', 'token', 'secret', 'key'];
  const safeTta = { ...data };
  
  sensitiveFields.forEach(field => {
    if (safeTta[field]) {
      safeTta[field] = '***REDACTED***';
    }
  });
  
  console.log(message, safeTta);
}
```

### Session Security
```javascript
async function secureSessionManagement(page) {
  // Set secure session timeouts
  const sessionTimeout = 30 * 60 * 1000; // 30 minutes
  
  // Monitor for security warnings
  page.on('dialog', async (dialog) => {
    if (dialog.message().includes('security') || dialog.message().includes('session')) {
      console.log('Security dialog detected:', dialog.message());
      await dialog.accept();
    }
  });
  
  // Clear sensitive data on session end
  const clearSensitiveData = async () => {
    await page.evaluate(() => {
      // Clear sensitive local storage
      const sensitiveKeys = Object.keys(localStorage).filter(key => 
        key.includes('token') || key.includes('auth') || key.includes('password')
      );
      
      sensitiveKeys.forEach(key => localStorage.removeItem(key));
      
      // Clear session storage
      sessionStorage.clear();
    });
    
    // Clear cookies
    await page.context().clearCookies();
  };
  
  // Set up session timeout
  setTimeout(clearSensitiveData, sessionTimeout);
  
  return clearSensitiveData;
}
```
