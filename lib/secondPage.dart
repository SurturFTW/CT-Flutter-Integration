import 'package:flutter/material.dart';

class DeepLinkPage extends StatelessWidget {
  final String? type;
  final String? title;
  final String? message;

  const DeepLinkPage({
    Key? key,
    required this.type,
    required this.title,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Deep Link Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Type: $type", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text("Title: $title", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text("Message: $message", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
