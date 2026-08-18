from fastapi import FastAPI,WebSocket,WebSocketDisconnect
app=FastAPI(); users=set(); messages=[]; sockets=[]
@app.get('/api/messages')
def history(): return messages[-100:]
@app.get('/api/users')
def online(): return list(users)
@app.websocket('/ws/{username}')
async def chat(ws:WebSocket,username:str):
    await ws.accept(); users.add(username); sockets.append(ws)
    try:
        while True:
            item={'user':username,'message':await ws.receive_text()}; messages.append(item)
            for s in list(sockets):
                try: await s.send_json(item)
                except Exception: pass
    except WebSocketDisconnect: pass
    finally:
        users.discard(username)
        if ws in sockets: sockets.remove(ws)
