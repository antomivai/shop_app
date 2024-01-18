import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';
import '../widgets/message_input.dart';
import '../widgets/messages.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final fbm = FirebaseMessaging.instance;
    fbm.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Support'),
      ),
      drawer: AppDrawer(),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(child: Messages()),
            MessageInput(),
          ],
        ),
      ),
    );
  }
}
