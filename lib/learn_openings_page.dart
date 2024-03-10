import 'package:flutter/material.dart';
import 'package:chess_openings_trainer/chess_board.dart';

class OpeningsPage extends StatelessWidget {
  const OpeningsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose opening'),
      ),
      body: ListView(
        children:  <Widget>[
          
          _buildExpansionTile(
            context,
            title: 'French Defense',
            variants: ['The Classical Variation', 'The Advance Variation', 'The Steinitz Variation', 'The Winawer Variation', 'The Tarrasch Variation', 'The Greek Gift'],
          ),
          _buildExpansionTile(
            context,
            title: 'Italian Game',
            variants: ['The Giuoco Piano', 'The Evans Gambit', 'The Two Knights Defence', 'The Fried Liver Attack'],
          ),
          _buildExpansionTile(
            context,
            title: 'Sicilian Defense',
            variants: ['The Open Sicilian', 'The Alapin Variation', 'The Smith Morra Gambit', 'Grand Prix Attack', 'Bowdler Attack'],
          ),
          _buildExpansionTile(
            context,
            title: "King's Gambit",
            variants: ["King's Pawn Opening", "King's Gambit Accepted", "King's Gambit Declined"],
          ),
          _buildExpansionTile(
            context,
            title: 'Vienna Game',
            variants: ['Main Line', 'Falkbeer Gambit', 'Max Lange Defense', 'Mieses Variation'],
          ),
          _buildExpansionTile(
            context,
            title: "Queen's Gambit",
            variants: ['Classical Variation'],
          ),
          _buildExpansionTile(
            context,
            title: "Special Openings",
            variants: ['Sandomiersky Gambit', 'Bartosh Gambit Teeth Variation'],
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(BuildContext context, {required String title, required List<String> variants}){
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
        children: variants.map((variant) => ListTile(
          title: Padding(
            padding: const EdgeInsets.only(left: 48.0),
            child: Text(
              variant,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          onTap: () {
            // Plansza do gry
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameBoard(),
              ),

            );
          }
        )).toList()
        )
    );
  }
}
