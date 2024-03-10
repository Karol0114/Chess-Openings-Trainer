bool isWhite (int index) {
  int x = index ~/ 8;
  int y = index % 8;

  bool isWhite = (x + y) % 2 == 0;

  return isWhite;
}