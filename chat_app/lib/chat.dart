import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:chat_app/global.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final String myUsername;
  const ChatScreen({
    Key key,
    this.myUsername,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController inputController = TextEditingController();
  SocketIO socketIO;
  IO.Socket socket;
  List<Map<String, dynamic>> messages = [];

  void socketIOConnect() {
    print("Starting connecting");
    //Creating the socket
    socketIO = SocketIOManager().createSocketIO(
      'ws://127.0.0.1:5000',
      '/',
    );
    //Call init before doing anything with socket
    socketIO.init();
    //Subscribe to an event to listen to
    socketIO.subscribe('massage', (jsonData) {
      //Convert the JSON data received into a Map
      Map<String, dynamic> data = json.decode(jsonData);
      this.setState(() => messages.add(data));
    });
    //Connect to the socket
    socketIO.connect().then((value) => print("I am in"));
  }

  void socketIOSendMassage(text) {
    print("send message");
    Map data = {"time": DateTime.now().millisecondsSinceEpoch, "data": text, "username": widget.myUsername};
    socketIO.sendMessage("message", jsonEncode(data));
  }

  void socketIODisconnect() {
    print("disconnet");
    socketIO.disconnect();
  }

  void iOConnect() {
    socket = IO.io('ws://localhost:5000');
    socket.on('connect', (_) {
      print('IO connect');
      socket.emit("massage", jsonEncode({"data": "${widget.myUsername} joined", "time": DateTime.now().toIso8601String(), "username": "Chat system"}));
    });
    socket.on('massage', (jsonData) => addMeassage(jsonData));
    socket.on('disconnect', (_) => print('disconnect'));
    socket.connect();
    socket.emit("i new", widget.myUsername);
    print("io connect");
  }

  void iODisconnect() {
    socket.disconnect();
    print("IO disconnected");
  }

  void iOSendMassage(text) {
    print("send message");
    Map data = {"time": DateTime.now().millisecondsSinceEpoch, "data": text, "username": widget.myUsername};
    socket.emit("massage", data);
    inputController.clear();
  }

  void addMeassage(jsonData) {
    print(jsonData);
    //Convert the JSON data received into a Map
    Map<String, dynamic> data = json.decode(jsonData);
    this.setState(() => messages.add(data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black54),
        title: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            CircleAvatar(
              //imgUrl: friendsList[0]['imgUrl'],
              child: Text("GT"),
            ),
            SizedBox(width: 15),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Cybdom Tech",
                  style: Theme.of(context).textTheme.subtitle1,
                  overflow: TextOverflow.clip,
                ),
                Text(
                  "Online",
                  style: Theme.of(context).textTheme.subtitle2.apply(
                        color: myGreen,
                  ),
                )
              ],
            )
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.link),
            onPressed: () {iOConnect();},
          ),
          IconButton(
            icon: Icon(Icons.link_off),
            onPressed: () {iODisconnect();},
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: messages.length,
                    itemBuilder: (context, index){
                      if (messages[index]["username"] == widget.myUsername){
                        return ReceivedMessagesWidget(message: messages[index]);
                      } else {
                        return SentMessageWidget(message: messages[index]);
                      }
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(15.0),
                  height: 61,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(35.0),
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 3),
                                  blurRadius: 5,
                                  color: Colors.grey)
                            ],
                          ),
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 16.0,),
                              Expanded(
                                child: TextField(
                                  controller: inputController,
                                  decoration: InputDecoration(
                                      hintText: "Type Something...",
                                      border: InputBorder.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Container(
                        padding: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                            color: myGreen, shape: BoxShape.circle),
                        child: InkWell(
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                          onTap: () {
                            iOSendMassage(inputController.value.text);
                          },
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
