# MCP Fetch Server Troubleshooting

## Problem
The MCP fetch server fails with: `Failed to fetch robots.txt ... due to a connection issue`

## Root Causes

### 1. JavaScript-Heavy Sites (AWS Workshop)
The AWS Workshop site is a React Single Page Application (SPA) that loads content dynamically. The MCP fetch tool only retrieves static HTML and doesn't execute JavaScript.

**Solution**: View the page in a browser or use a headless browser tool.

### 2. Network/Proxy Issues
If you're behind a corporate proxy or firewall, the Python MCP server might not have proper proxy configuration.

**Solution**: Configure proxy in MCP settings.

### 3. SSL Certificate Issues
The Python requests library might have SSL verification problems.

**Solution**: Update certificates or configure SSL settings.

## Fixes

### Fix 1: Update MCP Configuration with Proxy

Edit `~/.kiro/settings/mcp.json`:

```json
{
  "mcpServers": {
    "fetch": {
      "command": "python",
      "args": ["-m", "mcp_server_fetch"],
      "env": {
        "HTTP_PROXY": "http://your-proxy:port",
        "HTTPS_PROXY": "http://your-proxy:port",
        "NO_PROXY": "localhost,127.0.0.1"
      },
      "autoApprove": [],
      "disabled": false
    }
  }
}
```

### Fix 2: Disable SSL Verification (Not Recommended for Production)

```json
{
  "mcpServers": {
    "fetch": {
      "command": "python",
      "args": ["-m", "mcp_server_fetch"],
      "env": {
        "PYTHONHTTPSVERIFY": "0",
        "REQUESTS_CA_BUNDLE": ""
      },
      "autoApprove": [],
      "disabled": false
    }
  }
}
```

### Fix 3: Update Python Certificates

```powershell
# Update certifi package
pip install --upgrade certifi requests

# Or use system certificates
pip install --upgrade pip-system-certs
```

### Fix 4: Use Alternative Fetch Method

Since the AWS Workshop is a SPA, use PowerShell instead:

```powershell
# Run the fetch script
.\scripts\fetch-workshop-content.ps1

# Or manually with Invoke-WebRequest
Invoke-WebRequest -Uri "https://catalog.us-east-1.prod.workshops.aws/workshops/ee59d21b-4cb8-4b3d-a629-24537cf37bb5/en-US/lab1" -UseBasicParsing
```

## Workaround: Manual Content Extraction

Since the workshop site requires JavaScript:

1. **Open in Browser**: Visit the URL in Chrome/Edge
2. **View Page Source**: Right-click → View Page Source
3. **Extract Data Requirements**: Look for data schema in the instructions
4. **Copy Relevant Sections**: Copy the text content you need

## Testing MCP Fetch

Test if MCP fetch works with a simple site:

```bash
# Test with a simple static site
curl https://example.com
```

If this works but AWS Workshop doesn't, it confirms the JavaScript issue.

## Alternative: Use Browser DevTools

1. Open the workshop page in browser
2. Press F12 to open DevTools
3. Go to Network tab
4. Look for API calls that load the actual content
5. Copy the API response data

## Recommended Approach for AWS Workshop

**Don't rely on MCP fetch for this site.** Instead:

1. **View in Browser**: Open the workshop URL in your browser
2. **Read Instructions**: Manually read the lab requirements
3. **Copy Data Schema**: Note the required data structure
4. **Share with AI**: Copy the relevant text and paste it in chat

This is more reliable than trying to scrape a JavaScript-heavy SPA.

## Verification

Test your MCP fetch configuration:

```powershell
# Check if Python can access the site
python -c "import requests; print(requests.get('https://catalog.us-east-1.prod.workshops.aws/robots.txt').status_code)"

# Should print: 200
```

If this fails, you have a Python/network configuration issue.

## Summary

The MCP fetch server issue with AWS Workshop is expected behavior because:
- ✗ The site is a JavaScript SPA
- ✗ MCP fetch doesn't execute JavaScript
- ✓ The site is accessible (verified with PowerShell)
- ✓ Use browser to view content instead

**Recommendation**: Open the workshop in your browser and manually review the Lab 1 requirements, then share them here.
