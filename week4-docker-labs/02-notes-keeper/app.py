import os,sqlite3
from flask import Flask,request,redirect,render_template_string
app=Flask(__name__); DB=os.getenv('DATABASE_PATH','notes.db');
def init():
 c=sqlite3.connect(DB); c.execute('create table if not exists notes(id integer primary key,title text,content text)'); c.commit(); c.close()
HTML='''<h1>Notes Keeper</h1><form method="post" action="/notes"><input name="title" placeholder="Title" required><textarea name="content" placeholder="Content" required></textarea><button>Add</button></form><form><input name="q" placeholder="Search"><button>Search</button></form>{% for n in notes %}<article><h2><a href="/notes/{{n[0]}}">{{n[1]}}</a></h2><p>{{n[2]}}</p><form method="post" action="/notes/{{n[0]}}/delete"><button>Delete</button></form></article>{% endfor %}'''
@app.get('/')
def home():
 q=request.args.get('q','%'); c=sqlite3.connect(DB); notes=c.execute('select * from notes where title like ? or content like ? order by id desc',(f'%{q}%',f'%{q}%')).fetchall(); c.close(); return render_template_string(HTML,notes=notes)
@app.post('/notes')
def add():
 c=sqlite3.connect(DB); c.execute('insert into notes(title,content) values(?,?)',(request.form['title'],request.form['content'])); c.commit(); c.close(); return redirect('/')
@app.get('/notes/<int:i>')
def one(i):
 c=sqlite3.connect(DB); n=c.execute('select * from notes where id=?',(i,)).fetchone(); c.close(); return render_template_string('<h1>{{n[1]}}</h1><p>{{n[2]}}</p>',n=n), (200 if n else 404)
@app.post('/notes/<int:i>/delete')
def delete(i):
 c=sqlite3.connect(DB); c.execute('delete from notes where id=?',(i,)); c.commit(); c.close(); return redirect('/')
if __name__=='__main__': init(); app.run(host='0.0.0.0',port=5000)
