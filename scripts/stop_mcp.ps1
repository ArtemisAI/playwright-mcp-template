# PowerShell script to stop Playwright MCP server
# Usage: .\stop_mcp.ps1

param(
    [switch]$Force
)

Write-Host "Stopping Playwright MCP Server..." -ForegroundColor Red

# Find all Node.js processes running MCP server
$mcpProcesses = Get-Process node -ErrorAction SilentlyContinue | Where-Object {
    $_.CommandLine -like "*playwright-mcp*" -or 
    $_.CommandLine -like "*@modelcontextprotocol/server-playwright*"
}

if ($mcpProcesses.Count -eq 0) {
    Write-Host "No Playwright MCP server processes found." -ForegroundColor Yellow
    return
}

Write-Host "Found $($mcpProcesses.Count) MCP server process(es)" -ForegroundColor Cyan

foreach ($process in $mcpProcesses) {
    try {
        Write-Host "Stopping process ID: $($process.Id)" -ForegroundColor Yellow
        
        if ($Force) {
            $process.Kill()
            Write-Host "Force killed process $($process.Id)" -ForegroundColor Red
        } else {
            $process.CloseMainWindow()
            # Wait up to 5 seconds for graceful shutdown
            if (-not $process.WaitForExit(5000)) {
                Write-Host "Process didn't exit gracefully, force killing..." -ForegroundColor Yellow
                $process.Kill()
            }
        }
        
        Write-Host "Successfully stopped process $($process.Id)" -ForegroundColor Green
    } catch {
        Write-Error "Failed to stop process $($process.Id): $_"
    }
}

# Also check for any lingering browser processes
$browserProcesses = Get-Process chrome, chromium, msedge -ErrorAction SilentlyContinue | Where-Object {
    $_.CommandLine -like "*--remote-debugging-port*"
}

if ($browserProcesses.Count -gt 0) {
    Write-Host "Found $($browserProcesses.Count) browser process(es) with remote debugging" -ForegroundColor Cyan
    
    foreach ($browser in $browserProcesses) {
        try {
            Write-Host "Stopping browser process ID: $($browser.Id)" -ForegroundColor Yellow
            $browser.Kill()
            Write-Host "Successfully stopped browser process $($browser.Id)" -ForegroundColor Green
        } catch {
            Write-Error "Failed to stop browser process $($browser.Id): $_"
        }
    }
}

Write-Host "Playwright MCP server cleanup completed!" -ForegroundColor Green
