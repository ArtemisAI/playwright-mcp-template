# PowerShell script to check Playwright MCP server status
# Usage: .\check_status.ps1

Write-Host "Checking Playwright MCP Server Status..." -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Gray

# Check Node.js availability
Write-Host "🔍 Checking Node.js..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js: Not found or not in PATH" -ForegroundColor Red
}

# Check npm availability
Write-Host "🔍 Checking npm..." -ForegroundColor Yellow
try {
    $npmVersion = npm --version
    Write-Host "✅ npm: v$npmVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ npm: Not found or not in PATH" -ForegroundColor Red
}

# Check if MCP package is installed globally
Write-Host "🔍 Checking Playwright MCP package..." -ForegroundColor Yellow
try {
    $packageInfo = npm list -g @modelcontextprotocol/server-playwright 2>$null
    if ($packageInfo -match "@modelcontextprotocol/server-playwright@(.+)") {
        Write-Host "✅ Playwright MCP: v$($matches[1])" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Playwright MCP: Installed but version unclear" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Playwright MCP: Not installed globally" -ForegroundColor Red
    Write-Host "   Try: npm install -g @modelcontextprotocol/server-playwright" -ForegroundColor Gray
}

# Check for running MCP processes
Write-Host "🔍 Checking running MCP processes..." -ForegroundColor Yellow
$mcpProcesses = Get-Process node -ErrorAction SilentlyContinue | Where-Object {
    $_.CommandLine -like "*playwright-mcp*" -or 
    $_.CommandLine -like "*@modelcontextprotocol/server-playwright*"
}

if ($mcpProcesses.Count -gt 0) {
    Write-Host "✅ Found $($mcpProcesses.Count) running MCP process(es):" -ForegroundColor Green
    foreach ($process in $mcpProcesses) {
        Write-Host "   📋 PID: $($process.Id), CPU: $($process.CPU)%" -ForegroundColor Cyan
    }
} else {
    Write-Host "⚠️  No running MCP processes found" -ForegroundColor Yellow
}

# Check for browser processes with remote debugging
Write-Host "🔍 Checking browser processes..." -ForegroundColor Yellow
$browserProcesses = Get-Process chrome, chromium, msedge, firefox -ErrorAction SilentlyContinue | Where-Object {
    $_.CommandLine -like "*--remote-debugging-port*" -or
    $_.CommandLine -like "*--enable-automation*"
}

if ($browserProcesses.Count -gt 0) {
    Write-Host "✅ Found $($browserProcesses.Count) automation-enabled browser(s):" -ForegroundColor Green
    foreach ($browser in $browserProcesses) {
        Write-Host "   🌐 $($browser.ProcessName) PID: $($browser.Id)" -ForegroundColor Cyan
    }
} else {
    Write-Host "⚠️  No automation-enabled browsers found" -ForegroundColor Yellow
}

# Check Playwright browsers installation
Write-Host "🔍 Checking Playwright browsers..." -ForegroundColor Yellow
try {
    $browserList = npx playwright list 2>$null
    if ($browserList) {
        Write-Host "✅ Playwright browsers installed:" -ForegroundColor Green
        $browserList | ForEach-Object { Write-Host "   $($_)" -ForegroundColor Cyan }
    } else {
        Write-Host "⚠️  No Playwright browsers found" -ForegroundColor Yellow
        Write-Host "   Try: npx playwright install" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Failed to check Playwright browsers" -ForegroundColor Red
}

# Check network connectivity (if needed for remote operations)
Write-Host "🔍 Checking network connectivity..." -ForegroundColor Yellow
try {
    $ping = Test-NetConnection -ComputerName "www.google.com" -Port 80 -InformationLevel Quiet
    if ($ping) {
        Write-Host "✅ Network: Connected" -ForegroundColor Green
    } else {
        Write-Host "❌ Network: Connection issues detected" -ForegroundColor Red
    }
} catch {
    Write-Host "⚠️  Network: Unable to test connectivity" -ForegroundColor Yellow
}

Write-Host "=" * 50 -ForegroundColor Gray
Write-Host "Status check completed!" -ForegroundColor Cyan
