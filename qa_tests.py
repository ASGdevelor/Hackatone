"""Integration tests on a disposable copy of the database (never touches real data)."""
import tempfile,shutil,sqlite3,os
from pathlib import Path
from fastapi.testclient import TestClient
import app
original=app.DB
with tempfile.TemporaryDirectory() as td:
 app.DB=Path(td)/'test.db';shutil.copy2(original,app.DB)
 try:
  with TestClient(app.app) as client:
   checks=[]
   def check(label,cond):
    checks.append((label,bool(cond)));print(('PASS' if cond else 'FAIL'),label)
   h=client.get('/api/health');check('health/version/500 docs',h.status_code==200 and h.json()['documents']==500)
   check('unauthenticated dashboard denied',client.get('/api/dashboard').status_code==401)
   accounts=[('director@fotoprint.by','DirectorDemo2026!'),('petrov@fotoprint.by','ManagerDemo2026!'),('sidorov@fotoprint.by','DeputyDemo2026!'),('smirnova@fotoprint.by','SalesHeadDemo2026!'),('kuznetsov@fotoprint.by','SalesDeputyDemo2026!')]
   for email,pwd in accounts:
    r=client.post('/api/auth/login',json={'email':email,'password':pwd});check('login '+email,r.status_code==200)
    check('session '+email,client.get('/api/auth/me').status_code==200)
    client.post('/api/auth/logout')
   r=client.post('/api/auth/login',json={'email':accounts[0][0],'password':'wrong'});check('wrong password denied',r.status_code==401)
   client.post('/api/auth/login',json={'email':accounts[0][0],'password':accounts[0][1]})
   check('director 500 documents',len(client.get('/api/documents').json())==500)
   for endpoint in ('dashboard','tasks','meetings','events','audit','ai/status'):
    check('director '+endpoint,client.get('/api/'+endpoint).status_code==200)
   check('local chat',client.post('/api/chat',json={'message':'Какие задачи просрочены?'}).status_code==200)
   meeting=client.get('/api/meetings').json()[0]
   check('meeting analysis',client.get('/api/meeting/'+str(meeting['meeting_id'])+'/analysis').status_code==200)
   proposal=client.post('/api/proposals',json={'kind':'task','payload':{'title':'QA cancel test'}})
   check('proposal created',proposal.status_code==200)
   pid=proposal.json()['id'];check('cancel proposal',client.post(f'/api/proposals/{pid}/cancel').status_code==200)
   proposal=client.post('/api/proposals',json={'kind':'task','payload':{'title':'QA confirmed task','owner_id':3}})
   check('confirm task',client.post(f"/api/proposals/{proposal.json()['id']}/confirm").status_code==200)
   client.post('/api/auth/logout')
   client.post('/api/auth/login',json={'email':accounts[2][0],'password':accounts[2][1]})
   check('deputy restricted docs',len(client.get('/api/documents').json())<500)
   check('deputy cannot create task',client.post('/api/proposals',json={'kind':'task','payload':{'title':'forbidden'}}).status_code==403)
   c=app.conn();secret=c.execute("SELECT doc_id FROM documents_meta WHERE department='hr' LIMIT 1").fetchone()['doc_id'];c.close()
   check('deputy forbidden HR document',client.get(f'/api/documents/{secret}').status_code==403)
   own=next((t for t in client.get('/api/tasks').json() if t['owner_id']==3),None)
   if own:
    p=client.post('/api/proposals',json={'kind':'task_status','payload':{'task_id':own['task_id'],'status':'done'}})
    check('deputy status proposal',p.status_code==200)
    if p.status_code==200:check('deputy status confirm',client.post(f"/api/proposals/{p.json()['id']}/confirm").status_code==200)
   else:check('deputy has assigned task',False)
   print('TOTAL',sum(ok for _,ok in checks),'/',len(checks))
   if not all(ok for _,ok in checks):raise SystemExit(1)
 finally:app.DB=original
