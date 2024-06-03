import "package:chess_openings_trainer/compontents/text_box.dart";
import "package:chess_openings_trainer/signin_page.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class ProfilePage extends StatefulWidget {
  final String userId;

  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> editField(String field, String currentValue) async {
    String newValue = currentValue;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Edytuj " + field),
        content: TextField(
          onChanged: (value) {
            newValue = value;
          },
          controller: TextEditingController(text: currentValue),
          decoration: InputDecoration(hintText: "Wprowadź nowe $field"),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Anuluj'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Zapisz'),
            onPressed: () async {
              Navigator.of(context).pop();
              await FirebaseFirestore.instance
                  .collection("Users")
                  .doc(widget.userId)
                  .update({field: newValue});
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignInScreen()));
  }

  void _acceptFriendRequest(String requesterId) async {
    try {
      User? user = auth.currentUser;
      if (user != null) {
        // Fetch the requester's username
        DocumentSnapshot requesterDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(requesterId)
            .get();
        Map<String, dynamic>? requesterData =
            requesterDoc.data() as Map<String, dynamic>?;
        String requesterUsername = requesterData?['username'] ?? 'unknown';

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('friends')
            .doc(requesterId)
            .set({'username': requesterUsername});
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(requesterId)
            .collection('friends')
            .doc(user.uid)
            .set({'username': user.displayName ?? 'unknown'});
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('friendRequests')
            .doc(requesterId)
            .delete();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Błąd przy akceptowaniu zaproszenia: $e"),
      ));
    }
  }

  void _rejectFriendRequest(String requesterId) async {
    try {
      User? user = auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('friendRequests')
            .doc(requesterId)
            .delete();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Błąd przy odrzucaniu zaproszenia: $e"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = auth.currentUser;
    bool isCurrentUser =
        currentUser != null && currentUser.uid == widget.userId;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        backgroundColor: Colors.grey[900],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Błąd: ${snapshot.error}"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Brak danych użytkownika'));
          }

          Map<String, dynamic> userData =
              snapshot.data?.data() as Map<String, dynamic>? ??
                  {
                    'username': 'brak nazwy użytkownika',
                    'bio': 'brak bio',
                  };

          return ListView(
            children: <Widget>[
              const SizedBox(height: 50),
              const Icon(Icons.person, size: 72),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Text(
                  'username',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              MyTextBox(
                text: userData['username'] ?? 'brak nazwy użytkownika',
                sectionName: 'username',
                showEditIcon: false,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Text(
                  'bio',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              MyTextBox(
                text: userData['bio'] ?? 'brak bio',
                sectionName: 'bio',
                onPressed: isCurrentUser
                    ? () => editField('bio', userData['bio'] ?? 'brak bio')
                    : null,
                showEditIcon: isCurrentUser,
              ),
              if (isCurrentUser)
                ElevatedButton(
                  onPressed: () => _signOut(context),
                  child: Text('Wyloguj się'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              if (isCurrentUser)
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(widget.userId)
                      .collection('friendRequests')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Błąd: ${snapshot.error}"));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('Brak zaproszeń do znajomych'));
                    }

                    var requests = snapshot.data!.docs;
                    return Column(
                      children: requests.map((request) {
                        var requesterId = request.id;
                        var requesterName = request['username'] ?? 'unknown';
                        return ListTile(
                          title: Text(requesterName),
                          subtitle: Text('Chce dodać cię do znajomych'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.check, color: Colors.green),
                                onPressed: () {
                                  _acceptFriendRequest(requesterId);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  _rejectFriendRequest(requesterId);
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

void _signOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('email');
  await prefs.remove('password');
  await prefs.remove('isRememberMe');

  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (context) => SignInScreen()));
}
