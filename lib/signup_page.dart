import 'package:chess_openings_trainer/reusable_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chess_openings_trainer/home_page.dart';
//import 'package:firebase_signin/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:chess_openings_trainer/signin_page.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

Future<bool> isUsernameUnique(String username) async {
  final usernameResult = await FirebaseFirestore.instance
      .collection('usernames')
      .doc(username)
      .get();
  return !usernameResult.exists;
}



class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter UserName", Icons.person_outline, false,
                    _userNameTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Email Id", Icons.person_outline, false,
                    _emailTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Password", Icons.lock_outlined, true,
                    _passwordTextController),
                const SizedBox(
                  height: 20,
                ),
                firebaseUIButton(context, "Sign Up", () async {
                  String username = _userNameTextController.text;
                  String email = _emailTextController.text;
                  if (await isUsernameUnique(username)) {
                    try {
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .createUserWithEmailAndPassword(
                        email: email,
                        password: _passwordTextController.text,
                      );

                      //Add user to the Firestore database
                      await FirebaseFirestore.instance
                          .collection("Users")
                          .doc(userCredential.user!.uid)
                          .set({
                        'username': _userNameTextController.text,
                        'bio': 'Empty bio',
                        //here you can add additional user info like below:
                      });
                      await FirebaseFirestore.instance
                          .collection('usernames')
                          .doc(username)
                          .set({
                        'userId': userCredential.user!.uid,
                      });

                      print("Created New Account");

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignInScreen()));
                    } catch (e) {
                      print("Error: ${e.toString()}");
                      if (e is FirebaseAuthException) {
                        if(e.code == 'email-already-in-use') {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Email is already in use")));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "An error occurred")));
                        }
                      }
                    }
                  } else if (!await isUsernameUnique(username)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Username is already taken")));
                  } 
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
