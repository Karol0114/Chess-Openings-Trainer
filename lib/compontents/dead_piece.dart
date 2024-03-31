import 'package:flutter/material.dart';

class DeadPiece extends StatelessWidget {
  final String imagePath;
  final bool isWhite;

  const DeadPiece({super.key, required this.isWhite, required this.imagePath});


  @override 
  Widget build(BuildContext context) {
    Color pieceColor = isWhite ? Colors.white : Colors.black;
    return Image.asset(
      imagePath,
      color: pieceColor
    );
  }
}