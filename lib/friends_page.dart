import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_page.dart';
import 'profile_page.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
      ),
      body: FriendsList(),
    );
  }
}

class FriendsList extends StatefulWidget {
  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];

  void _searchUsers() async {
    String searchText = _searchController.text.trim();
    if (searchText.isNotEmpty) {
      try {
        String endText = searchText + '\uf8ff';
        QuerySnapshot querySnapshot = await firestore
            .collection('usernames')
            .where(FieldPath.documentId, isGreaterThanOrEqualTo: searchText)
            .where(FieldPath.documentId, isLessThanOrEqualTo: endText)
            .get();

        setState(() {
          _searchResults = querySnapshot.docs;
        });
      } catch (e) {
        print('Error searching users: $e');
      }
    } else {
      print('Search text is empty');
    }
  }

  void _sendFriendRequest(String friendId) async {
    User? user = auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await firestore.collection('Users').doc(user.uid).get();
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;
        String username = userData?['username'] ?? 'unknown';

        await firestore
            .collection('Users')
            .doc(friendId)
            .collection('friendRequests')
            .doc(user.uid)
            .set({'username': username});
        print('Friend request sent to $friendId');
      } catch (e) {
        print('Error sending friend request: $e');
      }
    } else {
      print('No user is currently logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = auth.currentUser;
    if (user == null) {
      return Center(child: Text('No user logged in'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search by username',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: _searchUsers,
              ),
            ),
          ),
        ),
        Expanded(
          child: _searchResults.isNotEmpty
              ? ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    var userDoc = _searchResults[index];
                    var username = userDoc.id;
                    var userId = userDoc['userId'];
                    return ListTile(
                      title: Text(username),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(userId: userId),
                          ),
                        );
                      },
                      trailing: IconButton(
                        icon: Icon(Icons.person_add),
                        onPressed: () {
                          _sendFriendRequest(userId);
                        },
                      ),
                    );
                  },
                )
              : StreamBuilder(
                  stream: firestore
                      .collection('Users')
                      .doc(user.uid)
                      .collection('friends')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading friends'));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No friends found'));
                    }

                    var friends = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        var friend = friends[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 4,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            title: Text(
                              friend['username'],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing:
                                Icon(Icons.chat, color: Colors.blueAccent),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                      friendId: friend.id,
                                      friendName: friend['username']),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
