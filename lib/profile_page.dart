import "package:chess_openings_trainer/compontents/text_box.dart";
import "package:chess_openings_trainer/signin_page.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;

  //edit field
  Future<void> editField(String field, String currentValue) async {
    String newValue = currentValue;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Edit " + field),
        content: TextField(
          onChanged: (value) {
            newValue = value;
          },
          controller: TextEditingController(text: currentValue),
          decoration: InputDecoration(hintText: "Enter new $field"),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('save'),
            onPressed: () async {
              Navigator.of(context).pop();
              await FirebaseFirestore.instance
                  .collection("Users")
                  .doc(currentUser.uid)
                  .update({field: newValue});
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  //method for logout
  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignInScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
        backgroundColor: Colors.grey[900],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          Map<String, dynamic> userData =
              snapshot.data?.data() as Map<String, dynamic>? ??
                  {
                    'username': 'Your username',
                    'bio': 'Your bio',
                  };
          return ListView(
            children: <Widget>[
              // profile pic
              const SizedBox(height: 50),
              const Icon(Icons.person, size: 72),
              const SizedBox(height: 10),
              // user email
              Text(
                currentUser.email!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
              // user details
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Text(
                  'My details',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              // username
              MyTextBox(
                text: userData['username'] ?? 'no username provided',
                sectionName: 'username',
                onPressed: () => editField(
                    'username', userData['username'] ?? 'no username provided'),
                showEditIcon: false,
              ),
              // bio
              MyTextBox(
                text: userData['bio'] ?? 'no bio avaliable',
                sectionName: 'bio',
                onPressed: () =>
                    editField('bio', userData['bio'] ?? 'no bio avaliable'),
              ),
              const SizedBox(height: 50),
              // user posts
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Text(
                  'My Posts',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              // button
              ElevatedButton(
                onPressed: () => _signOut(context),
                child: Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
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
