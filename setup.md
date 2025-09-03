# Playwright MCP Server Setup Guide

## Prerequisites

### System Requirements
- **Node.js**: Version 16+ required
- **PowerShell**: 5.1+ or PowerShell Core 7+
- **Windows**: Tested on Windows 10/11
- **Chrome/Chromium**: Latest version (auto-installed by Playwright)

### Claude Desktop Integration
- Claude Desktop app with MCP support
- VS Code with Claude extension (optional but recommended)

## Installation Steps

### 1. Node.js and Package Setup

Create a `package.json` in your project root:

```json
{
  "name": "playwright-mcp-automation",
  "version": "1.0.0",
  "type": "module",
  "dependencies": {
    "@modelcontextprotocol/server-playwright": "^0.6.0",
    "playwright": "^1.40.0"
  },
  "scripts": {
    "start-mcp": "npx --package @modelcontextprotocol/server-playwright playwright-mcp --cache-dir .mcp-cache"
  }
}
```

Install dependencies:
```powershell
npm install
npx playwright install chromium
```

### 2. MCP Server Configuration

Create `.playwright-mcprc` configuration file:

```json
{
  "browser": "chromium",
  "headless": false,
  "viewport": {
    "width": 1280,
    "height": 720
  },
  "timeout": 30000,
  "cacheDir": ".mcp-cache"
}
```

### 3. Claude Desktop MCP Configuration

Add to Claude Desktop's MCP settings:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "--package",
        "@modelcontextprotocol/server-playwright",
        "playwright-mcp",
        "--cache-dir",
        ".mcp-cache"
      ],
      "cwd": "H:\\My Drive\\2_STUDIES\\_UdeM\\Scholarships"
    }
  }
}
```

### 4. VS Code Integration (Optional)

Add to VS Code settings.json:
```json
{
  "playwright.reuseBrowser": true,
  "playwright.showTrace": true
}
```

## Directory Structure Setup

Create the following directory structure in your project:

```
project_root/
├── .mcp/
│   ├── playwright_general/     # Documentation (this folder)
│   └── cache/                  # Runtime cache
├── .mcp-cache/                 # Playwright browser cache
├── package.json                # Node.js dependencies
├── .playwright-mcprc          # MCP configuration
├── scripts/
│   ├── start_mcp.ps1          # Startup script
│   └── cleanup.ps1            # Cleanup script
└── logs/                      # Runtime logs
```

## Environment Variables

Set the following environment variables for optimal performance:

```powershell
# PowerShell
$env:PLAYWRIGHT_CACHE_DIR = ".\.mcp-cache"
$env:PLAYWRIGHT_BROWSERS_PATH = ".\.mcp-cache\browsers"
$env:DEBUG = "playwright:*"  # For debugging (optional)
```

## Verification Steps

1. **Test Node.js installation**:
   ```powershell
   node --version
   npm --version
   ```

2. **Verify Playwright installation**:
   ```powershell
   npx playwright --version
   ```

3. **Test MCP server startup**:
   ```powershell
   npx --package @modelcontextprotocol/server-playwright playwright-mcp --cache-dir .mcp-cache
   ```

4. **Check browser installation**:
   ```powershell
   npx playwright show-report  # Should list installed browsers
   ```

## Common Setup Issues

### Issue: "Module not found" errors
**Solution**: Ensure you're in the correct directory and run `npm install`

### Issue: Browser download failures
**Solution**: 
```powershell
npx playwright install --force
```

### Issue: Permission errors
**Solution**: Run PowerShell as Administrator for initial setup

### Issue: Path-related errors
**Solution**: Use absolute paths in configuration files

## Next Steps

After successful setup:
1. Review [Configuration Files](./config/) for customization options
2. Study [Usage Examples](./examples/) for implementation patterns
3. Test with simple navigation commands
4. Implement error handling and cleanup procedures
