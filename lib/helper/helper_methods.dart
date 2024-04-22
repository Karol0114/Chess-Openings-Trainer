import 'package:cloud_firestore/cloud_firestore.dart';

bool isWhite(int index) {
  int x = index ~/ 8;
  int y = index % 8;

  bool isWhite = (x + y) % 2 == 0;

  return isWhite;
}

bool isInBoard(int row, int col) {
  return row >= 0 && row < 8 && col >= 0 && col < 8;
}

// return a formatted data as string
String formatDate(Timestamp? timestamp) {
  // timestamp is object we retrieve from firebase so to display it les convert
  // it to a string
  if (timestamp == null) {
    return 'brak daty';
  }

  DateTime dateTime = timestamp.toDate();

// get year
  String year = dateTime.year.toString();

// get month
  String month = dateTime.month.toString();

// get day
  String day = dateTime.day.toString();

  // final formatted date
  String formattedData = '$day/$month/$year';

  return formattedData;
}
