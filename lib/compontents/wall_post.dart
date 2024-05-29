import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'comment.dart';

class WallPost extends StatelessWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;
  final bool isLiked;
  final void Function(bool) onLikeTap;
  final VoidCallback onCommentsLoaded;

  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.time,
    required this.postId,
    required this.likes,
    required this.isLiked,
    required this.onLikeTap,
    required this.onCommentsLoaded,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0),
      child: Card(
        color: Colors.grey[350],
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[400],
                    child: Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      user,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => onLikeTap(!isLiked),
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.grey,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    likes.length.toString(),
                    style: TextStyle(color: Colors.black),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () => showCommentDialog(context),
                    child: Row(
                      children: [
                        Icon(Icons.comment, color: Colors.grey[600]),
                        SizedBox(width: 10),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("User Posts")
                              .doc(postId)
                              .collection("comments")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              int commentsCount = snapshot.data!.docs.length;
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                onCommentsLoaded();
                              });
                              return Text(
                                commentsCount.toString(),
                                style: TextStyle(color: Colors.grey[600]),
                              );
                            } else {
                              return Text(
                                '0',
                                style: TextStyle(color: Colors.grey[600]),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .doc(postId)
                    .collection("comments")
                    .orderBy("CommentTime", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  List<Widget> commentWidgets = snapshot.data!.docs.map((doc) {
                    final commentData = doc.data() as Map<String, dynamic>;
                    final commenterUid = commentData['CommentedBy'] ?? '';
                    return FutureBuilder<String>(
                      future: getUsernameByUid(commenterUid),
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                              "Błąd ładowania danych: ${snapshot.error}");
                        } else if (snapshot.hasData) {
                          final username = snapshot.data ?? 'Anonim';
                          return Comment(
                            text: commentData["CommentText"] ??
                                'Brak tekstu komentarza',
                            user: username,
                            time: commentData["CommentTime"]
                                as Timestamp, // Przekazywanie obiektu Timestamp
                          );
                        } else {
                          return const Text('Brak danych');
                        }
                      },
                    );
                  }).toList();
                  return ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: commentWidgets,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showCommentDialog(BuildContext context) {
    TextEditingController _commentTextController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add comment"),
        content: TextField(
          controller: _commentTextController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: InputDecoration(hintText: "Write a comment..."),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _commentTextController.clear();
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              addComment(_commentTextController.text);
              Navigator.pop(context);
              _commentTextController.clear();
            },
            child: Text("Post"),
          ),
        ],
      ),
    );
  }

  void addComment(String commentText) {
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(postId)
        .collection("comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": FirebaseAuth.instance.currentUser!.uid,
      "CommentTime": Timestamp.now(),
    });
  }

  Future<String> getUsernameByUid(String uid) async {
    final usersRef = FirebaseFirestore.instance.collection('Users');
    final querySnapshot = await usersRef.doc(uid).get();
    if (querySnapshot.exists) {
      final userData = querySnapshot.data();
      return userData?['username'] ?? 'nieznany';
    }
    return 'nieznany';
  }

  String formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('dd-MM HH:mm').format(date);
  }
}
