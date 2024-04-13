import "package:flutter/material.dart";

class MyTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final void Function()? onPressed;
  final bool showEditIcon;

  const MyTextBox({
    super.key,
    required this.text,
    required this.sectionName,
    required this.onPressed,
    this.showEditIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[600],
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
      ),
      child: ConstrainedBox(
        // Zastosowanie ConstrainedBox
        constraints: BoxConstraints(
          minHeight: 60, // Minimalna wysokość każdego pola
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 15,
            bottom: 15,
            top: 15, // Dodałem padding górny
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sectionName,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  if (showEditIcon)
                    IconButton(
                        onPressed: onPressed, icon: Icon(Icons.settings)),
                ],
              ),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}
