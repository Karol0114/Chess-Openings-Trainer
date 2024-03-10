import 'package:chess_openings_trainer/compontents/piece.dart';
import 'package:flutter/material.dart';

class Square extends StatelessWidget {
  final bool isWhite;

  final ChessPiece? piece;

  final bool isSelected;
  
  final void Function()? onTap;

  const Square({super.key, required this.isWhite, required this.piece, required this.isSelected, required this.onTap,});

  @override 
  Widget build(BuildContext context) {

    Color? squareColor;

    // Jeżeli uzytkownik wybierze figure, to podswietla się na zielono
    if(isSelected) {
      squareColor = Colors.green;
    } else {
      squareColor = isWhite ? Colors.brown[200] : Colors.brown[600];
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: squareColor,
        child: piece != null 
            ? Image.asset(
              piece!.imagePath,
              color: piece!.isWhite ? Colors.white : Colors.black,
              ) 
            : null,
      ),
    );
  }
}