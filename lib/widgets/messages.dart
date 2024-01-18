import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/message_bubble.dart';

class Messages extends StatelessWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chats/6LxYzOgAzDIpUXSwefXF/messages')
          .orderBy('createdDate', descending: true)
          .snapshots(),
      builder: (ctx, AsyncSnapshot<QuerySnapshot<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = snapshot.data?.docs;
        final currentUser = FirebaseAuth.instance.currentUser;
        final username =
            currentUser!.email == null ? currentUser.email : currentUser.uid;
        return ListView.builder(
          reverse: true,
          itemCount: chatDocs?.length,
          itemBuilder: (ctx, index) => MessageBubble(
            username!,
            chatDocs?[index]['text'],
            chatDocs?[index]['userAvatarUrl'],
            chatDocs?[index]['userId'] == currentUser.uid,
            key: ValueKey(chatDocs?[index].id),
          ),
        );
      },
    );
  }
}
