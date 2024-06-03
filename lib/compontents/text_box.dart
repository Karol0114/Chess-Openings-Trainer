import 'package:flutter/material.dart';

class MyTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final Function? onPressed;
  final bool showEditIcon;

  MyTextBox({
    required this.text,
    required this.sectionName,
    this.onPressed,
    this.showEditIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(color: Colors.white),
            ),
            if (showEditIcon && onPressed != null)
              IconButton(
                icon: Icon(Icons.edit, color: Colors.white),
                onPressed: () => onPressed!(),
              ),
          ],
        ),
      ),
    );
  }
}
