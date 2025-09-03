# PowerShell script to reset Playwright MCP environment
# Usage: .\reset_environment.ps1

param(
    [switch]$Force,
    [switch]$KeepCache
)

Write-Host "Resetting Playwright MCP Environment..." -ForegroundColor Yellow
Write-Host "=" * 50 -ForegroundColor Gray

if ($Force) {
    Write-Host "⚠️  Force mode enabled - this will be destructive!" -ForegroundColor Red
    $confirm = Read-Host "Are you sure you want to continue? (y/N)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Host "Operation cancelled." -ForegroundColor Gray
        return
    }
}

# Stop all MCP processes
Write-Host "🛑 Stopping all MCP processes..." -ForegroundColor Yellow
& "$PSScriptRoot\stop_mcp.ps1" -Force

# Clear npm cache
Write-Host "🧹 Clearing npm cache..." -ForegroundColor Yellow
try {
    npm cache clean --force
    Write-Host "✅ npm cache cleared" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to clear npm cache: $_" -ForegroundColor Red
}

# Remove and reinstall MCP package
if ($Force) {
    Write-Host "🔄 Reinstalling Playwright MCP package..." -ForegroundColor Yellow
    try {
        npm uninstall -g @modelcontextprotocol/server-playwright 2>$null
        npm install -g @modelcontextprotocol/server-playwright
        Write-Host "✅ Playwright MCP package reinstalled" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to reinstall package: $_" -ForegroundColor Red
    }
}

# Clear browser data and reinstall browsers
Write-Host "🌐 Resetting Playwright browsers..." -ForegroundColor Yellow
try {
    if ($Force) {
        # Remove existing browser installations
        $playwrightCache = Join-Path $env:USERPROFILE ".cache\ms-playwright"
        if (Test-Path $playwrightCache) {
            Remove-Item $playwrightCache -Recurse -Force
            Write-Host "✅ Removed existing browser cache" -ForegroundColor Green
        }
    }
    
    # Reinstall browsers
    npx playwright install chromium
    Write-Host "✅ Browsers reinstalled" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to reset browsers: $_" -ForegroundColor Red
}

# Clear MCP cache directory
if (-not $KeepCache) {
    Write-Host "🗂️  Clearing MCP cache..." -ForegroundColor Yellow
    $cacheDir = ".mcp-cache"
    if (Test-Path $cacheDir) {
        try {
            Remove-Item $cacheDir -Recurse -Force
            Write-Host "✅ MCP cache cleared" -ForegroundColor Green
        } catch {
            Write-Host "❌ Failed to clear MCP cache: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "ℹ️  No MCP cache found" -ForegroundColor Cyan
    }
}

# Clear temporary files
Write-Host "🧹 Clearing temporary files..." -ForegroundColor Yellow
try {
    $tempPatterns = @(
        "*.tmp",
        "*.log",
        "playwright-*.json",
        "debug-*.txt"
    )
    
    foreach ($pattern in $tempPatterns) {
        Get-ChildItem -Path . -Name $pattern -ErrorAction SilentlyContinue | Remove-Item -Force
    }
    Write-Host "✅ Temporary files cleared" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to clear temporary files: $_" -ForegroundColor Red
}

# Reset any stuck Chrome processes
Write-Host "🔧 Cleaning up stuck browser processes..." -ForegroundColor Yellow
try {
    $stuckBrowsers = Get-Process chrome, chromium, msedge -ErrorAction SilentlyContinue | Where-Object {
        $_.Responding -eq $false
    }
    
    if ($stuckBrowsers.Count -gt 0) {
        $stuckBrowsers | ForEach-Object { $_.Kill() }
        Write-Host "✅ Cleaned up $($stuckBrowsers.Count) stuck browser process(es)" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  No stuck browser processes found" -ForegroundColor Cyan
    }
} catch {
    Write-Host "❌ Failed to clean up browser processes: $_" -ForegroundColor Red
}

Write-Host "=" * 50 -ForegroundColor Gray
Write-Host "🎉 Environment reset completed!" -ForegroundColor Green
Write-Host "💡 You can now run .\start_mcp.ps1 to start fresh" -ForegroundColor Cyan
