import 'package:chess_openings_trainer/learn_openings_page.dart';
import 'package:flutter/material.dart';
import 'package:chess_openings_trainer/play_openings.dart';
import 'package:chess_openings_trainer/learn_openings_page.dart';
import 'package:chess_openings_trainer/openings_score_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Opening trainer',
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
      home: const MyHomePage(title: 'Chess Openings Trainer'),
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
          
        ],
      ),
    );
  }

  Widget _buildTitle(String title, IconData icon) {
    return InkWell(
      onTap: () {
        if (title == 'Train openings') {
          var push = Navigator.push(context, MaterialPageRoute(builder: (context) => const OpeningsPage()));
        } else if (title == 'Play openings') {
          var push = Navigator.push(context, MaterialPageRoute(builder: (context) => const PlayOpenings()));
        } else if (title == 'Openings score') {
          var push = Navigator.push(context, MaterialPageRoute(builder: (context) => const CountingScoreOpenings()));
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
