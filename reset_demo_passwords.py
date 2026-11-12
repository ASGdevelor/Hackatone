"""Restore published demo passwords without deleting corporate demo data."""
import sqlite3
from pathlib import Path
from app import password_hash

accounts = {
 'director@fotoprint.by':'DirectorDemo2026!',
 'petrov@fotoprint.by':'ManagerDemo2026!',
 'sidorov@fotoprint.by':'DeputyDemo2026!',
 'smirnova@fotoprint.by':'SalesHeadDemo2026!',
 'kuznetsov@fotoprint.by':'SalesDeputyDemo2026!',
}
db=Path(__file__).parent/'data'/'app.db'
if not db.exists():
 raise SystemExit('База не найдена. Сначала запустите start.bat')
with sqlite3.connect(db) as c:
 for email,password in accounts.items():
  user=c.execute('SELECT id FROM users WHERE lower(email)=?',(email,)).fetchone()
  if not user: raise SystemExit(f'Нет тестового пользователя: {email}')
  c.execute('INSERT INTO auth_credentials(user_id,password_hash,failed,locked_until) VALUES(?,?,0,0) ON CONFLICT(user_id) DO UPDATE SET password_hash=excluded.password_hash,failed=0,locked_until=0',(user[0],password_hash(password)))
 c.execute('DELETE FROM auth_sessions')
print('Тестовые пароли восстановлены. Документы, задачи и встречи сохранены.')
