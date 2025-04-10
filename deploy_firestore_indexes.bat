@echo off
echo Deploying Firestore indexes for the e-commerce app...

REM Check if Firebase CLI is installed
where firebase >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
  echo Firebase CLI not installed. Please install it using npm:
  echo npm install -g firebase-tools
  exit /b 1
)

REM Check if user is logged in
firebase login:list >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
  echo Please log in to Firebase first:
  firebase login
)

REM Deploy the Firestore indexes
echo Deploying Firestore indexes...
firebase deploy --only firestore:indexes

if %ERRORLEVEL% EQU 0 (
  echo.
  echo Firestore indexes deployed successfully!
  echo.
  echo Note: It may take some time for indexes to be fully built on the Firebase servers.
) else (
  echo.
  echo Failed to deploy Firestore indexes. Please check the error messages above.
)

pause 