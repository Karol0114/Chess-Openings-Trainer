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
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    User? user = auth.currentUser;
    if (user == null) {
      return Center(child: Text('User not logged in'));
    }

    var chatId = user.uid.compareTo(widget.friendId) < 0
        ? '${user.uid}_${widget.friendId}'
        : '${widget.friendId}_${user.uid}';

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
              List<Widget> messageWidgets = [];
              DateTime? lastMessageDate;

              for (var message in messages) {
                var messageText = message['text'] ?? '';
                var messageSender = message['senderId'] ?? 'unknown';
                var messageTimestamp = message['timestamp'] != null
                    ? (message['timestamp'] as Timestamp).toDate()
                    : DateTime.now();

                bool isMe = messageSender == user.uid;
                DateTime messageDate = DateTime(
                  messageTimestamp.year,
                  messageTimestamp.month,
                  messageTimestamp.day,
                );

                if (lastMessageDate == null ||
                    lastMessageDate!.difference(messageDate).inDays != 0) {
                  messageWidgets.add(
                    Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 10.0),
                        padding: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          DateFormat('dd.MM.yyyy').format(messageDate),
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  );
                  lastMessageDate = messageDate;
                }

                messageWidgets.add(
                  Align(
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
                            DateFormat('HH:mm').format(messageTimestamp),
                            style: TextStyle(
                              fontSize: 12.0,
                              color: isMe ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return ListView(
                controller: _scrollController,
                reverse: true,
                children: messageWidgets.reversed.toList(),
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
                  maxLines: null, // Allow multiple lines
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
    );
  }

  void _sendMessage(String senderId, String chatId) async {
    if (messageController.text.isNotEmpty) {
      var messageData = {
        'text': messageController.text,
        'senderId': senderId,
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
      _scrollToBottom(); // Scroll to bottom after sending message
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}
