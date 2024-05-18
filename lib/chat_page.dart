import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatPage extends StatelessWidget {
  final String friendId;
  final String friendName;

  ChatPage({required this.friendId, required this.friendName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with $friendName'),
      ),
      body: ChatScreen(friendId: friendId),
    );
  }
}
