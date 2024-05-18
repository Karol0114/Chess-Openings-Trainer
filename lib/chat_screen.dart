import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String friendId;

  ChatScreen({required this.friendId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    User? user = auth.currentUser;
    if (user == null) {
      return Center(child: Text('No user logged in'));
    }

    var chatId = user.uid.compareTo(widget.friendId) < 0
        ? '${user.uid}_${widget.friendId}'
        : '${widget.friendId}_${user.uid}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: firestore
                  .collection('Chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    return ListTile(
                      title: Text(message['text']),
                      subtitle: Text(message['sender'] == user.uid
                          ? 'You'
                          : widget.friendId),
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
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Enter message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(user.uid, chatId);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String senderId, String chatId) async {
    if (_messageController.text.isNotEmpty) {
      var messageData = {
        'text': _messageController.text,
        'sender': senderId,
        'timestamp': FieldValue.serverTimestamp(),
      };

      var chatDoc = firestore.collection('Chats').doc(chatId);
      var chatSnapshot = await chatDoc.get();
      if (!chatSnapshot.exists) {
        await chatDoc.set({
          'members': [senderId, widget.friendId],
        });
      }

      await chatDoc.collection('messages').add(messageData);
      _messageController.clear();
    }
  }
}
