import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './message_bubble.dart';

class Messages extends StatelessWidget {
  Future<User> checkCurrentUser() async {
    User currentUser = FirebaseAuth.instance.currentUser;
    return currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
        future: checkCurrentUser(),
        builder: (ctx, futureSnapshot) {
          if (futureSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return StreamBuilder(
            builder: (ctx, chatSnapshot) {
              if (chatSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final chatDocs = chatSnapshot.data.docs;

              return ListView.builder(
                reverse: true,
                itemCount: chatDocs.length,
                itemBuilder: (ctx, index) => MessageBubble(
                  chatDocs[index]['text'],
                  chatDocs[index]['username'],
                  chatDocs[index]['userImage'],
                  chatDocs[index]['userId'] == futureSnapshot.data.uid,
                  key: ValueKey(chatDocs[index].documentID),
                ),
              );
            },
            stream: FirebaseFirestore.instance
                .collection('chat')
                .orderBy(
                  'createdAt',
                  descending: true,
                )
                .snapshots(),
          );
        });
  }
}
