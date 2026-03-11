@echo off
chcp 65001 >nul
echo.
echo ================================
echo   GitHub Pages Setup  
echo ================================
echo.

REM Refresh PATH
set "PATH=%PATH%;C:\Program Files\GitHub CLI"

echo [1/3] Authenticating with GitHub...
echo.
echo After running this, a code will appear.
echo Copy it and press Enter to open browser.
echo Paste the code in GitHub.
echo.
pause

gh auth login --web --git-protocol https

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Error: Authentication failed.
    echo Please try again.
    pause
    exit /b 1
)

echo.
echo [2/3] Creating repository...
gh repo create aitech --public --source=. --remote=origin --push

if %ERRORLEVEL% NEQ 0 (
    echo Repository might exist. Trying to push...
    git remote add origin https://github.com/$(gh api user --jq .login)/aitech.git 2>nul
    git push -u origin master
)

echo.
echo [3/3] Enabling GitHub Pages...
gh api repos/{owner}/aitech/pages -X POST -f source[branch]=master -f source[path]=/

echo.
echo ================================
echo SUCCESS! Site is being deployed
echo ================================
echo.
for /f "tokens=*" %%i in ('gh api user --jq .login') do set USERNAME=%%i
echo Your site will be at:
echo https://%USERNAME%.github.io/aitech
echo.
echo (Takes 2-3 minutes to go live)
echo.
pause
