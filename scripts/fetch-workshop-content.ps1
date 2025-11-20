# PowerShell script to fetch AWS Workshop content
# Since the MCP fetch server has issues with the workshop site

param(
    [string]$WorkshopUrl = "https://catalog.us-east-1.prod.workshops.aws/workshops/ee59d21b-4cb8-4b3d-a629-24537cf37bb5/en-US/lab1/create-crawler-console",
    [string]$OutputFile = "workshop-lab1-content.html"
)

Write-Host "Fetching workshop content from: $WorkshopUrl" -ForegroundColor Green

try {
    # Fetch the content
    $response = Invoke-WebRequest -Uri $WorkshopUrl -UseBasicParsing -ErrorAction Stop
    
    # Save to file
    $response.Content | Out-File -FilePath $OutputFile -Encoding UTF8
    
    Write-Host "✓ Content saved to: $OutputFile" -ForegroundColor Green
    Write-Host "  Status Code: $($response.StatusCode)" -ForegroundColor Cyan
    Write-Host "  Content Length: $($response.Content.Length) characters" -ForegroundColor Cyan
    
    # Try to extract any useful information
    Write-Host "`nNote: This is a React SPA - the actual content loads via JavaScript." -ForegroundColor Yellow
    Write-Host "You may need to view the page in a browser to see the full content." -ForegroundColor Yellow
    
} catch {
    Write-Host "✗ Error fetching content: $_" -ForegroundColor Red
    exit 1
}
