import 'package:chess_openings_trainer/compontents/piece.dart';
import 'package:chess_openings_trainer/helper/helper_methods.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
import 'package:chess_openings_trainer/compontents/square.dart';

class GameBoard extends StatefulWidget {
  

  const GameBoard({super.key});

  @override 
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {

  // tablica 2 wymairowa ktora bedzie reprezentować plansze zachową, wraz z odpowiednią pozycja srtartową figury

  late List<List<ChessPiece?>> board;

  // Wybranie figury z planszy, natomiast jeżeli uzytkownik wybierze pole bez gfiogury, to będzie wartość null
  ChessPiece? selectedPiece;

  // Wartość wiersza, wybranego przez uzytkonwika. Domyslnie, jest wartość -1, która oznacza, że żadna figura nie została wybrana
  int selectedRow = -1;
  // Wartość kolumny, wybranego przez uzytkonwika. Domyslnie, jest wartość -1, która oznacza, że żadna figura nie została wybrana
  int selectedCol = -1;
  @override 
  void initState() {
    super.initState();
    _initializeBoard();
  }
  // Inicjalizacja planszy
  void _initializeBoard() {
    // Zainicjalizujmy plansze, z wartościami null, ktore oznaczac beda brak figur na danym polu, a do reszty pol przypiszemy odpowiednio figury 
    List<List<ChessPiece?>> newBoard = List.generate(8, (index) => List.generate(8, (index) => null));


    
        // Miejsce pionków
        for (int i = 0; i < 8; i++) {
          newBoard[1][i] = ChessPiece(type: ChessPieceType.pawn, isWhite: false, imagePath: 'lib/images/pawn.png',);
        }

        for (int i = 0; i < 8; i++) {
          newBoard[6][i] = ChessPiece(type: ChessPieceType.pawn, isWhite: true, imagePath: 'lib/images/pawn.png',);
        }
        // Miejsce wież
        newBoard[0][0] = ChessPiece(type: ChessPieceType.rook, isWhite: false, imagePath: 'lib/images/rook.png',);
        newBoard[0][7] = ChessPiece(type: ChessPieceType.rook, isWhite: false, imagePath: 'lib/images/rook.png',);
        newBoard[7][0] = ChessPiece(type: ChessPieceType.rook, isWhite: true, imagePath: 'lib/images/rook.png',);
        newBoard[7][7] = ChessPiece(type: ChessPieceType.rook, isWhite: true, imagePath: 'lib/images/rook.png',);
        // Miejsce gońców
        newBoard[0][2] = ChessPiece(type: ChessPieceType.bishop, isWhite: false, imagePath: 'lib/images/bishop2.png',);
        newBoard[0][5] = ChessPiece(type: ChessPieceType.bishop, isWhite: false, imagePath: 'lib/images/bishop2.png',);
        newBoard[7][2] = ChessPiece(type: ChessPieceType.bishop, isWhite: true, imagePath: 'lib/images/bishop2.png',);
        newBoard[7][5] = ChessPiece(type: ChessPieceType.bishop, isWhite: true, imagePath: 'lib/images/bishop2.png',);

        // Miejsce skoczków
        newBoard[0][1] = ChessPiece(type: ChessPieceType.knight, isWhite: false, imagePath: 'lib/images/knight.png',);
        newBoard[0][6] = ChessPiece(type: ChessPieceType.knight, isWhite: false, imagePath: 'lib/images/knight.png',);
        newBoard[7][1] = ChessPiece(type: ChessPieceType.knight, isWhite: true, imagePath: 'lib/images/knight.png',);
        newBoard[7][6] = ChessPiece(type: ChessPieceType.knight, isWhite: true, imagePath: 'lib/images/knight.png',);
        // Miejsce królowych
        newBoard[0][3] = ChessPiece(type: ChessPieceType.queen, isWhite: false, imagePath: 'lib/images/queen.png',);
        newBoard[7][3] = ChessPiece(type: ChessPieceType. queen, isWhite: true, imagePath: 'lib/images/queen.png',);
        // Miejsce króli
        newBoard[0][4] = ChessPiece(type: ChessPieceType.king, isWhite: false, imagePath: 'lib/images/king.png',);
        newBoard[7][4] = ChessPiece(type: ChessPieceType.king, isWhite: true, imagePath: 'lib/images/king.png',);
        board = newBoard;
  }

// Wybór figury przez użytkownika

void pieceSelected(int row, int col) {
  setState(() {
     // Jeżeli na wybranym polu przez użytkownika jest figura to ją zaznaczamy

     if(board[row][col] != null) {
      selectedPiece = board[row][col];
      selectedRow = row;
      selectedCol = col;
     }
  });
}

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Centrujemy planszę na ekranie
        child: AspectRatio(
          aspectRatio: 1, // Zachowaj proporcje 1:1
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5, // Plansza zajmuje 50% szerokości ekranu
            height: MediaQuery.of(context).size.width * 0.5, // Opcjonalnie, jeśli chcesz ustawić wysokość
          
            child: GridView.builder(
              itemCount: 8 * 8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: 
                  const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index) {

                int row = index ~/ 8;
                int col = index % 8;

                bool isSelected = selectedRow == row && selectedCol == col;


                return Square(
                  isWhite: isWhite(index),
                  piece: board[row][col],
                  isSelected: isSelected,
                  onTap: () => pieceSelected(row, col),
                );
              },
            ),
          ),
        ),
      ),
    );
  }   
}
