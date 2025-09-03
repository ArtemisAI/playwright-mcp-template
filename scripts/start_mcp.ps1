# PowerShell script to start Playwright MCP server
# Usage: .\start_mcp.ps1

param(
    [switch]$Headless,
    [string]$CacheDir = ".mcp-cache",
    [switch]$Debug
)

Write-Host "Starting Playwright MCP Server..." -ForegroundColor Green

# Set environment variables
if ($Debug) {
    $env:DEBUG = "playwright:*"
    Write-Host "Debug mode enabled" -ForegroundColor Yellow
}

# Ensure Node.js is available
try {
    $nodeVersion = node --version
    Write-Host "Node.js version: $nodeVersion" -ForegroundColor Cyan
} catch {
    Write-Error "Node.js not found. Please install Node.js 16+ and add it to PATH."
    exit 1
}

# Check if package is installed
try {
    npx --package @modelcontextprotocol/server-playwright --help | Out-Null
} catch {
    Write-Host "Installing Playwright MCP package..." -ForegroundColor Yellow
    npm install @modelcontextprotocol/server-playwright
}

# Ensure browsers are installed
Write-Host "Checking browser installation..." -ForegroundColor Cyan
try {
    npx playwright install chromium
} catch {
    Write-Warning "Failed to install browsers. Continuing anyway..."
}

# Create cache directory if it doesn't exist
if (-not (Test-Path $CacheDir)) {
    New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null
    Write-Host "Created cache directory: $CacheDir" -ForegroundColor Green
}

# Build command arguments
$arguments = @(
    "--package", "@modelcontextprotocol/server-playwright",
    "playwright-mcp",
    "--cache-dir", $CacheDir
)

if ($Headless) {
    $arguments += "--headless"
    Write-Host "Running in headless mode" -ForegroundColor Yellow
}

Write-Host "Starting MCP server with arguments: $($arguments -join ' ')" -ForegroundColor Cyan

try {
    # Start the MCP server
    npx @arguments
} catch {
    Write-Error "Failed to start Playwright MCP server: $_"
    exit 1
}

Write-Host "Playwright MCP server started successfully!" -ForegroundColor Green
