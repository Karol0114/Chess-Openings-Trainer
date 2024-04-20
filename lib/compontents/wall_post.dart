import 'package:chess_openings_trainer/compontents/like_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    isLiked = widget.likes.contains(currentUser.email);
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
      "CommentedBy": currentUser.email,
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
            onPressed: () => addComment(_commentTextController.text),
            child: Text("Post"),
          ),

          //cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Card(
        color: Color.fromARGB(255, 67, 190, 10),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
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
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.user,
                      style: TextStyle(
                          color: Colors.grey[800], fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              // Message
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(widget.message),
              ),

              // Like and Comment Section
              Row(
                children: [
                  LikeButton(isLiked: isLiked, onTap: toggleLike),
                  SizedBox(width: 10),
                  Text(
                    "${widget.likes.length} likes",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: showCommentDialog,
                    child: Row(
                      children: [
                        Icon(Icons.comment, color: Colors.grey[600]),
                        SizedBox(width: 10),
                        Text(
                          "0",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
