@echo off
echo ===============================
echo Git Sync Utility
echo ===============================

REM Use the directory where this batch file is located
cd /d "%~dp0" || (
    echo ❌ Could not change directory to %~dp0
    pause
    exit /b 1
)

REM Check if this is a Git repository
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
    echo ❌ This folder is not a Git repository.
    pause
    exit /b 1
)

echo Pulling latest changes from GitHub...
git pull origin main
if errorlevel 1 goto :error

echo Checking for local changes...
git status --porcelain > temp_git_status.txt

for %%A in (temp_git_status.txt) do (
    if %%~zA==0 (
        echo No local changes to commit.
        del temp_git_status.txt
        goto :end
    )
)

del temp_git_status.txt

echo.
set /p commitMessage=Enter commit message (leave blank to cancel): 

if "%commitMessage%"=="" (
    echo Commit cancelled.
    goto :end
)

echo Staging changes...
git add .

echo Committing changes...
git commit -m "%commitMessage%"
if errorlevel 1 goto :error

echo Pushing to GitHub...
git push origin main
if errorlevel 1 goto :error

:end
echo ===============================
echo Git sync complete.
pause
exit /b

:error
echo.
echo ❌ An error occurred. Check the messages above.
pause
exit /b 1
