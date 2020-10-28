from flask import Flask, render_template
from flask_socketio import SocketIO, Namespace
import json

app = Flask(__name__)
app.config['SECRET_KEY'] = 'vnkdjnfjknfl1232#'
socketio = SocketIO(app)

users = []

@app.route('/')
def deshboard():
    return render_template('session.html')

@socketio.on('i new')
def new_user(username):
    users.append(username)
    print(f"New user joined {username}")

@socketio.on('massage')
def send_massage(msg):
    print(f"Send massage {msg}")
    socketio.send(msg, True)

if __name__ == '__main__':
    socketio.run(app, debug=True)