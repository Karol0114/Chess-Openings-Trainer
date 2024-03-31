import 'package:chess_openings_trainer/chess_board.dart';
import 'package:chess_openings_trainer/friends_page.dart';
import 'package:chess_openings_trainer/learn_openings_page.dart';
import 'package:chess_openings_trainer/signin_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'friends_page.dart';
import 'package:chess_openings_trainer/play_openings.dart';
//import 'package:chess_openings_trainer/learn_openings_page.dart';
import 'package:chess_openings_trainer/openings_score_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBuR58C-Uj32pOvbhXhdTPHknK1c5I5BUg",
          appId: "1:332377044451:android:852b3ea41d0c5f14311cd6",
          messagingSenderId: "332377044451",
          projectId: "chess-openings-trainer-ai"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Openings Trainer',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark().copyWith(
          primary: Colors.blue,
          secondary: Colors.blue,
        ),
        textTheme: const TextTheme(
          bodyText1: TextStyle(color: Colors.white),
          bodyText2: TextStyle(color: Colors.white),
        ),
      ),
      home: const SignInScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        children: <Widget>[
          _buildTitle('Train openings', Icons.school),
          _buildTitle('Play openings', Icons.play_arrow),
          _buildTitle('Openings score', Icons.check_circle_outline_rounded),
          _buildTitle('Play game', Icons.gamepad),
          _buildTitle('Friends', Icons.people),
        ],
      ),
    );
  }

  Widget _buildTitle(String title, IconData icon) {
    return InkWell(
      onTap: () {
        if (title == 'Train openings') {
          var push = Navigator.push(context,
              MaterialPageRoute(builder: (context) => const OpeningsPage()));
        } else if (title == 'Play openings') {
          var push = Navigator.push(context,
              MaterialPageRoute(builder: (context) => const PlayOpenings()));
        } else if (title == 'Openings score') {
          var push = Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CountingScoreOpenings()));
        } else if (title == 'Play game') {
          var push = Navigator.push(context,
              MaterialPageRoute(builder: (context) => const GameBoard()));
        } else if (title == 'Friends') {
          var push = Navigator.push(context,
              MaterialPageRoute(builder: (context) => const FriendsPage()));
        }
        print('$title tapped!');
      },
      child: Card(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 70.0),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
