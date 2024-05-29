import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Comment extends StatelessWidget {
  final String text;
  final String user;
  final Timestamp time; // Przekazywanie obiektu Timestamp

  const Comment({
    super.key,
    required this.text,
    required this.user,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('dd-MM HH:mm').format(time.toDate());

    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 2,
              offset: Offset(0, 2),
            )
          ]),
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Row(
            children: [
              Text(user,
                  style: TextStyle(
                    color: Colors.grey[850],
                    fontWeight: FontWeight.bold,
                  )),
              Spacer(),
              Text(formattedTime,
                  style: TextStyle(
                    color: Colors.grey[600],
                  )),
            ],
          )
        ],
      ),
    );
  }
}
