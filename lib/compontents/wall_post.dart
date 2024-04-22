import 'package:chess_openings_trainer/compontents/comment.dart';
import 'package:chess_openings_trainer/compontents/like_button.dart';
import 'package:chess_openings_trainer/helper/helper_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<String> getUsernameByUid(String uid) async {
  print('getUsernameByUid called with uid: $uid');

  final usersRef = FirebaseFirestore.instance.collection('Users');
  final querySnapshot = await usersRef.doc(uid).get();

  if (querySnapshot.exists) {
    final userData = querySnapshot.data();
    final username = userData?['username'] ??
        'nieznany'; // Zakładając, że pole w dokumencie to 'username'
    print('Username found: $username');
    return username;
  }

  print('No matching username found, returning "nieznany"');
  return 'nieznany';
}

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;
  final bool isLiked;
  final void Function(bool) onLikeTap;

  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.time,
    required this.postId,
    required this.likes,
    required this.isLiked,
    required this.onLikeTap,
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  final _commentTextController = TextEditingController();
  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.uid);
    checkIfLiked();
  }

  void checkIfLiked() async {
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    DocumentSnapshot snapshot = await postRef.get();
    if (snapshot.exists) {
      Map<String, dynamic> postData = snapshot.data() as Map<String, dynamic>;
      List<String> likesList = List<String>.from(postData['Likes'] ?? []);
      setState(() {
        isLiked = likesList.contains(currentUser.uid);
      });
    }
  }

  void toggleLike() async {
    final newIsLiked = !isLiked;
    setState(() {
      isLiked = newIsLiked;
    });
    widget.onLikeTap(newIsLiked);

    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (newIsLiked) {
      await postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.uid])
      });
    } else {
      await postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.uid])
      });
    }
  }

// add a comment
  void addComment(String commentText) {
    //write the comment to firestore under comments collection for this post
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.uid,
      "CommentTime": Timestamp.now() // remember
    });
  }

// show a dialog box for adding comment
  void showCommentDialog() {
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
          //post button
          TextButton(
            onPressed: () {
              // add comment
              addComment(_commentTextController.text);

              // pop box
              Navigator.pop(context);

              // clear controller
              _commentTextController.clear();
            },
            child: Text("Post"),
          ),

          //cancel button
          TextButton(
            onPressed: () {
              // pop box
              Navigator.pop(context);

              // clear controller
              _commentTextController.clear();
            },
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

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
              // Header with the user profile pic and username
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
                      widget.user,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              // Message
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  widget.message,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),

              // Like and Comment Section
              Row(
                children: [
                  LikeButton(isLiked: isLiked, onTap: toggleLike),
                  SizedBox(width: 10),
                  Text(
                    widget.likes.length.toString(),
                    style: TextStyle(color: Colors.black),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: showCommentDialog,
                    child: Row(
                      children: [
                        Icon(Icons.comment, color: Colors.grey[600]),
                        SizedBox(width: 10),
                        StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("User Posts")
                                .doc(widget.postId)
                                .collection("comments")
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasData) {
                                // liczba odkumentow to liczba komentarzy
                                int commentsCount = snapshot.data!.docs.length;
                                return Text(
                                  commentsCount.toString(),
                                  style: TextStyle(color: Colors.grey[600]),
                                );
                              } else {
                                //jesli nie ma danych zwroc 0
                                return Text(
                                  '0',
                                  style: TextStyle(color: Colors.grey[600]),
                                );
                              }
                            })
                      ],
                    ),
                  ),
                ],
              ),

              // Comments under the post
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .doc(widget.postId)
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
                            time: commentData["CommentTime"] != null
                                ? formatDate(
                                    commentData["CommentTime"] as Timestamp)
                                : 'Brak daty',
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
}
