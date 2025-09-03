# Playwright MCP Server Documentation

This documentation captures all learnings, configurations, and best practices from using the Playwright MCP (Model Context Protocol) server for web automation tasks.

## Overview

The Playwright MCP server enables browser automation through Claude/AI agents, allowing for web scraping, form filling, navigation, and interaction with web applications. This setup was used to automate scholarship discovery and application processes on the UdeM bourses portal.

## Quick Links

- [Setup Guide](./setup.md) - Complete installation and configuration
- [Configuration Files](./config/) - All config files and templates
- [Usage Examples](./examples/) - Real-world usage patterns
- [Troubleshooting](./troubleshooting.md) - Common issues and solutions
- [Best Practices](./best_practices.md) - Lessons learned and recommendations

## Project Structure

```
.mcp/
├── playwright_general/
│   ├── README.md                 # This file
│   ├── setup.md                  # Installation and setup guide
│   ├── best_practices.md         # Usage recommendations
│   ├── troubleshooting.md        # Common issues and fixes
│   ├── config/
│   │   ├── package.json          # Node.js dependencies
│   │   ├── .playwright-mcprc     # MCP server config
│   │   └── browser_config.json   # Browser settings
│   ├── examples/
│   │   ├── navigation.md         # Navigation examples
│   │   ├── form_filling.md       # Form interaction patterns
│   │   ├── data_extraction.md    # Scraping techniques
│   │   └── authentication.md     # Login/session management
│   └── scripts/
│       ├── start_mcp.ps1         # PowerShell startup script
│       ├── cleanup.ps1           # Process cleanup script
│       └── test_connection.ps1   # Connection testing
```

## Key Capabilities Demonstrated

1. **Web Navigation & Interaction**
   - Page navigation and URL handling
   - Element clicking and form interaction
   - Text input and form submission

2. **Data Extraction & Scraping**
   - HTML element selection and data extraction
   - Table scraping and structured data collection
   - Dynamic content handling

3. **Session Management**
   - Login processes and authentication
   - Session persistence and cookie handling
   - Multi-step workflows

4. **Error Handling & Recovery**
   - Network error recovery
   - Element waiting and timeout handling
   - Process cleanup and restart procedures

## Next Steps

1. Review the [Setup Guide](./setup.md) for complete installation
2. Examine [Configuration Files](./config/) for project-specific settings
3. Study [Usage Examples](./examples/) for implementation patterns
4. Refer to [Best Practices](./best_practices.md) for optimization tips
