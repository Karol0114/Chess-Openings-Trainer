import 'package:chess_openings_trainer/chess_board.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LobbyPage extends StatefulWidget {
  @override
  _LobbyPageState createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  late Stream<QuerySnapshot> _gamesStream;

  Future<String> createGame() async {
    var newGame = {
      "players": [
        FirebaseAuth.instance.currentUser!.uid,
      ], // aktualnie zalogowany użytkownik jako biały
      "status": "waiting", // oczekiwanie na drugiego gracza
      "moves": [],
      "turn": FirebaseAuth.instance.currentUser!.uid,
      "gameResult": null
    };

    DocumentReference gameRef =
        await FirebaseFirestore.instance.collection('games').add(newGame);
    return gameRef
        .id; // Zwróć ID gry, które będzie używane do dołączania do gry
  }

  Future<bool> joinGame(String gameId) async {
    DocumentReference gameRef = FirebaseFirestore.instance.collection('games').doc(gameId);
    DocumentSnapshot gameSnap = await gameRef.get();

  if (gameSnap.exists) {
    Map<String, dynamic> gameData = gameSnap.data() as Map<String, dynamic>;
    List<dynamic> players = gameData['players'];

    // Sprawdź czy gra oczekuje na drugiego gracza i czy aktualnie zalogowany użytkownik nie jest już graczem
    if (gameData['status'] == 'waiting' && players.length == 1 && !players.contains(FirebaseAuth.instance.currentUser!.uid)) {
      await gameRef.update({
        'players': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
        'status': 'inProgress' // Zmiana statusu gry na 'w trakcie'
      });
      return true; // Dołączenie powiodło się
    }
  }
  return false; // Nie udało się dołączyć
}

  @override
  void initState() {
    super.initState();
    _gamesStream = FirebaseFirestore.instance
        .collection('games')
        .where('status', isEqualTo: 'waiting')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chess Lobby'),
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () async {
                String gameId = await createGame();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => GameBoard(gameId: gameId)));
              },
              child: Text('Create New Game')),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _gamesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> game =
                        document.data()! as Map<String, dynamic>;
                    return ListTile(
                      title: Text('Game ${document.id}'),
                      subtitle: Text('Tap to join'),
                      onTap: () async {
                        bool joined = await joinGame(document.id);
                        if (joined) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      GameBoard(gameId: document.id)));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Failed to join the game")));
                        }
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
