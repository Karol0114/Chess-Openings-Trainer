import 'package:flutter/material.dart';

class PlayOpenings extends StatelessWidget {
  const PlayOpenings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose opening to play'),
      ),
      body: ListView(
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
          _buildExpansionTile(
            title: 'Italian Game',
            variants: ['Classical Variation'],
          ),
          _buildExpansionTile(
            title: 'Sicilian Defense',
            variants: ['Classical Variation'],
          ),
          _buildExpansionTile(
            title: "King's Gambit",
            variants: ['Classical Variation'],
          ),
          _buildExpansionTile(
            title: 'Vienna Game',
            variants: ['Classical Variation'],
          ),
          _buildExpansionTile(
            title: "Queen's Gambit",
            variants: ['Classical Variation'],
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
            subtitle1: TextStyle(color: Colors.white),
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
                        child: Text(
                          variant,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ))
                .toList()));
  }
}
