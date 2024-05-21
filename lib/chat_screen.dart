import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String friendId;
  final String friendName;

  ChatScreen({required this.friendId, required this.friendName});

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
      return Center(child: Text('User not logged in'));
    }

    var chatId = user.uid.compareTo(widget.friendId) < 0
        ? '${user.uid}_${widget.friendId}'
        : '${widget.friendId}_${user.uid}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.friendName}'),
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error loading messages'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages found'));
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    var messageText = message['text'] ?? '';
                    var messageSender = message['sender'] ?? '';
                    var messageTimestamp = message['timestamp'] != null
                        ? (message['timestamp'] as Timestamp).toDate()
                        : DateTime.now();

                    bool isMe = messageSender == user.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.lightBlueAccent : Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5.0,
                              spreadRadius: 1.0,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMe ? 'You' : widget.friendName,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: isMe ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              messageText,
                              style: TextStyle(
                                fontSize: 15.0,
                                color: isMe ? Colors.white : Colors.black54,
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              DateFormat('hh:mm a').format(messageTimestamp),
                              style: TextStyle(
                                fontSize: 12.0,
                                color: isMe ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
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
    if (messageController.text.isNotEmpty) {
      var messageData = {
        'text': messageController.text,
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
      messageController.clear();
    }
  }
}
