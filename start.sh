#!/bin/sh
set -e
cd "$(dirname "$0")"
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
[ -f .env ] || cp .env.example .env
python -m uvicorn app:app --host 127.0.0.1 --port 8000
