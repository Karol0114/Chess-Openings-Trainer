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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 67, 190, 10),
          borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Row(
        children: [
          //profile pic
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[400],
            ),
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
          SizedBox(
            width: 20,
          ),
          //expanded to take the remaining space
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user,
                  style: TextStyle(color: Colors.grey[800]),
                ),
                SizedBox(height: 10),
                Text(widget.message),
              ],
            ),
          ),
          LikeButton(isLiked: isLiked, onTap: toggleLike),
          const SizedBox(
            width: 20,
          ),
          const SizedBox(height: 5),
          Text(
            widget.likes.length.toString(),
            style: TextStyle(color: Colors.grey[600]),
          ),

          // //message and user email
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Text(
          //       user,
          //       style: TextStyle(color: Colors.grey[800]),
          //     ),
          //     const SizedBox(
          //       height: 10,
          //     ),
          //     Text(message),
          //   ],
          // )
        ],
      ),
    );
  }
}
