import 'package:chess_openings_trainer/compontents/wall_post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chess_openings_trainer/compontents/text_field.dart';
import 'package:intl/intl.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final ScrollController _scrollController = ScrollController();
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textController = TextEditingController();
  String? username;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _fetchUsername() async {
    try {
      print("fetching username for uid: ${currentUser.uid}");
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();
      if (userDoc.exists) {
        print("user document data: ${userDoc.data()}");
        if (userDoc.data()?['username'] != null) {
          setState(() {
            username = userDoc.data()?['username'];
            print("fetched username: $username");
          });
        } else {
          print("username is null in the document");
        }
      } else {
        print("user document does not exist for uid: ${currentUser.uid}");
      }
    } catch (e) {
      print("error fetching username: $e");
    }
  }

  void postMessage() {
    if (textController.text.isNotEmpty && username != null) {
      FirebaseFirestore.instance.collection("User Posts").add({
        'Username': username,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
      textController.clear();
      _scrollToBottom(); // Scroll to bottom after posting a new message
    }
  }

  void onLikeTap(String postId, bool isLiked) {
    DocumentReference postRef =
        FirebaseFirestore.instance.collection("User Posts").doc(postId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot postSnapshot = await transaction.get(postRef);
      if (!postSnapshot.exists) {
        throw Exception("post does not exist");
      }
      if (isLiked) {
        transaction.update(postRef, {
          'Likes': FieldValue.arrayUnion([currentUser.uid])
        });
      } else {
        transaction.update(postRef, {
          'Likes': FieldValue.arrayRemove([currentUser.uid])
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Community'),
        ),
        body: Center(
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("User Posts")
                      .orderBy(
                        "TimeStamp",
                        descending: false,
                      )
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => _scrollToBottom());
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot documentSnapshot =
                              snapshot.data!.docs[index];
                          Map<String, dynamic> post =
                              documentSnapshot.data() as Map<String, dynamic>;
                          String postId = documentSnapshot.id;

                          final DateTime postTime =
                              (post['TimeStamp'] as Timestamp).toDate();
                          final String formattedTime =
                              DateFormat('dd-MM HH:mm').format(postTime);
                          List<String> likes =
                              List<String>.from(post['Likes'] ?? []);
                          bool isCurrentPostLiked =
                              likes.contains(currentUser.uid);

                          return WallPost(
                              message: post['Message'],
                              user: post['Username'] ?? 'Unknown',
                              time: formattedTime,
                              postId: postId,
                              likes: likes,
                              isLiked: isCurrentPostLiked,
                              onLikeTap: (bool isLiked) {
                                onLikeTap(postId, isLiked);
                              },
                              onCommentsLoaded: _scrollToBottom);
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error:${snapshot.error}'),
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: MyTextField(
                        controller: textController,
                        hintText: 'Write something here!',
                        obscureText: false,
                        maxLines: null,
                      ),
                    ),
                    IconButton(
                        onPressed: postMessage,
                        icon: const Icon(Icons.arrow_circle_up))
                  ],
                ),
              ),
              Text(
                "Logged in as: " + (username ?? 'Unknown'),
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(
                height: 50,
              )
            ],
          ),
        ));
  }
}
