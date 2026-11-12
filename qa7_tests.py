import tempfile,shutil,asyncio
from pathlib import Path
from fastapi.testclient import TestClient
import app
orig=app.DB
with tempfile.TemporaryDirectory() as tmp:
 app.DB=Path(tmp)/'db.sqlite';shutil.copy2(orig,app.DB)
 try:
  with TestClient(app.app) as c:
   login=c.post('/api/auth/login',json={'email':'director@fotoprint.by','password':'DirectorDemo2026!'})
   assert login.status_code==200,login.text
   prompts=['Привет, что умеешь?','Покажи KPI и статистику','Какие задачи просрочены?','Покажи активные задачи','Что я упустил?','Какие сроки на ближайшие 3 дня?','Кому нужно напомнить?','Подготовь повестку совещания','Найди регламент','Сформируй отчёт PDF','Создай задачу']
   app.os.environ['ALLOW_EXTERNAL_AI']='false'
   async def no_ollama():return None
   app.ollama_model=no_ollama
   for p in prompts:
    r=c.post('/api/chat',json={'message':p});assert r.status_code==200,(p,r.text)
    j=r.json();assert j['answer'] and j['mode']=='rules',(p,j)
    print('PASS',p,'=>',j['answer'][:85].replace('\n',' '))
   assert c.get('/api/reports/summary.pdf').content.startswith(b'%PDF')
   print('PASS PDF')
 finally:app.DB=orig
