import 'package:flutter/material.dart';

class CountingScoreOpenings extends StatelessWidget {
  const CountingScoreOpenings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tutaj zakładamy, że liczba wszystkich wariantów to x
    String totalVariants =
        'X'; // Przykładowa wartość, zmień na faktyczną liczbę wariantów

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose opening to play'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            // Wyświetlenie informacji o wyniku
            child: Text('Overall result: 0/$totalVariants',
                style: TextStyle(fontSize: 20, color: Colors.white)),
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                _buildExpansionTile(
                  title: 'French Defense',
                  variants: [
                    'The Classical Variation',
                    'The Advance Variation',
                    'The Steinitz Variation',
                    'The Winawer Variation',
                    'The Tarrasch Variation',
                    'The Greek Gift'
                  ],
                ),
                // Pozostałe wywołania _buildExpansionTile...
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(
      {required String title, required List<String> variants}) {
    return Theme(
      data: ThemeData(
        unselectedWidgetColor: Colors.white,
        textTheme: TextTheme(
          titleMedium: TextStyle(color: Colors.white),
        ),
        expansionTileTheme: ExpansionTileThemeData(
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
        ),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        children: variants
            .map((variant) => ListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(left: 48.0),
                    child: Row(
                      children: [
                        Text(
                          variant,
                          style: const TextStyle(color: Colors.white),
                        ),
                        Spacer(), // Użyj Spacer, aby checkbox był wyrównany do prawej
                        Checkbox(
                          value: false, // Szary checkbox (niezaznaczony)
                          onChanged: (bool? value) {
                            // Tutaj dodasz logikę zmiany stanu checkboxa
                          },
                          checkColor: Colors.green, // Kolor zaznaczenia
                          fillColor: MaterialStateProperty.all(
                              Colors.grey), // Kolor tła checkboxa
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
