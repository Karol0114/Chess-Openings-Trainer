import 'package:chess_openings_trainer/compontents/wall_post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chess_openings_trainer/compontents/text_field.dart';
import 'package:intl/intl.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  //scroll messages to newest
  final ScrollController _scrollController = ScrollController();

  //user
  final currentUser = FirebaseAuth.instance.currentUser!;

  //text controller
  final textController = TextEditingController();

  //zmienna do przechowywania nazwy uzytkownika
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
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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
        print("user docuemnt does not exist for uid: ${currentUser.uid}");
      }
    } catch (e) {
      print("error fetching usernaem: $e");
    }
    // setState(() {
    //   username = userDoc.data()?[
    //       'username']; //pobierz nazwe zuytkownika z dokumentu Firestores
    //   print("Username is: $username");
    // });
  }

  void postMessage() {
    //only post if there is something in the text field
    if (textController.text.isNotEmpty && username != null) {
      //store in firebase
      FirebaseFirestore.instance.collection("User Posts").add({
        'Username': username,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
    }

    //clear after send
    setState(() {
      textController.clear();
    });
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

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Community'),
        ),
        body: Center(
          child: Column(
            children: [
              // the wall
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
                          //get the message
                          // final post = snapshot.data!.docs[index].data()
                          //     as Map<String, dynamic>;

                          //Formatowanie Timestamp na czytelny format daty i czasu
                          final DateTime postTime =
                              (post['TimeStamp'] as Timestamp).toDate();
                          final String formattedTime =
                              DateFormat('yyyy-MM-dd - kk:mm').format(postTime);
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
                              });
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
              //post message
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Row(
                  children: [
                    //textfield
                    Expanded(
                      child: MyTextField(
                        controller: textController,
                        hintText: 'Write something here!',
                        obscureText: false,
                        maxLines: null,
                      ),
                    ),

                    //post button
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
