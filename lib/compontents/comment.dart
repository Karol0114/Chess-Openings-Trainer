import "package:flutter/material.dart";

class Comment extends StatelessWidget {
  final String text;
  final String user;
  final String time;
  const Comment(
      {super.key, required this.text, required this.user, required this.time});

  @override
  Widget build(BuildContext context) {
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
          //comment
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          //user and time
          Row(
            children: [
              Text(user,
                  style: TextStyle(
                    color: Colors.grey[850],
                    fontWeight: FontWeight.bold,
                  )),
              Spacer(),
              Text(time,
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
