import 'package:flutter/material.dart';
import 'package:chess_openings_trainer/chess_board.dart';
import 'package:flutter/widgets.dart';
import 'package:chess_openings_trainer/main.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pobierz szerokość ekranu i podziel przez 2, aby pola tekstowe miały połowę szerokości ekranu
    final double textFieldWidth = MediaQuery.of(context).size.width / 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login to Chess Openings Trainer'),
      ),
      body: SingleChildScrollView( // Umożliwi przewijanie, gdy klawiatura jest wyświetlona
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox( // Używamy ConstrainedBox, aby nadać maksymalną szerokość
                  constraints: BoxConstraints(maxWidth: textFieldWidth),
                  child: const TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress, // Ustawienie klawiatury dla email
                  ),
                ),
                const SizedBox(height: 16.0), // Odstęp między polami
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: textFieldWidth),
                  child: const TextField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true, // Ukrywanie tekstu dla bezpieczeństwa
                  ),
                ),
                const SizedBox(height: 24.0), // Odstęp przed przyciskiem
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: textFieldWidth),
                  child: ElevatedButton(
                    onPressed: () {
                      // Logika logowania (tu trzeba ją dodać)
                      // Po zalogowaniu przechodzimy do MyHomePage
                      Navigator.pushReplacement( // Zamiast push użyj pushReplacement, aby zapobiec powrotowi do ekranu logowania
                      context,
                      MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Chess Openings Trainer')),
                      );
                    },
                    child: const Text('Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
