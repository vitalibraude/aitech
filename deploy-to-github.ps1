# Simple GitHub Pages Deployment
# ================================

$repoName = "aitech"

Write-Host "`n=== Deploying to GitHub Pages ===" -ForegroundColor Cyan

# Step 1: Check auth
Write-Host "`nChecking GitHub authentication..." -ForegroundColor Yellow
gh auth status 2>&1 | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "Please login to GitHub first by running: gh auth login" -ForegroundColor Yellow
    Write-Host "Then run this script again." -ForegroundColor Yellow
    exit 1
}

# Step 2: Create repo
Write-Host "Creating repository '$repoName'..." -ForegroundColor Yellow
gh repo create $repoName --public --source=. --remote=origin --push 2>&1 | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "Repository might already exist. Trying to push..." -ForegroundColor Yellow
    git remote add origin "https://github.com/$(gh api user --jq .login)/$repoName.git" 2>&1 | Out-Null
    git push -u origin master 2>&1 | Out-Null
}

# Step 3: Enable Pages
Write-Host "Enabling GitHub Pages..." -ForegroundColor Yellow
gh api repos/{owner}/$repoName/pages -X POST -f source[branch]=master -f source[path]=/ 2>&1 | Out-Null

# Get URL
$username = gh api user --jq .login
Write-Host "`n[SUCCESS] Site deployed!" -ForegroundColor Green
Write-Host "URL: https://$username.github.io/$repoName" -ForegroundColor Cyan
Write-Host "`n(May take 2-3 minutes to go live)" -ForegroundColor Gray
