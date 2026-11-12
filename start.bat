@echo off
setlocal EnableExtensions
cd /d "%~dp0"
set "PYTHON_CMD="
rem Prefer Python 3.11, but do not fail if another supported Python is installed.
py -3.11 -c "import sys" >nul 2>nul
if not errorlevel 1 set "PYTHON_CMD=py -3.11"
if not defined PYTHON_CMD (
  python -c "import sys; assert sys.version_info >= (3,11)" >nul 2>nul
  if not errorlevel 1 set "PYTHON_CMD=python"
)
if not defined PYTHON_CMD (
  py -3 -c "import sys; assert sys.version_info >= (3,11)" >nul 2>nul
  if not errorlevel 1 set "PYTHON_CMD=py -3"
)
if not defined PYTHON_CMD (
 echo ERROR: Python 3.11 or newer is required. Check: python --version and py -0p
 pause
 exit /b 1
)
echo Using: %PYTHON_CMD%
rem Reuse a valid environment, otherwise create one without deleting user data.
if exist ".venv\Scripts\python.exe" (
  ".venv\Scripts\python.exe" -c "import sys" >nul 2>nul
  if errorlevel 1 (
    echo Existing virtual environment is broken. Recreating it...
    rmdir /s /q ".venv"
  )
)
if not exist ".venv\Scripts\python.exe" (
  %PYTHON_CMD% -m venv .venv
  if errorlevel 1 (
    echo ERROR: Could not create virtual environment.
    pause
    exit /b 1
  )
)
".venv\Scripts\python.exe" -m pip install -r requirements.txt
if errorlevel 1 (
 echo ERROR: Could not install dependencies. Check internet access.
 pause
 exit /b 1
)
if not exist ".env" copy ".env.example" ".env" >nul
echo.
echo Starting AI Manager at http://127.0.0.1:8000
echo Health check: http://127.0.0.1:8000/api/health
".venv\Scripts\python.exe" -m uvicorn app:app --host 127.0.0.1 --port 8000
if errorlevel 1 echo ERROR: Server failed. Another server may be using port 8000.
pause
