@echo off
setlocal
where ollama >nul 2>nul
if errorlevel 1 (
 echo Ollama is not installed. Install it from https://ollama.com/download/windows
 echo Then run this file again.
 pause
 exit /b 1
)
echo Downloading local model llama3.2 (internet required, several GB may be needed)...
ollama pull llama3.2
if errorlevel 1 (
 echo Model download failed. Check internet and disk space.
 pause
 exit /b 1
)
echo Model ready. Start Ollama, then start.bat.
pause
