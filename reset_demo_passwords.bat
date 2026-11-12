@echo off
cd /d "%~dp0"
if exist ".venv\Scripts\python.exe" (
 ".venv\Scripts\python.exe" reset_demo_passwords.py
) else (
 python reset_demo_passwords.py
 if errorlevel 1 py -3 reset_demo_passwords.py
)
pause
