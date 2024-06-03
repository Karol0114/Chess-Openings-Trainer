import 'dart:async';
import 'package:chess_openings_trainer/compontents/dead_piece.dart';
import 'package:chess_openings_trainer/compontents/piece.dart';
import 'package:chess_openings_trainer/helper/helper_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
import 'package:chess_openings_trainer/compontents/square.dart';
import 'package:flutter/widgets.dart';

class GameBoard extends StatefulWidget {
  final String gameId;

  const GameBoard({super.key, required this.gameId});

  @override 
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late StreamSubscription<DocumentSnapshot> _gameStream;




void makeMove(String move) {
  // Funkcja, która wykonuje ruch i zapisuje go w Firestore
  FirebaseFirestore.instance.collection('games').doc(widget.gameId).update({
    'moves': FieldValue.arrayUnion([move])
  });
}
  // tablica 2 wymairowa ktora bedzie reprezentować plansze zachową, wraz z odpowiednią pozycja srtartową figury


  late List<List<ChessPiece?>> board;

  // Wybranie figury z planszy, natomiast jeżeli uzytkownik wybierze pole bez gfiogury, to będzie wartość null
  ChessPiece? selectedPiece;

  // Wartość wiersza, wybranego przez uzytkonwika. Domyslnie, jest wartość -1, która oznacza, że żadna figura nie została wybrana
  int selectedRow = -1;
  // Wartość kolumny, wybranego przez uzytkonwika. Domyslnie, jest wartość -1, która oznacza, że żadna figura nie została wybrana
  int selectedCol = -1;


  // Lista możliwych ruchów

  List<List<int>> validMoves = [];


  // Lisa białych figur, które zostały zbite przez czarnego użytkownika
  List<ChessPiece> whitePiecesTaken = [];

  // Lisa czarnych figur, które zostały zbite przez białego użytkownika
  List<ChessPiece> blackPiecesTaken = [];

  // Identyfikacja, czyj jest teraz ruch, zmienną ustalamy na true, ponieważ białe zaczynają

  bool isWhiteTurn = true;


  // inicjalizacja pozycji królów (sledzenia pozycji, ułatwi sprawdzenie czy król jest szachowany)

  List <int> whiteKingPosition = [7,4];
  List <int> blackKingPosition = [0,4];

  bool checkStatus = false;

  // Obliczanie prawdziwych legalnych ruchów, odnosi sie do sytuacji, gdy krol jest szachowany

  List<List<int>> calculateRealValidMoves(int row, int col, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);


    if (checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];

        if (simulatedMoveIsIafe(piece!, row,col,endRow,endCol)) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = candidateMoves;
    } 

    return realValidMoves;

  }



  // Implementacja roszady

  bool whiteKingMoved = false;
  bool whiteRookKingSideMoved = false;
  bool whiteRookQueenSideMoved = false;

  bool blackKingMoved = false;
  bool blackRookKingSideMoved = false;
  bool blackRookQueenSideMoved = false;



  @override
  void initState() {
    super.initState();
    _initializeBoard();
    _gameStream = FirebaseFirestore.instance.collection('games').doc(widget.gameId)
        .snapshots().listen((snapshot) {
      if (snapshot.exists) {
        var gameData = snapshot.data()!;
        updateBoard(gameData['moves']);
      }
    });
  }

   void updateBoard(List<dynamic> moves) {
  // Resetowanie planszy do stanu początkowego
  _initializeBoard();

  // Iteracja przez każdy ruch zapisany w Firestore
  for (String move in moves) {
    List<String> positions = move.split('-');
    List<int> startPos = positions[0].split(',').map((x) => int.parse(x)).toList();
    List<int> endPos = positions[1].split(',').map((x) => int.parse(x)).toList();

    // Przeniesienie figury
    ChessPiece? movingPiece = board[startPos[0]][startPos[1]];
    board[endPos[0]][endPos[1]] = movingPiece;
    board[startPos[0]][startPos[1]] = null;

    // Sprawdzenie promocji pionka
    if (movingPiece != null && movingPiece.type == ChessPieceType.pawn && (endPos[0] == 0 || endPos[0] == 7)) {
      promotePawn(endPos[0], endPos[1], movingPiece.isWhite);
    }

    // Aktualizacja pozycji królów w razie ruchu króla
    if (movingPiece != null && movingPiece.type == ChessPieceType.king) {
      if (movingPiece.isWhite) {
        whiteKingPosition = [endPos[0], endPos[1]];
      } else {
        blackKingPosition = [endPos[0], endPos[1]];
      }
    }
  }

  // Uaktualnienie stanu aplikacji
  setState(() {});
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

     // Jeżeli, żadna figura nie była zaznaczona, to będzie to pierwzym zaznaczeniem

     if(selectedPiece == null && board[row][col] != null) {
      if(board[row][col]!.isWhite == isWhiteTurn) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }
     }

     // jeżeli figura jest zaznaczna, to użytkowenik może wybrać figure inną, aby zbić figurę, obecnie zaznaczoną figurą

     else if(board[row][col] != null && board[row][col]!.isWhite == selectedPiece!.isWhite ) {
      selectedPiece = board[row][col];
      selectedRow = row;
      selectedCol = col;
     }

     // jeżeli figura została wybrana, oraz uzytkownik wybral legalne posunięcie, to posun tam figure

     else if (selectedPiece != null && validMoves.any((element) => element[0] == row && element[1] == col)) {
      movePiece(row, col);
     }

     // jezeli figura została zaznaczona, oblicz jej mozliwe posunięcia

     validMoves = calculateRealValidMoves(selectedRow, selectedCol, selectedPiece, true);
  });
}

void promotePawn(int row, int col, bool isWhite) {
  board[row][col] = ChessPiece(
    type: ChessPieceType.queen,
    isWhite: isWhite,
    imagePath: isWhite ? 'lib/images/queen.png' : 'lib/images/queen.png',

  );
}

  // Obliczenie możliwych ruchów, dla poszczególnych figur

  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece){
    List<List<int>> candidateMoves = [];

    if (piece == null) {
      return [];
    }
    // Różnica kierunku, bazując na jej kolorze
    
    int direction = piece.isWhite ? -1: 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        // Pionki poruszają sie tylko do przodu, jeżeli pole nie jest zajęte
        if (isInBoard(row + direction, col) && board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }
        // Pionki moga sie poruszać o 2 pola do przodu, jeżeli sa na startowej pozycji
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) && board[row + 2 * direction][col] == null && board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }
        // Pionki biją po przekątnej

        if(isInBoard(row + direction, col - 1) && board[row + direction][col - 1] != null && board[row + direction][col - 1] !.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if(isInBoard(row + direction, col + 1) && board[row + direction][col + 1] != null && board[row + direction][col + 1] !.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }
        break;
      case ChessPieceType.rook:

        var directions = [
          [-1,0], // góra
          [1,0], // dół
          [0,-1], // lewo
          [0,1], //prawo
        ];

        for (var direction in directions) {
          var i = 1;

          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }

            if (board[newRow][newCol] != null) {
              if(board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.knight:
        // Ruchy konia, przypominają literę L, isntieje 8 możliwości
        
        var knightMoves = [
          [-2,-1], // dwa do góry, jeden w lewo
          [-2,1], //dwa do góry, jeden w prawo
          [-1,-2], // jeden do góry, dwa w lewo
          [-1,2], //jeden do góry, dwa w prawo
          [1, -2], // jeden w dół, dwa w lewo
          [1,2], // jeden w dół, dwa w prawo
          [2, -1], // dwa w dół jeden w lewo
          [2, 1], // dwa w dół, jeden w prawo

        ];

        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }

          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      case ChessPieceType.bishop:
      // Gońce poruszają sie po przekątnych

      var directions = [
        [-1,-1], //gora lewo
        [-1, 1], // góra prawo
        [1,-1], // dół lewo
        [1,1], //dół prawo
      ];

      for (var direction in directions) {
        var i = 1;
        while (true) {
          var newRow = row + i * direction[0];
          var newCol = col + i * direction[1];

          if (!isInBoard(newRow, newCol)) {
            break;
          }

          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            break;
          }
          candidateMoves.add([newRow, newCol]);
          i++;
        }
      }
        break;
      case ChessPieceType.queen:
        // królowa porusza się po 8 polach w górę, dół, lewo, prawo, i po 4 przekątnych

        var directions = [
          [-1,0], // gora
          [1,0], // dół
          [0,-1], // lewo
          [0,1], // prawo
          [-1,-1], // góra lewo
          [-1,1], // góra prawo
          [1,-1], // dół lewo
          [1,1], // dół prawo
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow,newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.king:
      // król porusza się tak samo jak królowa, tylko jedno o jedno pole w kazdym kierunku
        var directions = [
          [-1,0], // gora
          [1,0], // dół
          [0,-1], // lewo
          [0,1], // prawo
          [-1,-1], // góra lewo
          [-1,1], // góra prawo
          [1,-1], // dół lewo
          [1,1], // dół prawo
        ];

        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];

          if (!isInBoard(newRow, newCol)) {
            continue;
          }

          if (board[newRow][newCol] != null) {
            if(board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }

            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        if ((!piece.isWhite && !blackKingMoved) || (piece.isWhite && !whiteKingMoved)) {
          // Sprawdź, czy droga dla roszady krótkiej jest wolna
          if (board[row][5] == null && board[row][6] == null) {
            candidateMoves.add([row, 6]);  // Pozycja po roszadzie krótkiej
          }
          // Sprawdź, czy droga dla roszady długiej jest wolna
          if (board[row][1] == null && board[row][2] == null && board[row][3] == null) {
            candidateMoves.add([row, 2]);  // Pozycja po roszadzie długiej
          }
        }
        break;
      default:

    }
    
    return candidateMoves;
  }

  // RUSZ FIGURĘ

  void movePiece(int newRow, int newCol) {

    // Sytuacja w której nowym miejscem figury, jest miejsce na ktrej znajduje się czarna figura:
    if(board[newRow][newCol] != null) {
      //dodaj zbitą figurę do odpowiedniej listy
      var capturedPiece = board[newRow][newCol];

      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }

    }
    // Po ruszeniu figurą wyczyszczenie starego jej miesjca
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // Sprawdzenie czy króle są pod atakiem
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    if (selectedPiece!.type == ChessPieceType.king) {
      // Jeśli ruch wykonuje król, to aktualizujemy flagi ruchu dla króla i wież
      if (selectedPiece!.isWhite) {
        whiteKingMoved = true;
        // Jeśli to roszada, zaktualizuj również pozycję wiezy
        

      } else {
        blackKingMoved = true;
        // Jeśli to roszada, zaktualizuj równiez pozycję wieży
      }
    }

    if (selectedPiece!.type == ChessPieceType.pawn) {
      if ((selectedPiece!.isWhite && newRow == 0) || (!selectedPiece!.isWhite && newRow == 7)) {
        promotePawn(newRow, newCol, selectedPiece!.isWhite);
      }
    }

    


    // Roszada
    if (selectedPiece!.type == ChessPieceType.king) {

      // Roszada krótka
      if (newCol - selectedCol == 2) {
        board[newRow][5] = board[newRow][7];  // Przenieś wieżę
        board[newRow][7] = null;  // Usuń wieżę ze starej pozycji
      }
      // Roszada długa
      else if (selectedCol - newCol == 2) {
        board[newRow][3] = board[newRow][0];  // Przenieś wieżę
        board[newRow][0] = null;  // Usuń wieżę ze starej pozycji
      } 
    }
    

    



    // Usunięcie wybrania tej figury
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    if (isCheckMate(!isWhiteTurn)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("CHECK MATE!"),
          actions: [
            TextButton(onPressed: resetGame, child: const Text("Play again"),),
          ],
        ),
      );
    }


    // Zmiana kolejki, czyli po wykonwnaiu ruchu białych, ruch moga wykonac tylko czarne

    isWhiteTurn = !isWhiteTurn;
  }

    // Sprawdzenie czy król jest szachowany

    bool isKingInCheck(bool isWhiteKing) {
      // zdobycie pozycji króla
      List<int> kingPosition = isWhiteKing ? whiteKingPosition : blackKingPosition;

      //sprawdzenie czy przeciwna figura atakuje króla

      for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
          ChessPiece? oposingPiece = board[i][j];
          if(oposingPiece == null || oposingPiece.isWhite == isWhiteKing) {
            continue;
          }

          List<List<int>> pieceValidMoves = calculateRawValidMoves(i, j, oposingPiece);

          if (pieceValidMoves.any((move) => move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
            return true;

          
          }
        }
    }
    

    return false;
  }


  bool simulatedMoveIsIafe(ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {

    ChessPiece? originalDestinationPiece = board[endRow][endCol];


    List<int>? originalKingPosition;

    if(piece.type == ChessPieceType.king) {
      originalKingPosition = piece.isWhite ? whiteKingPosition : blackKingPosition;

      if(piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;


    bool kingInCheck = isKingInCheck(piece.isWhite);

    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    if (piece.type == ChessPieceType.king) {
      if(piece.isWhite) {
        whiteKingPosition = [startRow, startCol];
      } else {
        blackKingPosition = [startRow, startCol];
      }
    }

    return !kingInCheck;
  }

  // SZACH MAT

  bool isCheckMate(bool isWhiteKing) {

    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {

        if(board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, board[i][j], true);

        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  // Rest do nowej gry

  void resetGame() {
    Navigator.pop(context);
    _initializeBoard();
    checkStatus = false;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];

    setState(() {
      
    });

  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      
          
          
        body: Column(
          children: [

            // Zbite białe pionki
            Expanded(
              child: GridView.builder(
                itemCount: whitePiecesTaken.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8), 
                itemBuilder: (context, index) => DeadPiece(
                  isWhite: true,
                  imagePath: whitePiecesTaken[index].imagePath,
                ),
                ),
            ),

            // Status gry

            Text(checkStatus ? "CHECK!" : ""),

            // Szachowa plansza
            Expanded(
              flex: 3,
              child: GridView.builder(
                itemCount: 8 * 8,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: 
                    const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                itemBuilder: (context, index) {
              
                  int row = index ~/ 8;
                  int col = index % 8;
              
                  bool isSelected = selectedRow == row && selectedCol == col;
              
                    // sprawdzenie, czy pole, które chce wybrac uzytkownik jest prawdiłowe
              
                  bool isValidMove = false;
                  for (var position in validMoves){
                    if (position[0] == row && position[1] == col) {
                      isValidMove = true;
                    }
                  }
              
                  return Square(
                    isWhite: isWhite(index),
                    piece: board[row][col],
                    isSelected: isSelected,
                    isValidMove: isValidMove,
                    onTap: () => pieceSelected(row, col),
                  );
                  },
                ),
            ),

              // Zbite czarne pionki
              Expanded(
              child: GridView.builder(
                itemCount: blackPiecesTaken.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8), 
                itemBuilder: (context, index) => DeadPiece(
                  isWhite: false,
                  imagePath: blackPiecesTaken[index].imagePath,
                ),
                ),
            ),
          ],
        ),
        );
      //),
    //);
  }
}
