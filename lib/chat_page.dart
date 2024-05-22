import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatPage extends StatelessWidget {
  final String friendId;
  final String friendName;

  const ChatPage({required this.friendId, required this.friendName, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with $friendName'),
      ),
      body: ChatScreen(friendId: friendId, friendName: friendName),
    );
  }
}
