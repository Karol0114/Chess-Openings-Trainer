import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      body: ChatScreen(friendId: friendId),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String friendId;

  ChatScreen({required this.friendId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    User? user = auth.currentUser;
    if (user == null) {
      print('User not logged in');
      return Center(child: Text('User not logged in'));
    }

    var chatId = user.uid.compareTo(widget.friendId) < 0
        ? '${user.uid}_${widget.friendId}'
        : '${widget.friendId}_${user.uid}';

    print('Chat ID: $chatId');

    return Column(
      children: [
        Expanded(
          child: StreamBuilder(
            stream: firestore
                .collection('Chats')
                .doc(chatId)
                .collection('messages')
                .orderBy('timestamp')
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              print('StreamBuilder state: ${snapshot.connectionState}');
              if (snapshot.connectionState == ConnectionState.waiting) {
                print('Waiting for messages...');
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                print('Error: ${snapshot.error}');
                return Center(child: Text('Error loading messages'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                print('No messages found');
                return Center(child: Text('No messages found'));
              }

              var messages = snapshot.data!.docs;
              print('Messages loaded: ${messages.length}');

              return ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  var message = messages[index];
                  return ListTile(
                    title: Text(message['text']),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    labelText: 'Enter message',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () async {
                  if (messageController.text.isNotEmpty) {
                    print('Sending message: ${messageController.text}');
                    try {
                      await firestore
                          .collection('Chats')
                          .doc(chatId)
                          .collection('messages')
                          .add({
                        'text': messageController.text,
                        'timestamp': FieldValue.serverTimestamp(),
                        'senderId': user.uid,
                      });
                      print('Message sent successfully');
                      messageController.clear();
                    } catch (e) {
                      print('Failed to send message: $e');
                    }
                  } else {
                    print('Message text is empty');
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
