import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  const MessageInput({Key? key}) : super(key: key);

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  var _enteredMessage = '';
  final _textController = TextEditingController();

  Future<void> _sendMessage() async {
    FocusScope.of(context).unfocus();
    final currentUser = FirebaseAuth.instance.currentUser;
    final docSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .get();
    final userData = docSnap.data() as Map<String, dynamic>;

    FirebaseFirestore.instance
        .collection('chats/6LxYzOgAzDIpUXSwefXF/messages')
        .add({
      'text': _enteredMessage,
      'createdDate': Timestamp.now(),
      'userId': currentUser?.uid,
      'email': userData['email'],
      'userAvatarUrl': userData['avatar_url'],
    });

    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
              child: TextField(
            controller: _textController,
            decoration: InputDecoration(labelText: 'Send a message...'),
            onChanged: (value) {
              setState(() {
                _enteredMessage = value;
              });
            },
          )),
          IconButton(
            color: Theme.of(context).primaryColor,
            icon: Icon(Icons.send),
            onPressed: _enteredMessage.trim().isEmpty ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}
